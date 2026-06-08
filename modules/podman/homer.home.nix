{
  osConfig,
  config,
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
        subtitle = builtins.currentSystem;
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
            {
              name = "Everyone is Here!";
              icon = "fas fa-briefcase";
              items =
                let
                  keys = builtins.attrNames widgets;
                  values = builtins.attrValues widgets;
                  size = builtins.length keys;
                in
                builtins.genList (i: {
                  ${builtins.elemAt keys i} = builtins.elemAt values i;
                }) size;
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
