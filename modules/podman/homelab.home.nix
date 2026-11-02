{
  osConfig,
  config,
  pkgs,
  ...
}:
let
  secrets = osConfig.secrets.values;
  peers = [
    {
      name = "exelo";
      value = "admin";
    }
    {
      name = "taya";
      value = "admin";
    }
    {
      name = "fdeity";
      value = "admin";
    }
    {
      name = "work";
      value = "admin";
    }
    {
      name = "paillettes";
      value = "friends";
    }
    {
      name = "alfa";
      value = "minecraft";
    }
    {
      name = "bravo";
      value = "minecraft";
    }
    {
      name = "charlie";
      value = "minecraft";
    }
    {
      name = "delta";
      value = "minecraft";
    }
    {
      name = "echo";
      value = "minecraft";
    }
    {
      name = "foxtrot";
      value = "minecraft";
    }
    {
      name = "golf";
      value = "minecraft";
    }
    {
      name = "hotel";
      value = "minecraft";
    }
    {
      name = "india";
      value = "minecraft";
    }
    {
      name = "juliett";
      value = "minecraft";
    }
    {
      name = "kilo";
      value = "minecraft";
    }
    {
      name = "lima";
      value = "minecraft";
    }
    {
      name = "mike";
      value = "minecraft";
    }
  ];
  dispatch = builtins.concatStringsSep "\n" (
    builtins.genList (
      i:
      assert (builtins.length peers) < 255 - 2;
      let
        groups = {
          admin = "-j ACCEPT";
          friends = "-g NAC_FRIENDS";
          minecraft = "-g NAC_MINECRAFT";
          banned = "-j DROP";
        };
        peer = builtins.elemAt peers i;
      in
      assert (builtins.match "[A-Za-z0-9_]+" peer.name) != null;
      "-A CUSTOM_NAC -s 10.13.13.${toString (i + 2)}/32 -m comment --comment ${peer.name} ${groups.${peer.value}}"
    ) (builtins.length peers)
  );
  custom-nac = pkgs.writeShellScript "custom-nac.sh" ''
    set -Eeuo pipefail
    trap 'echo "CUSTOM_NAC failed (ligne $LINENO)" >&2; kill 1' ERR

    FRIENDS="${config.services.podman.networks.friends.subnet}"
    MINECRAFT="${config.services.podman.networks.minecraft.subnet}"
    PIHOLE="${config.services.podman.containers.pi-hole.ip4}"

    iptables-restore -w --noflush <<EOF
    *filter
    :CUSTOM_NAC - [0:0]
    :NAC_FRIENDS - [0:0]
    :NAC_MINECRAFT - [0:0]
    :NAC_NO_LAN - [0:0]

    -A NAC_NO_LAN -d 10.0.0.0/8 -j DROP
    -A NAC_NO_LAN -d 172.16.0.0/12 -j DROP
    -A NAC_NO_LAN -d 192.168.0.0/16 -j DROP
    -A NAC_NO_LAN -d 100.64.0.0/10 -j DROP
    -A NAC_NO_LAN -d 169.254.0.0/16 -j DROP
    -A NAC_NO_LAN -d 212.27.38.253 -j DROP

    -A NAC_FRIENDS -d $PIHOLE -p udp --dport 53 -j RETURN
    -A NAC_FRIENDS -d $PIHOLE -p tcp --dport 53 -j RETURN
    -A NAC_FRIENDS -d $FRIENDS -j RETURN
    -A NAC_FRIENDS -j NAC_NO_LAN
    -A NAC_FRIENDS -j RETURN

    -A NAC_MINECRAFT -d $PIHOLE -p udp --dport 53 -j RETURN
    -A NAC_MINECRAFT -d $PIHOLE -p tcp --dport 53 -j RETURN
    -A NAC_MINECRAFT -d $MINECRAFT -p tcp --dport 25565 -j RETURN
    -A NAC_MINECRAFT -j NAC_NO_LAN
    -A NAC_MINECRAFT -j RETURN

    -A CUSTOM_NAC -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    ${dispatch}
    -A CUSTOM_NAC -j DROP
    COMMIT
    EOF

    iptables -w -C FORWARD -i wg0 -j CUSTOM_NAC 2>/dev/null || iptables -w -I FORWARD -i wg0 -j CUSTOM_NAC
    iptables -L CUSTOM_NAC -n --line-numbers
  '';
in
{
  imports = [
    ./podman.home.nix
    ./homer.home.nix
    ./traefik.home.nix
    ./ci-cd.home.nix
  ];
  config = {
    services.podman = {
      containers =
        let
          lsio = {
            PUID = 0;
            PGID = 0;
            TZ = "Europe/Paris";
          };
        in
        {
          jellyfin-friends = {
            image = "lscr.io/linuxserver/jellyfin:latest";
            environment = {
              PORT = 8096;
              HEALTHCHECK_PATH = "/health";
              DOCKER_MODS = "linuxserver/mods:jellyfin-opencl-intel ghcr.io/intro-skipper/intro-skipper-docker-mod";
            }
            // lsio;
            volumes = [
              "/run/media/dawn/bellum/Multimédia/Films:/data/movies:ro"
              "/run/media/dawn/bellum/Multimédia/Séries:/data/tvshows:ro"
              "/run/media/dawn/bellum/new_Music:/data/music:ro"
              "/run/media/dawn/cubus/jellyfin-friends:/config"
              "/run/media/dawn/cache/jellyfin-friends:/config/cache"
            ];
            devices = [ "/dev/dri:/dev/dri" ];
            extraPodmanArgs = [ "--health-cmd 'curl -i http://localhost:8096/health'" ];
            ip4 = "172.19.0.67";
            network = [ "friends" ];
            autoUpdate = "registry";
          };
          wireguard = {
            image = "lscr.io/linuxserver/wireguard:latest";
            addCapabilities = [ "NET_ADMIN" ];
            environment = {
              SERVERURL = secrets.ip;
              PEERS = builtins.concatStringsSep "," (map (peer: peer.name) peers);
              PEERDNS = config.services.podman.containers.pi-hole.ip4;
              PERSITENTKEEPALIVE_PEERS = "all";
              LOG_CONFS = false;
            }
            // lsio;
            volumes = [
              "/run/media/dawn/cubus/wireguard/:/config"
              "${custom-nac}:/custom-cont-init.d/custom-nac.sh:ro"
            ];
            ports = [ "51820:51820/udp" ];
            extraPodmanArgs = [
              "--sysctl net.ipv4.conf.all.src_valid_mark=1"
              "--sysctl net.ipv4.ip_forward=1"
              "--network=admin:ip=172.18.0.252"
              "--network=friends:ip=172.19.0.252"
              "--network=minecraft:ip=172.21.0.252"
            ];
            autoUpdate = "registry";
          };
          transmission = {
            image = "lscr.io/linuxserver/transmission:latest";
            environment = {
              PORT = 9091;
              HEALTHCHECK_PATH = "/transmission/web/";
            }
            // lsio;
            volumes = [
              "/run/media/dawn/cubus/transmission:/config"
              "/run/media/dawn/eox/downloads:/downloads"
              "/run/media/dawn/eox/watchdir:/watch"
            ];
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:9091/transmission/web/ '" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          sonarr = {
            image = "lscr.io/linuxserver/sonarr:latest";
            environment = {
              PORT = 8989;
              HEALTHCHECK_PATH = "/ping";
              SONARR__AUTH__METHOD = "External";
              SONARR__AUTH__APIKEY = osConfig.secrets.values.sonarr;
              SONARR__SERVER__ALLOWEDHOSTS = "sonarr, *.${secrets.dns}";
            }
            // lsio;
            volumes = [
              "/run/media/dawn/cubus/sonarr:/config"
              "/run/media/dawn/eox/downloads:/downloads"
              "/run/media/dawn/bellum/Multimédia/Séries:/tv"
            ];
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:8989/ping '" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          radarr = {
            image = "lscr.io/linuxserver/radarr:latest";
            environment = {
              PORT = 7878;
              HEALTHCHECK_PATH = "/ping";
              RADARR__AUTH__METHOD = "External";
              RADARR__AUTH__APIKEY = osConfig.secrets.values.radarr;
              RADARR__SERVER__ALLOWEDHOSTS = "radarr, *.${secrets.dns}";
            }
            // lsio;
            volumes = [
              "/run/media/dawn/cubus/radarr:/config"
              "/run/media/dawn/eox/downloads:/downloads"
              "/run/media/dawn/bellum/Multimédia/Films:/movies"
            ];
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:7878/ping '" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          jackett = {
            image = "lscr.io/linuxserver/jackett:latest";
            environment = {
              PORT = 9117;
              AUTO_UPDATE = true;
            }
            // lsio;
            volumes = [ "/run/media/dawn/cubus/jackett:/config" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          prowlarr = {
            image = "lscr.io/linuxserver/prowlarr:latest";
            environment = {
              PORT = 9696;
              HEALTHCHECK_PATH = "/ping";
              PROWLARR__AUTH__METHOD = "External";
              PROWLARR__AUTH__APIKEY = osConfig.secrets.values.prowlarr;
              PROWLARR__SERVER__ALLOWEDHOSTS = "prowlarr, *.${secrets.dns}";
            }
            // lsio;
            extraPodmanArgs = [
              "--dns ${config.services.podman.containers.pi-hole.ip4}"
              "--health-cmd 'curl -f http://localhost:9696/ping '"
            ];
            volumes = [ "/run/media/dawn/cubus/prowlarr:/config" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          flaresolverr = {
            image = "ghcr.io/flaresolverr/flaresolverr:latest";
            environment = {
              inherit (lsio) TZ;
              PORT = 8191;
              HEALTHCHECK_PATH = "/health";
              LANG = "fr_FR";
            };
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:8191/health '" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          bazarr = {
            image = "lscr.io/linuxserver/bazarr:latest";
            environment = {
              PORT = 6767;
            }
            // lsio;
            volumes = [
              "/run/media/dawn/cubus/bazarr:/config"
              "/run/media/dawn/bellum/Multimédia/Films:/movies"
              "/run/media/dawn/bellum/Multimédia/Séries:/tv"
            ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          jellyfin = {
            image = "lscr.io/linuxserver/jellyfin:latest";
            environment = {
              PORT = 8096;
              HEALTHCHECK_PATH = "/health";
              DOCKER_MODS = "linuxserver/mods:jellyfin-opencl-intel ghcr.io/intro-skipper/intro-skipper-docker-mod";
            }
            // lsio;
            volumes = [
              "/run/media/dawn/bellum/Multimédia/Films:/data/movies:ro"
              "/run/media/dawn/bellum/Multimédia/Séries:/data/tvshows:ro"
              "/run/media/dawn/bellum/new_Music:/data/music:ro"
              "/run/media/dawn/cubus/jellyfin:/config"
              "/run/media/dawn/cache/jellyfin:/config/cache"
            ];
            devices = [ "/dev/dri:/dev/dri" ];
            extraPodmanArgs = [ "--health-cmd 'curl -i http://localhost:8096/health'" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          lidarr = {
            image = "lscr.io/linuxserver/lidarr:nightly";
            environment = {
              PORT = 8686;
              HEALTHCHECK_PATH = "/ping";
              LIDARR__AUTH__METHOD = "External";
              LIDARR__AUTH__APIKEY = osConfig.secrets.values.lidarr;
              LIDARR__SERVER__ALLOWEDHOSTS = "lidarr, *.${secrets.dns}";
            }
            // lsio;
            volumes = [
              "/run/media/dawn/cubus/lidarr:/config"
              "/run/media/dawn/bellum/new_Music:/music"
              "/run/media/dawn/eox/downloads:/downloads"
            ];
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:8686/ping '" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          yubal = {
            image = "ghcr.io/guillevc/yubal:latest";
            userNS = "keep-id:uid=999,gid=999";
            environment = {
              PORT = 8000;
              YUBAL_SCHEDULER_CRON = "@weekly";
              YUBAL_DOWNLOAD_UGC = false;
              YUBAL_LOG_LEVEL = "WARNING";
              YUBAL_TZ = lsio.TZ;
            };
            volumes = [
              "/run/media/dawn/bellum/new_Music:/app/data"
              "/run/media/dawn/cubus/yubal:/app/config"
            ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          vaultwarden = {
            image = "docker.io/vaultwarden/server:latest";
            # userNS = "keep-id:uid=999,gid=999";
            environment = {
              PORT = 80;
              HEALTHCHECK_PATH = "/alive";
              DOMAIN = "https://vaultwarden.${secrets.dns}/";
              SIGNUPS_ALLOWED = "false";
            };
            volumes = [ "/run/media/dawn/cubus/vaultwarden:/data" ];
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:80/alive '" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          miniflux = {
            image = "docker.io/miniflux/miniflux:latest";
            environment = {
              PORT = 8080;
              DATABASE_URL = "postgresql://postgres:postgres@postgres:5432/miniflux?sslmode=disable";
              RUN_MIGRATIONS = 1;
              CREATE_ADMIN = 1;
              ADMIN_USERNAME = "admin";
              ADMIN_PASSWORD = "adminadmin";
              BASE_URL = "https://miniflux.${secrets.dns}";
            };
            extraPodmanArgs = [ "--health-cmd '/usr/bin/miniflux -healthcheck auto'" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          reactive-resume = {
            image = "docker.io/amruthpillai/reactive-resume:v5";
            userNS = "keep-id:uid=999,gid=999";
            environment = {
              PORT = 3000;
              inherit (lsio) TZ;
              APP_URL = "https://reactive-resume.${secrets.dns}";
              AUTH_SECRET = "NmQRQHGiCKAuerFZct6LM1xRPysr3rYd6TXLqzjclTc=";
              DATABASE_URL = "postgresql://postgres:postgres@postgres:5432/resume";
              FLAG_ALLOW_UNSAFE_AI_BASE_URL = false;
              FLAG_DISABLE_IMAGE_PROCESSING = true;
              HEALTHCHECK_PATH = "/api/health";
            };
            extraPodmanArgs = [
              "--health-cmd node -e 'fetch(\"http://127.0.0.1:3000/api/health\").then((r) => { if (!r.ok) process.exit(1); }).catch(() => process.exit(1));'"
              "--health-interval 30s"
              "--health-timeout 10s"
              "--health-retries 3"
            ];
            volumes = [ "/run/media/dawn/cubus/reactive-resume/:/app/data" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          postgres = {
            image = "localhost/homemanager/postgres";
            userNS = "keep-id:uid=999,gid=999";
            volumes = [ "/run/media/dawn/cubus/postgres/:/var/lib/postgresql" ];
            environment = {
              POSTGRESQL_USERNAME = "postgres";
              POSTGRESQL_PASSWORD = "postgres";
            };
            extraPodmanArgs = [
              "--health-cmd 'pg_isready -U postgres -d postgres'"
              "--health-interval 10s"
              "--health-retries 5"
              "--health-timeout 5s"
            ];
            network = [ "admin" ];
            autoUpdate = "local";
          };
          pi-hole = {
            image = "docker.io/pihole/pihole:latest";
            volumes =
              let
                adlists = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts";
              in
              [
                "${builtins.toFile "adlists.list" adlists}:/etc/pihole/adlists.list"
              ];
            environment = {
              PORT = 80;
              inherit (lsio) TZ;
              FTLCONF_webserver_api_password = "admin";
              FTLCONF_dns_upstreams = "9.9.9.11;149.112.112.11";
              FTLCONF_dns_rateLimit_count = 0;
              FTLCONF_dns_rateLimit_interval = 0;
              FTLCONF_webserver_api_allow_destructive = false;
              FTLCONF_misc_readOnly = true;
            };
            extraPodmanArgs = [
              "--health-cmd 'dig +norecurse +retry=0 @127.0.0.1 pi.hole ' --hostname '${osConfig.networking.hostName}'"
            ];
            ip4 = "172.18.0.253";
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          photoprism = {
            # https://dl.photoprism.app/podman/docker-compose.yml
            image = "docker.io/photoprism/photoprism:latest";
            userNS = "keep-id:uid=999,gid=999";
            environment = {
              PORT = 2342;
              HEALTHCHECK_PATH = "/api/v1/status";
              PHOTOPRISM_AUTH_MODE = "public";
              PHOTOPRISM_SITE_URL = "https://photoprism.${secrets.dns}";
              PHOTOPRISM_DISABLE_TLS = true;
              PHOTOPRISM_DATABASE_SERVER = "mariadb:3306";
              PHOTOPRISM_DATABASE_NAME = "photoprism";
              PHOTOPRISM_DATABASE_USER = "photoprism";
              PHOTOPRISM_DATABASE_PASSWORD = "insecure";
              PHOTOPRISM_SITE_DESCRIPTION = "UwU";
              PHOTOPRISM_SITE_AUTHOR = "Aurore";
              PHOTOPRISM_DEFAULT_LOCALE = "fr";
              PHOTOPRISM_DEFAULT_TIMEZONE = lsio.TZ;
              PHOTOPRISM_FFMPEG_ENCODER = "intel";
              PHOTOPRISM_INIT = "intel";
            };
            devices = [
              "/dev/dri:/dev/dri"
            ];
            volumes = [
              "/run/media/dawn/bellum/Dawn/Images/DCIM/:/photoprism/originals:ro"
              "/run/media/dawn/cubus/photoprism/import/:/photoprism/import"
              "/run/media/dawn/cubus/photoprism:/photoprism/storage"
            ];
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:2342/api/v1/status '" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          mariadb = {
            image = "docker.io/library/mariadb:lts";
            userNS = "keep-id:uid=999,gid=999"; # https://github.com/eriksjolund/podman-detect-option
            volumes = [ "/run/media/dawn/cubus/mariadb:/var/lib/mysql" ];
            environment = {
              MARIADB_AUTO_UPGRADE = true;
              MARIADB_DATABASE = "photoprism";
              MARIADB_USER = "photoprism";
              MARIADB_PASSWORD = "insecure";
              MARIADB_ROOT_PASSWORD = "insecure";
            };
            extraPodmanArgs = [ "--health-cmd 'healthcheck.sh --connect --innodb_initialized'" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          redis = {
            image = "docker.io/library/redis:latest";
            userNS = "keep-id:uid=999,gid=999";
            volumes = [ "/run/media/dawn/cubus/redis:/data" ];
            environment = {
              ALLOW_EMPTY_PASSWORD = "yes";
            };
            extraPodmanArgs = [ "--health-cmd 'redis-cli ping '" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          paperless = {
            image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
            userNS = "keep-id:uid=999,gid=999";
            volumes = [
              "/run/media/dawn/cubus/paperless/data:/usr/src/paperless/data"
              "/run/media/dawn/cubus/paperless/media:/usr/src/paperless/media"
              "/run/media/dawn/cubus/paperless/export:/usr/src/paperless/export"
              "/run/media/dawn/cubus/paperless/consume:/usr/src/paperless/consume"
            ];
            environment = {
              PORT = 8000;
              USERMAP_UID = lsio.PUID;
              USERMAP_GID = lsio.PGID;
              PAPERLESS_TIME_ZONE = lsio.TZ;
              PAPERLESS_OCR_LANGUAGE = "fra";
              PAPERLESS_APP_TITLE = "Sans-papier";
              PAPERLESS_URL = "https://paperless.${secrets.dns}";
              PAPERLESS_REDIS = "redis://redis:6379";
              PAPERLESS_DBHOST = "postgres";
              PAPERLESS_DBUSER = "postgres";
              PAPERLESS_DBPASS = "postgres";
              PAPERLESS_SECRET_KEY = "RawcrzB37LUSUaxpdXxSLywHM3IxyXGZzqPvA-Blv83sh9iNM9qUaPd75sMEJur7DIiTdNWL3xOZsNN8a8cTLA";
            };
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          it-tools = {
            image = "docker.io/corentinth/it-tools:latest";
            environment.PORT = 80;
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          fileflows = {
            image = "docker.io/revenz/fileflows:stable";
            environment = {
              PORT = 5000;
            }
            // lsio;
            volumes = [
              "/run/media/dawn/cubus/fileflows/:/app/Data"
              "/run/media/dawn/cache/fileflows/:/temp"
              "/run/media/dawn/bellum/Multimédia/:/media"
            ];
            devices = [ "/dev/dri:/dev/dri" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          nextcloud = {
            image = "lscr.io/linuxserver/nextcloud:latest";
            userNS = "keep-id:uid=999,gid=999";
            environment = {
              PUID = 999;
              PGID = 999;
              inherit (lsio) TZ;
              PORT = 80;
              HEALTHCHECK_PATH = "/status.php";
            };
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:80/status.php '" ];
            volumes = [
              "/run/media/dawn/cubus/nextcloud/:/config"
              "/run/media/dawn/bellum/new_Music/:/data"
            ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          changedetection = {
            image = "lscr.io/linuxserver/changedetection.io:latest";
            environment = {
              PORT = 5000;
              LOGGER_LEVEL = "INFO";
              BASE_URL = "https://changedetection.${secrets.dns}";
            }
            // lsio;
            volumes = [ "/run/media/dawn/cubus/changedetection:/config" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          logseq = {
            image = "ghcr.io/logseq/logseq-webapp:latest";
            environment = {
              PORT = 80;
            };
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          scrutiny = {
            image = "ghcr.io/analogj/scrutiny:v${pkgs.scrutiny-collector.version}-web";
            environment = {
              PORT = 8080;
            };
            volumes = [
              "${
                builtins.toFile "scrutiny.json" (
                  builtins.toJSON {
                    web.influxdb = {
                      scheme = "http";
                      host = "influxdb";
                      port = 8086;
                    };
                    log.level = "WARN";
                  }
                )
              }:/opt/scrutiny/config/scrutiny.yaml:ro"
            ];
            ports = [ "127.0.0.1:8080:8080" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          influxdb = {
            image = "docker.io/library/influxdb:2";
            userNS = "keep-id:uid=999,gid=999";
            volumes = [ "/run/media/dawn/cubus/influxdb:/var/lib/influxdb2" ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          ramalama = {
            image = "quay.io/ramalama/ramalama:latest";
            devices = [ "/dev/dri:/dev/dri" ];
            volumes = [
              "${
                builtins.fetchurl {
                  url = "https://huggingface.co/unsloth/gemma-3-1b-it-GGUF/resolve/main/gemma-3-1b-it-IQ4_XS.gguf";
                  sha256 = "0sky8c3gghq78l68sv3l3g2brxlgdr243zdyy4s8mwh8xnjwb04z";
                }
              }:/mnt/models/gemma-3-1b-it-IQ4_XS.gguf"
            ];
            exec = "llama-server --host 0.0.0.0 -m /mnt/models/gemma-3-1b-it-IQ4_XS.gguf --no-warmup --alias unsloth/gemma-3-1b-it-GGUF --jinja -c 4096";
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          open-webui = {
            image = "ghcr.io/open-webui/open-webui:main";
            volumes = [ "/run/media/dawn/cubus/open-webui:/app/backend/data" ];
            environment = {
              PORT = 8080;
              DEFAULT_LOCALE = "fr";
              GLOBAL_LOG_LEVEL = "WARNING";
              OPENAI_API_BASE_URL = "http://ramalama:8080/v1"; # default port will be changed to :9931 in a future release https://github.com/ggml-org/llama.cpp/pull/26508
            };
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          llmfit = {
            image = "ghcr.io/alexsjones/llmfit:latest";
            exec = "serve --host 0.0.0.0 --port 8787";
            environment.PORT = 8787;
            extraPodmanArgs = [
              "--health-cmd 'curl -f http://localhost:8787/health '"
              "--health-interval 15s"
              "--health-timeout 5s"
              "--health-retries 3"
              "--health-start-period 10s"
            ];
            network = [ "admin" ];
            autoUpdate = "registry";
          };
          minecraft-server = {
            image = "docker.io/itzg/minecraft-server:java21-alpine";
            volumes = [
              "/run/media/dawn/cubus/minecraft-server:/data"
            ];
            environment = {
              EULA = "TRUE";
              DIFFICULTY = "easy";
              MODE = "survival";
              ONLINE_MODE = false;
              TYPE = "AUTO_CURSEFORGE";
              CF_PAGE_URL = "https://www.curseforge.com/minecraft/modpacks/all-the-mons/";
              CF_FILENAME_MATCHER = "1.3.0";
              RCON_CMDS_STARTUP = "gamerule keepInventory true\ngamerule mobGriefing false";
              MAX_MEMORY = "12G";
              USE_AIKAR_FLAGS = true;
              OPS = "Horror,Mogasdoor";
            };
            ip4 = "172.21.0.67";
            network = [ "minecraft" ];
            autoUpdate = "registry";
          };
        };
    };
  };
}
