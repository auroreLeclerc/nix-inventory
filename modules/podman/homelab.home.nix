{ osConfig, config, myLibs, ... }: {
	imports = [ ./podman.home.nix ./homer.home.nix ./traefik.home.nix ];
	config = {
		services.podman = {
			containers = let 
				lscr = {
					PUID = 0;
					PGID = 0;
					TZ = "Europe/Paris";
				};
			in {
				wireguard = {
					image = "lscr.io/linuxserver/wireguard:latest";
					addCapabilities = [ "NET_ADMIN" ];
					environment = {
						SERVERURL = myLibs.impureSopsReading osConfig.sops.secrets.ip.path;
						PEERS = "exelo,taya";
						PEERDNS = config.services.podman.containers.pihole.ip4;
						PERSITENTKEEPALIVE_PEERS = "all";
						LOG_CONFS = false;
					} // lscr;
					volumes = [ "/media/bellum/main/docker/wireguard/:/config" ];
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
					} // lscr;
					volumes = [
						"/run/media/dawn/blaaz/data:/config"
						"/run/media/dawn/blaaz/downloads:/downloads"
						"/run/media/dawn/blaaz/watchdir:/watch"
					];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				sonarr = {
					image = "lscr.io/linuxserver/sonarr:latest";
					environment = {
						PORT = 8989;
					} // lscr;
					volumes = [
						"/media/bellum/main/docker/sonarr:/config"
						"/run/media/dawn/blaaz/downloads:/downloads"
						"/media/bellum/main/Multimédia/Séries:/tv"
					];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				radarr = {
					image = "lscr.io/linuxserver/radarr:latest";
					environment = {
						PORT = 7878;
					} // lscr;
					volumes = [
						"/media/bellum/main/docker/radarr:/config"
						"/run/media/dawn/blaaz/downloads:/downloads"
						"/media/bellum/main/Multimédia/Films:/movies"
					];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				jackett = {
					image = "lscr.io/linuxserver/jackett:latest";
					environment = {
						PORT = 9117;
						AUTO_UPDATE = true;
					} // lscr;
					volumes = [ "/media/bellum/main/docker/jackett:/config" ];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				bazarr = {
					image = "lscr.io/linuxserver/bazarr:latest";
					environment = {
						PORT = 6767;
					} // lscr;
					volumes = [
						"/media/bellum/main/docker/bazarr:/config"
						"/media/bellum/main/Multimédia/Films:/movies"
						"/media/bellum/main/Multimédia/Séries:/tv"
					];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				jellyfin = {
					image = "lscr.io/linuxserver/jellyfin:latest";
					environment = {
						PORT = 8096;
						DOCKER_MODS = [
							"lscr.io/linuxserver/mods:jellyfin-amd"
							"ghcr.io/intro-skipper/intro-skipper-docker-mod"
						];
					} // lscr;
					volumes = [
						"/media/bellum/main/Multimédia/Films:/data/movies:ro"
						"/media/bellum/main/Multimédia/Séries:/data/tvshows:ro"
						"/media/bellum/main/new_Deezer:/data/music:ro"
						"/run/media/dawn/cache/jellyfin:/config/cache"
						"/media/bellum/main/docker/jellyfin:/config"
					];
					devices = [
						"/dev/dri:/dev/dri"
						"/dev/kfd:/dev/kfd"
					];
					extraPodmanArgs = [ "--health-cmd 'curl -i http://jellyfin:8096/health'" ];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				lidarr = {
					image = "docker.io/youegraillot/lidarr-on-steroids";
					environment = {
						PORT = 8686;
					} // lscr;
					volumes = [
						"/media/bellum/main/docker/lidarr:/config"
						"/media/bellum/main/new_Deezer:/music"
						"/media/bellum/main/new_Deezer:/downloads"
					];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				vaultwarden = {
					image = "docker.io/vaultwarden/server:latest";
					environment = {
						PORT = 80;
						DOMAIN = "https://vaultwarden.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
						SIGNUPS_ALLOWED = "false";
					};
					volumes = [ "/media/bellum/main/docker/vaultwarden/data:/data" ];
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
      			BASE_URL = "https://miniflux.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
					};
					extraPodmanArgs = [ "--health-cmd '/usr/bin/miniflux -healthcheck auto'" ];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				minio = { # Storage (for image uploads)
					image = "docker.io/minio/minio:latest";
					exec = "server /data";
					environment = {
						PORT = 9000;
						MINIO_ROOT_USER = "minioadmin";
						MINIO_ROOT_PASSWORD = "minioadmin";
					};
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				chrome = { # Chrome Browser (for printing and previews)
					image = "ghcr.io/browserless/chromium:latest";
					environment = {
						PORT = 443;
						TOKEN = "chrome_token";
						HEALTH = "true";
						PROXY_HOST = "chrome.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						PROXY_PORT = 443;
						PROXY_SSL = "true";
					};
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				reactive-resume = {
					image = "docker.io/amruthpillai/reactive-resume:latest";
					environment = {
						PORT = 3000;
						NODE_ENV = "production";
						PUBLIC_URL = "https://reactive-resume.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						STORAGE_URL = "https://minio.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/default";
						CHROME_TOKEN = "chrome_token";
						CHROME_URL = "wss://chrome.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						DATABASE_URL = "postgresql://postgres:postgres@postgre:5432/resume";
						ACCESS_TOKEN_SECRET = "access_token_secret";
						REFRESH_TOKEN_SECRET = "refresh_token_secret";
						MAIL_FROM = "noreply@localhost.gay";
						STORAGE_ENDPOINT = "minio";
						STORAGE_PORT = 9000;
						STORAGE_BUCKET = "default";
						STORAGE_ACCESS_KEY = "minioadmin";
						STORAGE_SECRET_KEY = "minioadmin";
						STORAGE_USE_SSL = false;
						STORAGE_SKIP_BUCKET_CHECK = false;
					};
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				postgres = {
					image = "localhost/homemanager/postgres";
					volumes = [ "/media/bellum/main/docker/postgres/:/var/lib/postgresql" ];
					environment = {
						POSTGRES_PASSWORD = "postgres";
					};
					extraPodmanArgs = [
						"--userns keep-id:uid=999,gid=999" # https://github.com/eriksjolund/podman-detect-option
						"--health-cmd 'pg_isready -U postgres -d postgres'"
						"--health-interval 10s"
						"--health-retries 5"
						"--health-timeout 5s"
					];
					network = [ "docker-like" ];
					autoUpdate = "local";
				};
				pihole = {
					image = "docker.io/pihole/pihole:latest";
					volumes = let 
						adlists = ''https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts'';
					in [
						"${builtins.toFile "adlists.list" adlists}:/etc/pihole/adlists.list"
					];
					environment = {
						PORT = 80;
						TZ = lscr.TZ;
						FTLCONF_webserver_api_password = "";
						FTLCONF_dns_listeningMode = "all";
						FTLCONF_dns_upstreams = "9.9.9.10;149.112.112.10;2620:fe::10;2620:fe::fe:10";
					};
					ip4 = "172.18.0.253";
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				photoprism = { # https://dl.photoprism.app/podman/docker-compose.yml
					image = "docker.io/photoprism/photoprism:latest";
					environment = {
						PORT = 2342;
						PHOTOPRISM_AUTH_MODE = "public";
						PHOTOPRISM_SITE_URL = "https://photoprism.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						PHOTOPRISM_DISABLE_TLS = true;
						PHOTOPRISM_READONLY = true;
						PHOTOPRISM_DATABASE_SERVER = "mariadb:3306";
						PHOTOPRISM_DATABASE_NAME = "photoprism";
						PHOTOPRISM_DATABASE_USER = "photoprism";
						PHOTOPRISM_DATABASE_PASSWORD = "insecure";
						PHOTOPRISM_SITE_DESCRIPTION = "UwU";
						PHOTOPRISM_SITE_AUTHOR = "Aurore";
						PHOTOPRISM_DEFAULT_LOCALE = "fr";
						PHOTOPRISM_DEFAULT_TIMEZONE = lscr.TZ;
					};
					devices = [
						"/dev/dri:/dev/dri"
						"/dev/kfd:/dev/kfd"
					];
					volumes = [
						"/media/bellum/main/Dawn/Images/DCIM/:/photoprism/originals:ro"
						"/media/bellum/main/docker/photoprism/import/:/photoprism/import"
						"/media/bellum/main/docker/photoprism:/photoprism/storage"
					];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				mariadb = {
					image = "docker.io/library/mariadb:lts";
					volumes = [ "/media/bellum/main/docker/mariadb:/var/lib/mysql" ];
					environment = {
						MARIADB_AUTO_UPGRADE = true;
						MARIADB_DATABASE = "photoprism";
						MARIADB_USER = "photoprism";
						MARIADB_PASSWORD = "insecure";
						MARIADB_ROOT_PASSWORD = "insecure";
					};
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				redis = {
					image = "docker.io/library/redis:8";
					volumes = [ "/media/bellum/main/docker/redis:/data" ];
					extraPodmanArgs = [
						"--userns keep-id:uid=999,gid=999" # https://github.com/eriksjolund/podman-detect-option
					];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				paperless = {
					image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
					volumes = [
						"/media/bellum/main/docker/paperless/data:/usr/src/paperless/data"
						"/media/bellum/main/docker/paperless/media:/usr/src/paperless/media"
						"/media/bellum/main/docker/paperless/export:/usr/src/paperless/export"
						"/media/bellum/main/docker/paperless/consume:/usr/src/paperless/consume"
					];
					environment = {
						PORT = 8000;
						USERMAP_UID = lscr.PUID;
						USERMAP_GID = lscr.PGID;
						PAPERLESS_TIME_ZONE = lscr.TZ;
						PAPERLESS_OCR_LANGUAGE = "fra";
						PAPERLESS_APP_TITLE = "Sans-papier";
						PAPERLESS_URL = "https://paperless.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
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
  			tdarr = {
    			image = "ghcr.io/haveagitgat/tdarr:latest";
					environment = {
						PORT = 8265;
						serverURL = "https://tdarr.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						inContainer = true;
						auth = false;
					} // lscr;
					volumes = [
						"/media/bellum/main/docker/tdarr/server:/app/server"
						"/media/bellum/main/docker/tdarr/configs:/app/configs"
						"/media/bellum/main/docker/tdarr/logs:/app/logs"
						"/media/bellum/main/Multimédia:/media:ro"
						"/run/media/dawn/cache/tdarr/:/temp"
					];
					devices = [
						"/dev/dri:/dev/dri"
						"/dev/kfd:/dev/kfd"
					];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
			};
		};
	};
}