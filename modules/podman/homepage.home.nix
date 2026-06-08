{ osConfig, ... }:
let
  secrets = osConfig.secrets.values;
in
{
  config.services.podman.containers =
    let
      homePageSettings = {
        title = "Laboratoire Maison";
        description = "A description of my awesome homepage";
        favicon = "/images/icon.png";
        color = "violet";
        background = "/images/dark.png";
        language = "fr";
      };
      homePageServices = [
        {
          "Administration" = [
            {
              Transmission = {
                icon = "transmission";
                widget = {
                  type = "transmission";
                  url = "https://transmission.${secrets.dns}";
                };
              };
            }
            {
              Jackett = {
                icon = "jackett";
                widget = {
                  type = "jackett";
                  url = "https://jackett.${secrets.dns}";
                };
              };
            }
            {
              Prowlarr = {
                icon = "prowlarr";
                widget = {
                  type = "prowlarr";
                  key = secrets.prowlarr;
                  url = "https://prowlarr.${secrets.dns}";
                };
              };
            }
            {
              Traefik = {
                icon = "traefik";
                widget = {
                  type = "traefik";
                  url = "https://traefik.${secrets.dns}";
                };
              };
            }
            {
              Pihole = {
                icon = "pihole";
                widget = {
                  type = "pihole";
                  url = "https://pihole.${secrets.dns}/";
                  version = 6;
                };
              };
            }
            {
              Vaultwarden = {
                icon = "vaultwarden";
                href = "https://vaultwarden.${secrets.dns}/";
              };
            }
          ];
        }
        {
          "Multimédia" = [
            {
              Jellyfin = {
                icon = "jellyfin";
                widget = {
                  type = "jellyfin";
                  url = "https://jellyfin.${secrets.dns}";
                  key = secrets.jellyfin;
                  version = 2;
                  enableBlocks = true;
                };
              };
            }
            {
              Radarr = {
                icon = "radarr";
                widget = {
                  type = "radarr";
                  url = "https://radarr.${secrets.dns}";
                  key = secrets.radarr;
                };
              };
            }
            {
              Sonarr = {
                icon = "sonarr";
                widget = {
                  type = "sonarr";
                  url = "https://sonarr.${secrets.dns}";
                  key = secrets.sonarr;
                };
              };
            }
            {
              Lidarr = {
                icon = "lidarr";
                widget = {
                  type = "lidarr";
                  url = "https://lidarr.${secrets.dns}";
                  key = secrets.lidarr;
                };
              };
            }
            {
              Yubal = {
                icon = "yubal";
                href = "https://yubal.${secrets.dns}";
              };
            }
            {
              Fileflows = {
                icon = "fileflows";
                widget = {
                  type = "fileflows";
                  url = "https://fileflows.${secrets.dns}";
                };
              };
            }
            {
              Bazarr = {
                icon = "bazarr";
                widget = {
                  type = "bazarr";
                  url = "https://bazarr.${secrets.dns}";
                };
              };
            }
          ];
        }
        {
          "Documents" = [
            {
              Reactive-Resume = {
                icon = "reactive-resume";
                href = "https://reactive-resume.${secrets.dns}";
              };
            }
            {
              Miniflux = {
                icon = "miniflux";
                widget = {
                  type = "miniflux";
                  url = "https://miniflux.${secrets.dns}/";
                  key = secrets.miniflux;
                };
              };
            }
            {
              Photoprism = {
                icon = "photoprism";
                widget = {
                  type = "photoprism";
                  url = "https://photoprism.${secrets.dns}/";
                };
              };
            }
            {
              Paperless = {
                icon = "paperlessngx";
                widget = {
                  type = "paperlessngx";
                  url = "https://paperless.${secrets.dns}/";
                  key = secrets.paperless;
                };
              };
            }
            {
              IT-Tools = {
                icon = "it-tools";
                href = "https://it-tools.${secrets.dns}/";
              };
            }
            {
              Nextcloud = {
                icon = "nextcloud";
                widget = {
                  type = "nextcloud";
                  url = "https://nextcloud.${secrets.dns}/";
                };
              };
            }
            {
              Changedetection = {
                icon = "changedetectionio";
                widget = {
                  type = "changedetectionio";
                  url = "https://changedetection.${secrets.dns}/";
                };
              };
            }
            {
              Logseq = {
                icon = "logseq";
                href = "https://logseq.${secrets.dns}/";
              };
            }
            {
              Scrutiny = {
                icon = "scrutiny";
                widget = {
                  type = "scrutiny";
                  url = "https://scrutiny.${secrets.dns}/";
                };
              };
            }
          ];
        }
      ];
    in
    {
      homepage = {
        image = "ghcr.io/gethomepage/homepage:latest";
        volumes = [
          "${builtins.toFile "homePageSettings.json" (builtins.toJSON homePageSettings)}:/app/config/settings.yaml"
          "${builtins.toFile "homePageServices.json" (builtins.toJSON homePageServices)}:/app/config/services.yaml"
          "${
            builtins.fetchurl {
              url = "https://xenia-images.efi.pages.gay/chimmie_egg-wallpaper_light.png";
              sha256 = "sha256-sEwFNdWClC1I3mc49EgJHSQJ4j1eAqReKQNOE+mZRus=";
            }
          }:/app/public/images/light.png"
          "${
            builtins.fetchurl {
              url = "https://xenia-images.efi.pages.gay/chimmie_egg-wallpaper_dark.png";
              sha256 = "sha256-XXLFsFyULzshW7FA09swQHzFkVp2W0YXrSGXncv+66Y=";
            }
          }:/app/public/images/dark.png"
          "${
            builtins.fetchurl {
              url = "https://xenia-images.efi.pages.gay/neotheta_sigil.png";
              sha256 = "0y4liw0p4cydl44hqm3db5vcpn0fwxxyks92s6mlqwjhzbaqlsj2";
            }
          }:/app/public/images/icon.png"
        ];
        environment = {
          PORT = 3000;
          HOMEPAGE_ALLOWED_HOSTS = "homepage.${secrets.dns}";
        };
        network = [ "docker-like" ];
        autoUpdate = "registry";
      };
    };
}
