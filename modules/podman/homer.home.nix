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
      homerConfig = {
        title = "Laboratoire Maison";
        subtitle = "Nix language evaluator v${builtins.nixVersion} with Nix${builtins.toString builtins.langVersion}";
        logo = "assets/logo.webp";
        # header = true;
        footer = false;
        columns = "auto";
        connectivityCheck = false;
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
                url = "https://jellyfin.${secrets.dns}";
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
              pihole = {
                type = "PiHole";
                endpoint = "https://pihole.${secrets.dns}/";
                apiVersion = 6;
                url = "https://pihole.${secrets.dns}/admin";
              };
            };
            widgets = builtins.mapAttrs (
              name: container:
              if (builtins.hasAttr "PORT" container.environment) then
                {
                  inherit name;
                  logo =
                    let # https://dashboardicons.com/
                      exceptions = {
                        yubal = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/yubal.svg";
                        pi-hole = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pi-hole.svg";
                        traefik = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/traefik-proxy.svg";
                      };
                    in
                    if (builtins.hasAttr name exceptions) then
                      exceptions.${name}
                    else
                      "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/${name}.svg";
                  url = "https://${name}.${secrets.dns}/";
                }
                // (if (builtins.hasAttr name customServices) then customServices.${name} else { })
              else
                null
            ) config.services.podman.containers;
          in
          [
            (lib.mkIf false {
              name = "Everyone is Here!";
              icon = "fa-solid fa-dragon";
              items =
                let
                  values = builtins.attrValues widgets;
                in
                builtins.genList (
                  i:
                  let
                    value = builtins.elemAt values i;
                  in
                  if (value != null) then value else { }
                ) (builtins.length values);
            })
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
              name = "Infra";
              icon = "fa-solid fa-bridge";
              items = [
                widgets.traefik
                widgets.scrutiny
                widgets.pihole
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
                widgets.changedetection
              ];
            }
          ];
      };
    in
    {
      homer = {
        image = "docker.io/b4bz/homer:latest";
        volumes = [
          "${builtins.toFile "homerConfig.json" (builtins.toJSON homerConfig)}:/www/assets/config.yml"
          "${
            builtins.fetchurl {
              url = "https://xenia-images.efi.pages.gay/chimmie_egg-wallpaper_light.png";
              sha256 = "1ss6k7li6kh355ga80jy7pi0j90x154g8f37vr42v542slshak5h";
            }
          }:/www/assets/light.png"
          "${
            builtins.fetchurl {
              url = "https://xenia-images.efi.pages.gay/chimmie_egg-wallpaper_dark.png";
              sha256 = "19pbzv5rv5r1mlblcnvnba8waz2063dx6h5ibchknbwlbjqcawjx";
            }
          }:/www/assets/dark.png"
          "${
            builtins.fetchurl {
              url = "https://xenia-images.efi.pages.gay/jd-laclede1.webp";
              sha256 = "1vzkkxfd0hbpbz97xc24v2ykhwn9ci2vhxzvs8lwknh8lrw5qlhm";
            }
          }:/www/assets/logo.webp"
        ];
        environment = {
          PORT = 8080;
          INIT_ASSETS = 0;
        };
        network = [ "docker-like" ];
        autoUpdate = "registry";
      };
    };
}
