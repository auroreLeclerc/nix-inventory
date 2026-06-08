{ osConfig, ... }:
let
  secrets = osConfig.secrets.values;
in
{
  config.services.podman.containers =
    let
      homePageSettings = {
        title = "Laboratoire Maison";
        description = "OwO";
        favicon = "/images/icon.webp";
        color = "violet";
        background = "/images/dark.png";
        cardBlur = "md";
        language = "fr";
        headerStyle = "boxedWidgets";
      };
      homePageServices = [
        {
          "Administration" = [
            {
              Transmission = {
                icon = "transmission";
                href = "https://transmission.${secrets.dns}";
                widget = {
                  type = "transmission";
                  url = "https://transmission.${secrets.dns}";
                };
              };
            }
            {
              Jackett = {
                icon = "jackett";
                href = "https://jackett.${secrets.dns}";
                widget = {
                  type = "jackett";
                  url = "https://jackett.${secrets.dns}";
                };
              };
            }
            {
              Prowlarr = {
                icon = "prowlarr";
                href = "https://prowlarr.${secrets.dns}";
                widget = {
                  type = "prowlarr";
                  key = secrets.prowlarr;
                  url = "https://prowlarr.${secrets.dns}";
                };
              };
            }
            {
              Traefik = {
                icon = "traefik-proxy";
                href = "https://traefik.${secrets.dns}";
                widget = {
                  type = "traefik";
                  url = "https://traefik.${secrets.dns}";
                };
              };
            }
            {
              Pihole = {
                icon = "pi-hole";
                href = "https://pihole.${secrets.dns}";
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
                href = "https://jellyfin.${secrets.dns}";
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
                href = "https://radarr.${secrets.dns}";
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
                href = "https://sonarr.${secrets.dns}";
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
                href = "https://lidarr.${secrets.dns}";
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
                href = "https://fileflows.${secrets.dns}";
                widget = {
                  type = "fileflows";
                  url = "https://fileflows.${secrets.dns}";
                };
              };
            }
            {
              Bazarr = {
                icon = "bazarr";
                href = "https://bazarr.${secrets.dns}";
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
                href = "https://miniflux.${secrets.dns}";
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
                href = "https://photoprism.${secrets.dns}";
                widget = {
                  type = "photoprism";
                  url = "https://photoprism.${secrets.dns}/";
                };
              };
            }
            {
              Paperless = {
                icon = "paperless-ngx";
                href = "https://paperless.${secrets.dns}";
                widget = {
                  type = "paperless";
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
                href = "https://nextcloud.${secrets.dns}";
                widget = {
                  type = "nextcloud";
                  url = "https://nextcloud.${secrets.dns}/";
                };
              };
            }
            {
              Changedetection = {
                icon = "changedetection";
                href = "https://changedetectionio.${secrets.dns}";
                widget = {
                  type = "changedetection";
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
                href = "https://scrutiny.${secrets.dns}";
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
              url = "https://xenia-images.efi.pages.gay/jd-laclede1.webp";
              sha256 = "1vzkkxfd0hbpbz97xc24v2ykhwn9ci2vhxzvs8lwknh8lrw5qlhm";
            }
          }:/app/public/images/icon.webp"
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
