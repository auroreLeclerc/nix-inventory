{
  config,
  osConfig,
  lib,
  ...
}:
let
  secrets = osConfig.secrets.values;
in
{
  config.services.podman.containers =
    let
      debug = false;
      traefikConfig = network: {
        log.level = "INFO";
        api = {
          dashboard = true;
          insecure = true;
        };
        entrypoints = {
          web = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
            };
          };
          websecure = {
            address = ":443";
            http.tls = {
              certResolver = "duckresolver";
              domains =
                {
                  admin = [
                    {
                      main = secrets.dns;
                      sans = "*.${secrets.dns}";
                    }
                  ];
                  friends = [
                    {
                      main = secrets.dns-friends;
                      sans = "*.${secrets.dns-friends}";
                    }
                  ];
                }
                .${network};
            };
          };
        };
        certificatesresolvers.duckresolver.acme = {
          dnschallenge = {
            provider = "duckdns";
            propagation.delaybeforechecks = 120;
          };
          email = secrets.mail;
          storage = "/letsencrypt/acme.json";
        };
        providers.file.filename = "/etc/traefik/dynamic.yml";
      };
      dynamicConfig = network: {
        http = {
          middlewares = {
            # https://github.com/traefik/traefik/issues/12536
            block-traefik-hub.headers.customResponseHeaders.Content-Security-Policy = "default-src 'self' 'unsafe-inline';";
            error-handler.errors = {
              status = [
                "400-404"
                "500-599"
              ]; # transmission needs 409 untouch
              service = "error-handler";
              query = "/{status}";
            };
            cors-handler.headers = {
              accessControlAllowMethods = [
                "GET"
                "HEAD"
                "OPTIONS"
              ];
              accessControlAllowHeaders = "*";
              accessControlAllowOriginList = "*";
              accessControlMaxAge = 100;
              addVaryHeader = true;
            };
          };
          routers = builtins.mapAttrs (
            name: container:
            if (builtins.hasAttr "PORT" container.environment) && (builtins.elem network container.network) then
              {
                rule = "Host(`${name}.${
                  {
                    admin = secrets.dns;
                    friends = secrets.dns-friends;
                  }
                  .${network}
                }`)";
                entryPoints = [ "websecure" ];
                service = name;
                middlewares = [
                  "cors-handler"
                  "error-handler"
                ];
              }
            else
              null
          ) config.services.podman.containers;
          services =
            (builtins.mapAttrs (
              name: container:
              if (builtins.hasAttr "PORT" container.environment) && (builtins.elem network container.network) then
                {
                  loadBalancer = {
                    servers = [
                      { url = "http://${name}:${toString container.environment.PORT}"; }
                    ];
                    healthCheck =
                      if (builtins.hasAttr "HEALTHCHECK_PATH" container.environment) then
                        {
                          path = container.environment.HEALTHCHECK_PATH;
                          interval = container.environment.HEALTHCHECK_INTERVAL or "30s";
                          timeout = container.environment.HEALTHCHECK_TIMEOUT or "5s";
                        }
                      else
                        null;
                  };
                }
              else
                null
            ) config.services.podman.containers)
            // {
              error-handler.loadBalancer.servers = [ { url = "http://error-pages:8080"; } ]; # static
            };
        };
      };
    in
    {
      whoami = lib.mkIf debug {
        image = "docker.io/traefik/whoami:latest";
        environment.PORT = 80;
        network = [
          "admin"
          "friends"
        ];
        autoUpdate = "registry";
      };
      traefik = {
        image = "docker.io/library/traefik:latest";
        volumes = [
          "/run/media/dawn/cubus/traefik:/letsencrypt"
          "${builtins.toFile "traefikConfig.json" (builtins.toJSON (traefikConfig "admin"))}:/etc/traefik/traefik.yml"
          "${builtins.toFile "dynamicConfig.json" (builtins.toJSON (dynamicConfig "admin"))}:/etc/traefik/dynamic.yml"
        ];
        environment = {
          PORT = 8080;
          DUCKDNS_TOKEN = secrets.duck;
        };
        ip4 = "172.18.0.254";
        network = [ "admin" ];
        autoUpdate = "registry";
      };
      traefik-friends = {
        image = "docker.io/library/traefik:latest";
        volumes = [
          "/run/media/dawn/cubus/traefik-friends:/letsencrypt"
          "${builtins.toFile "traefikConfig.json" (builtins.toJSON (traefikConfig "friends"))}:/etc/traefik/traefik.yml"
          "${builtins.toFile "dynamicConfig.json" (builtins.toJSON (dynamicConfig "friends"))}:/etc/traefik/dynamic.yml"
        ];
        environment = {
          PORT = 8080;
          DUCKDNS_TOKEN = secrets.duck;
        };
        ip4 = "172.19.0.254";
        network = [ "friends" ];
        autoUpdate = "registry";
      };
      error-pages = {
        image = "ghcr.io/tarampampam/error-pages:3";
        environment = {
          PORT = lib.mkIf debug 8080;
          TEMPLATE_NAME = "connection";
        };
        network = [
          "admin"
          "friends"
        ];
        autoUpdate = "registry";
      };
    };
}
