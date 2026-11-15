{
  osConfig,
  config,
  lib,
  ...
}:
let
  secrets = osConfig.secrets.values;
in
{
  config.services.podman.containers =
    let
      homerConfig = network: {
        "$schema" =
          "https://raw.githubusercontent.com/homer-dashboard/homer/main/.schema/config-schema.json";
        title =
          {
            admin = "Laboratoire Maison";
            friends = "Serveur d'Aurore";
          }
          .${network};
        subtitle = lib.trivial.version;
        logo = "assets/logo.png";
        footer = false;
        columns = "auto";
        connectivityCheck = true;
        defaults = {
          layout = "list";
          colorTheme = "auto";
        };
        theme = "neon";
        colors = {
          light.background-image = "/assets/light.png";
          dark.background-image = "/assets/dark.png";
        };
        services =
          let
            widgets = builtins.mapAttrs (
              let
                customServices = {
                  transmission = {
                    type = "Transmission";
                  };
                  prowlarr = {
                    type = "Prowlarr";
                    apikey = secrets.prowlarr;
                  };
                  traefik = {
                    type = "Traefik";
                  };
                  vaultwarden = {
                    type = "Vaultwarden";
                  };
                  jellyfin = {
                    type = "Emby";
                    apikey = secrets.jellyfin;
                    libraryType = "series";
                  };
                  radarr = {
                    type = "Radarr";
                    apikey = secrets.radarr;
                  };
                  sonarr = {
                    type = "Sonarr";
                    apikey = secrets.sonarr;
                  };
                  lidarr = {
                    type = "Lidarr";
                    apikey = secrets.lidarr;
                  };
                  miniflux = {
                    type = "Miniflux";
                    apikey = secrets.miniflux;
                  };
                  paperless = {
                    type = "PaperlessNG";
                    apikey = secrets.paperless;
                  };
                  nextcloud = {
                    type = "Nextcloud";
                  };
                  pi-hole = {
                    type = "PiHole";
                    endpoint = "https://pi-hole.${secrets.dns}/";
                    apiVersion = 6;
                    url = "https://pi-hole.${secrets.dns}/admin";
                  };
                };
              in
              name: container:
              if (builtins.hasAttr "PORT" container.environment) && (builtins.elem network container.network) then
                {
                  inherit name;
                  logo =
                    let # https://dashboardicons.com/
                      exceptions = {
                        yubal = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/yubal.svg";
                        traefik = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/traefik-proxy.svg";
                        llmfit = "https://raw.githubusercontent.com/AlexsJones/llmfit/refs/heads/main/assets/icon.svg";
                        jellyfin-friends = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellyfin.svg";
                        traefik-friends = exceptions.traefik;
                      };
                    in
                    if (builtins.hasAttr name exceptions) then
                      exceptions.${name}
                    else
                      "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/${name}.svg";
                  url = "https://${name}.${
                    {
                      admin = secrets.dns;
                      friends = secrets.dns-friends;
                    }
                    .${network}
                  }/";
                }
                // (if (builtins.hasAttr name customServices) then customServices.${name} else { })
              else
                {
                  inherit name;
                  logo = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/i-am-programmer-kawaii-japanese.svg";
                  class = "navbar-menu";
                }
            ) config.services.podman.containers;
          in
          [
            {
              name = "*Arr & Misc";
              icon = "fa-solid fa-cloud-arrow-down";
              items = [
                widgets.transmission
                widgets.lidarr
                widgets.sonarr
                widgets.radarr
                widgets.bazarr
                widgets.fileflows
                widgets.yubal
                widgets.prowlarr
                widgets.jackett
              ];
            }
            {
              name = "Fun times";
              icon = "fa-solid nf-md-cards_playing";
              items = [
                widgets.jellyfin
                widgets.jellyfin-friends
              ];
            }
            {
              name = "Infra";
              icon = "fa-solid fa-bridge";
              items = [
                widgets.traefik
                widgets.traefik-friends
                widgets.scrutiny
                widgets.pi-hole
                widgets.it-tools
                # widgets.flaresolverr
              ];
            }
            {
              name = "Documents";
              icon = "fa-solid fa-briefcase";
              items = [
                widgets.paperless
                widgets.photoprism
                widgets.nextcloud
                widgets.vaultwarden
              ];
            }
            {
              name = "Work";
              icon = "fa-solid fa-hammer";
              items = [
                widgets.miniflux
                widgets.logseq
                widgets.reactive-resume
                widgets.open-webui
                widgets.llmfit
                widgets.changedetection
              ];
            }
          ];
      };
      light = builtins.fetchurl {
        url = "https://xenia-images.efi.pages.gay/chimmie_egg-wallpaper_light.png";
        sha256 = "1ss6k7li6kh355ga80jy7pi0j90x154g8f37vr42v542slshak5h";
      };
      dark = builtins.fetchurl {
        url = "https://xenia-images.efi.pages.gay/chimmie_egg-wallpaper_dark.png";
        sha256 = "19pbzv5rv5r1mlblcnvnba8waz2063dx6h5ibchknbwlbjqcawjx";
      };
      logo = builtins.fetchurl {
        url = "https://xenia-images.efi.pages.gay/chimmie_firefox.png";
        sha256 = "1jbdabykdpr3mmna3clzsa6qxg1z9w9i19nr3a6i4is9hlfj4g6a";
      };
    in
    {
      homer = {
        image = "docker.io/b4bz/homer:latest";
        volumes = [
          "${builtins.toFile "homerConfig.json" (builtins.toJSON (homerConfig "admin"))}:/www/assets/config.yml"
          "${light}:/www/assets/light.png"
          "${dark}:/www/assets/dark.png"
          "${logo}:/www/assets/logo.png"
        ];
        environment = {
          PORT = 8080;
          INIT_ASSETS = 0;
        };
        network = [ "admin" ];
        autoUpdate = "registry";
      };
      homer-friends = {
        image = "docker.io/b4bz/homer:latest";
        volumes = [
          "${builtins.toFile "homerConfig.json" (builtins.toJSON (homerConfig "friends"))}:/www/assets/config.yml"
          "${light}:/www/assets/light.png"
          "${dark}:/www/assets/dark.png"
          "${logo}:/www/assets/logo.png"
        ];
        environment = {
          PORT = 8080;
          INIT_ASSETS = 0;
        };
        network = [ "friends" ];
        autoUpdate = "registry";
      };
    };
}
