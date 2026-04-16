{
  osConfig,
  config,
  ...
}:
let
  secrets = osConfig.secrets.values;
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
      settings.storage.storage = {
        driver = "overlay";
        rootless_storage_path = "/run/media/dawn/cache/podman";
      };
      containers =
        let
          lsio = {
            PUID = 1000;
            PGID = 0;
            TZ = "Europe/Paris";
          };
        in
        {
          wireguard = {
            image = "lscr.io/linuxserver/wireguard:latest";
            addCapabilities = [ "NET_ADMIN" ];
            environment = {
              SERVERURL = secrets.ip;
              PEERS = "exelo,taya,fdeity";
              PEERDNS = config.services.podman.containers.pihole.ip4;
              PERSITENTKEEPALIVE_PEERS = "all";
              LOG_CONFS = false;
            }
            // lsio;
            volumes = [ "/run/media/dawn/cubus/wireguard/:/config" ];
            ports = [ "51820:51820/udp" ];
            extraPodmanArgs = [
              "--sysctl net.ipv4.conf.all.src_valid_mark=1"
              "--sysctl net.ipv4.ip_forward=1"
            ];
            network = [ "docker-like" ];
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
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          sonarr = {
            image = "lscr.io/linuxserver/sonarr:latest";
            environment = {
              PORT = 8989;
              HEALTHCHECK_PATH = "/ping";
              SONARR__AUTH__METHOD = "External";
              SONARR__AUTH__APIKEY = osConfig.secrets.values.sonarr;
            }
            // lsio;
            volumes = [
              "/run/media/dawn/cubus/sonarr:/config"
              "/run/media/dawn/eox/downloads:/downloads"
              "/run/media/dawn/bellum/Multimédia/Séries:/tv"
            ];
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:8989/ping '" ];
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          radarr = {
            image = "lscr.io/linuxserver/radarr:latest";
            environment = {
              PORT = 7878;
              HEALTHCHECK_PATH = "/ping";
              RADARR__AUTH__METHOD = "External";
              RADARR__AUTH__APIKEY = osConfig.secrets.values.radarr;
            }
            // lsio;
            volumes = [
              "/run/media/dawn/cubus/radarr:/config"
              "/run/media/dawn/eox/downloads:/downloads"
              "/run/media/dawn/bellum/Multimédia/Films:/movies"
            ];
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:7878/ping '" ];
            network = [ "docker-like" ];
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
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          prowlarr = {
            image = "lscr.io/linuxserver/prowlarr:latest";
            environment = {
              PORT = 9696;
              HEALTHCHECK_PATH = "/ping";
              PROWLARR__AUTH__METHOD = "External";
              PROWLARR__AUTH__APIKEY = osConfig.secrets.values.prowlarr;
            }
            // lsio;
            extraPodmanArgs = [
              "--dns ${config.services.podman.containers.pihole.ip4}"
              "--health-cmd 'curl -f http://localhost:9696/ping '"
            ];
            volumes = [ "/run/media/dawn/cubus/prowlarr:/config" ];
            network = [ "docker-like" ];
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
            network = [ "docker-like" ];
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
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          jellyfin = {
            image = "lscr.io/linuxserver/jellyfin:latest";
            environment = {
              PORT = 8096;
              HEALTHCHECK_PATH = "/health";
              DOCKER_MODS = [
                # "linuxserver/mods:jellyfin-amd"
                "linuxserver/mods:jellyfin-opencl-intel"
                "ghcr.io/intro-skipper/intro-skipper-docker-mod"
              ];
            }
            // lsio;
            volumes = [
              "/run/media/dawn/bellum/Multimédia/Films:/data/movies:ro"
              "/run/media/dawn/bellum/Multimédia/Séries:/data/tvshows:ro"
              "/run/media/dawn/bellum/new_Deezer:/data/music:ro"
              "/run/media/dawn/cubus/jellyfin:/config"
              "/run/media/dawn/cache/jellyfin:/config/cache"
            ];
            devices = [ "/dev/dri:/dev/dri" ];
            extraPodmanArgs = [ "--health-cmd 'curl -i http://jellyfin:8096/health'" ];
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          lidarr = {
            image = "lscr.io/linuxserver/lidarr:nightly";
            environment = {
              PORT = 8686;
              HEALTHCHECK_PATH = "/ping";
              LIDARR__AUTH__METHOD = "External";
              LIDARR__AUTH__APIKEY = osConfig.secrets.values.lidarr;
            }
            // lsio;
            volumes = [
              "/run/media/dawn/cubus/lidarr:/config"
              "/run/media/dawn/bellum/new_Music:/music"
              "/run/media/dawn/eox/downloads:/downloads"
            ];
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:8686/ping '" ];
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          yubal = {
            image = "ghcr.io/guillevc/yubal:latest";
            user = 1000;
            group = 0;
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
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          vaultwarden = {
            image = "docker.io/vaultwarden/server:latest";
            environment = {
              PORT = 80;
              HEALTHCHECK_PATH = "/alive";
              DOMAIN = "https://vaultwarden.${secrets.dns}/";
              SIGNUPS_ALLOWED = "false";
            };
            volumes = [ "/run/media/dawn/cubus/vaultwarden/data:/data" ];
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:80/alive '" ];
            network = [ "docker-like" ];
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
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          printer = {
            image = "ghcr.io/browserless/chromium:latest";
            environment = {
              PORT = 3000;
              HEALTH = true;
              CONCURRENT = 20;
              QUEUED = 10;
            };
            extraPodmanArgs = [
              "--health-cmd 'curl -f http://localhost:3000/pressure'"
              "--health-interval 10s"
              "--health-retries 5"
              "--health-timeout 5s"
            ];
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          reactive-resume = {
            image = "docker.io/amruthpillai/reactive-resume:latest";
            user = 1000;
            group = 0;
            environment = {
              PORT = 3000;
              inherit (lsio) TZ;
              APP_URL = "https://reactive-resume.${secrets.dns}";
              AUTH_SECRET = "";
              PRINTER_ENDPOINT = "ws://printer:3000";
              DATABASE_URL = "postgresql://postgres:postgres@postgres:5432/resume";
            };
            extraPodmanArgs = [
              "--health-cmd 'curl -f http://localhost:3000/api/health'"
              "--health-interval 10s"
              "--health-retries 5"
              "--health-timeout 5s"
            ];
            volumes = [ "/run/media/dawn/cubus/reactive-resume/:/app/data" ];
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          postgres = {
            image = "docker.io/bitnami/postgresql:latest";
            user = 1000;
            group = 0;
            volumes = [
              "/run/media/dawn/cubus/postgres/:/bitnami/postgresql"
              "${./init-db.sql}:/docker-entrypoint-initdb.d/init-db.sql:ro"
            ];
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
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          pihole = {
            image = "docker.io/pihole/pihole:latest";
            volumes =
              let
                adlists = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
              in
              [
                "${builtins.toFile "adlists.list" adlists}:/etc/pihole/adlists.list"
              ];
            environment = {
              PORT = 80;
              inherit (lsio) TZ;
              FTLCONF_webserver_api_password = "";
              FTLCONF_dns_listeningMode = "all";
              FTLCONF_dns_upstreams = "9.9.9.11;149.112.112.11";
            };
            extraPodmanArgs = [ "--health-cmd 'dig +norecurse +retry=0 @127.0.0.1 pi.hole '" ];
            ip4 = "172.18.0.253";
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          photoprism = {
            # https://dl.photoprism.app/podman/docker-compose.yml
            image = "docker.io/photoprism/photoprism:latest";
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
              PHOTOPRISM_FFMPEG_ENCODER = "vaapi";
            };
            devices = [
              "/dev/dri:/dev/dri"
              "/dev/kfd:/dev/kfd"
            ];
            volumes = [
              "/run/media/dawn/bellum/Dawn/Images/DCIM/:/photoprism/originals:ro"
              "/run/media/dawn/cubus/photoprism/import/:/photoprism/import"
              "/run/media/dawn/cubus/photoprism:/photoprism/storage"
            ];
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:2342/api/v1/status '" ];
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          mariadb = {
            image = "docker.io/bitnami/mariadb:latest";
            user = 1000;
            group = 0;
            volumes = [ "/run/media/dawn/cubus/mariadb:/bitnami/mariadb" ];
            environment = {
              MARIADB_DATABASE = "photoprism";
              MARIADB_USER = "photoprism";
              MARIADB_PASSWORD = "insecure";
              MARIADB_ROOT_PASSWORD = "insecure";
            };
            extraPodmanArgs = [ "--health-cmd 'healthcheck.sh --connect --innodb_initialized'" ];
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          redis = {
            image = "docker.io/bitnami/redis:latest";
            user = 1000;
            group = 0;
            volumes = [ "/run/media/dawn/cubus/redis:/bitnami/redis/data" ];
            environment = {
              ALLOW_EMPTY_PASSWORD = "yes";
            };
            extraPodmanArgs = [ "--health-cmd 'redis-cli ping '" ];
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          paperless = {
            image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
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
            };
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          it-tools = {
            image = "docker.io/corentinth/it-tools:latest";
            environment.PORT = 80;
            network = [ "docker-like" ];
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
              "/run/media/dawn/slowcache/:/temp"
              "/run/media/dawn/bellum/Multimédia/:/media"
            ];
            devices = [ "/dev/dri:/dev/dri" ];
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          nextcloud = {
            image = "lscr.io/linuxserver/nextcloud:latest";
            environment = {
              PORT = 80;
              HEALTHCHECK_PATH = "/status.php";
            }
            // lsio;
            extraPodmanArgs = [ "--health-cmd 'curl -f http://localhost:80/status.php '" ];
            volumes = [
              "/run/media/dawn/cubus/nextcloud/:/config"
              "/run/media/dawn/bellum/new_Music/:/data"
            ];
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
          changedetection = {
            image = "lscr.io/linuxserver/changedetection.io:latest";
            environment = {
              PORT = 5000;
              LOGGER_LEVEL = "INFO";
              BASE_URL = "https://changedetection.${secrets.dns}";
            };
            volumes = [ "/run/media/dawn/cubus/changedetection:/config" ];
            network = [ "docker-like" ];
            autoUpdate = "registry";
          };
        };
    };
  };
}
