{ osConfig, config, myLibs, ... }: {
	imports = [ ./podman.home.nix ./homer.home.nix ./traefik.home.nix ];
	config = {
		services.podman = {
			settings.storage.storage = {
				driver = "overlay";
				rootless_storage_path = "/run/media/dawn/cache/podman";
			};
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
						PEERS = "exelo,taya,fdeity";
						PEERDNS = config.services.podman.containers.pihole.ip4;
						PERSITENTKEEPALIVE_PEERS = "all";
						LOG_CONFS = false;
					} // lscr;
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
					} // lscr;
					volumes = [
						"/run/media/dawn/cubus/transmission:/config"
						"/run/media/dawn/eox/downloads:/downloads"
						"/run/media/dawn/eox/watchdir:/watch"
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
						"/run/media/dawn/cubus/sonarr:/config"
						"/run/media/dawn/eox/downloads:/downloads"
						"/run/media/dawn/bellum/Multimédia/Séries:/tv"
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
						"/run/media/dawn/cubus/radarr:/config"
						"/run/media/dawn/eox/downloads:/downloads"
						"/run/media/dawn/bellum/Multimédia/Films:/movies"
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
					volumes = [ "/run/media/dawn/cubus/jackett:/config" ];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				prowlarr = {
					image = "lscr.io/linuxserver/prowlarr:latest";
					environment = {
						PORT = 9696;
					} // lscr;
					volumes = [ "/run/media/dawn/cubus/prowlarr:/config" ];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				bazarr = {
					image = "lscr.io/linuxserver/bazarr:latest";
					environment = {
						PORT = 6767;
					} // lscr;
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
						DOCKER_MODS = [
							# "linuxserver/mods:jellyfin-amd"
							"linuxserver/mods:jellyfin-opencl-intel"
							"ghcr.io/intro-skipper/intro-skipper-docker-mod"
						];
					} // lscr;
					volumes = [
						"/run/media/dawn/bellum/Multimédia/Films:/data/movies:ro"
						"/run/media/dawn/bellum/Multimédia/Séries:/data/tvshows:ro"
						"/run/media/dawn/bellum/new_Deezer:/data/music:ro"
						"/run/media/dawn/cubus/jellyfin:/config"
						"/run/media/dawn/cache/jellyfin:/config/cache"
					];
					devices = [ "/dev/dri:/dev/dri"	];
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
						"/run/media/dawn/cubus/lidarr:/config"
						"/run/media/dawn/bellum/new_Deezer:/music"
						"/run/media/dawn/bellum/new_Deezer:/downloads"
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
					volumes = [ "/run/media/dawn/cubus/vaultwarden/data:/data" ];
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
					volumes = [ "/run/media/dawn/cubus/postgres/:/var/lib/postgresql" ];
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
						PHOTOPRISM_DATABASE_SERVER = "mariadb:3306";
						PHOTOPRISM_DATABASE_NAME = "photoprism";
						PHOTOPRISM_DATABASE_USER = "photoprism";
						PHOTOPRISM_DATABASE_PASSWORD = "insecure";
						PHOTOPRISM_SITE_DESCRIPTION = "UwU";
						PHOTOPRISM_SITE_AUTHOR = "Aurore";
						PHOTOPRISM_DEFAULT_LOCALE = "fr";
						PHOTOPRISM_DEFAULT_TIMEZONE = lscr.TZ;
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
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				mariadb = {
					image = "docker.io/library/mariadb:lts";
					volumes = [ "/run/media/dawn/cubus/mariadb:/var/lib/mysql" ];
					environment = {
						MARIADB_AUTO_UPGRADE = true;
						MARIADB_DATABASE = "photoprism";
						MARIADB_USER = "photoprism";
						MARIADB_PASSWORD = "insecure";
						MARIADB_ROOT_PASSWORD = "insecure";
					};
					extraPodmanArgs = [
						"--userns keep-id:uid=999,gid=999" # https://github.com/eriksjolund/podman-detect-option
					];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				redis = {
					image = "docker.io/library/redis:8";
					volumes = [ "/run/media/dawn/cubus/redis:/data" ];
					extraPodmanArgs = [
						"--userns keep-id:uid=999,gid=999" # https://github.com/eriksjolund/podman-detect-option
					];
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
				fileflows = {
					image = "docker.io/revenz/fileflows:stable";
					environment = {
						PORT = 5000;
					} // lscr;
					volumes = [
						"/run/media/dawn/cubus/fileflows/:/app/Data"
						"/run/media/dawn/cache/fileflows/:/temp"
						"/run/media/dawn/bellum/Multimédia/test/:/media"
					];
					devices = [ "/dev/dri:/dev/dri" ];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
			};
		};
	};
}