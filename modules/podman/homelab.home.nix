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
					volumes = [ "/home/dawn/docker/wireguard/:/config" ];
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
						"/media/bellum/gohma/data:/config"
						"/media/bellum/gohma/downloads:/downloads"
						"/media/bellum/gohma/watchdir:/watch"
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
						"/home/dawn/docker/sonarr:/config"
						"/media/bellum/gohma/downloads:/downloads"
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
						"/home/dawn/docker/radarr:/config"
						"/media/bellum/gohma/downloads:/downloads"
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
					volumes = [ "/home/dawn/docker/jackett:/config" ];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				bazarr = {
					image = "lscr.io/linuxserver/bazarr:latest";
					environment = {
						PORT = 6767;
					} // lscr;
					volumes = [
						"/home/dawn/docker/bazarr:/config"
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
						"/media/bellum/jellyfin:/config"
					];
					devices = [
						"/dev/dri:/dev/dri"
						"/dev/kfd:/dev/kfd"
					];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				lidarr = {
					image = "docker.io/youegraillot/lidarr-on-steroids";
					environment.PORT = 6595;
					volumes = [
						"/home/dawn/docker/lidarr:/config"
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
					volumes = [ "/home/dawn/docker/vaultwarden/data:/data" ];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				miniflux = {
					image = "docker.io/miniflux/miniflux:latest";
					environment = {
						DATABASE_URL = "postgres://postgres:postgres@postgre:5432/miniflux?sslmode=disable";
						RUN_MIGRATIONS = 1;
						CREATE_ADMIN = 1;
						ADMIN_USERNAME = "admin";
						ADMIN_PASSWORD = "adminadmin";
					};
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
					volumes = [
						"/etc/passwd:/etc/passwd:ro"
						"/home/dawn/docker/postgres/:/var/lib/postgresql"
					];
					environment = {
						POSTGRES_PASSWORD = "postgres";
					};
					extraPodmanArgs = [
						"--user 1000:1000" # https://github.com/docker-library/docs/blob/master/postgres/README.md#arbitrary---user-notes
						"--health-cmd 'CMD-SHELL,pg_isready -U postgres -d postgres'"
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
						TZ = "Europe/Paris";
						FTLCONF_webserver_api_password = "";
						FTLCONF_dns_listeningMode = "all";
						FTLCONF_dns_upstreams = "9.9.9.10;149.112.112.10;2620:fe::10;2620:fe::fe:10";
					};
					ip4 = "172.18.0.3";
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				whoami = {
					image = "docker.io/traefik/whoami:latest";
					environment.PORT = 80;
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				imnot = {
					image = "docker.io/traefik/whoami:latest";
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
			};
			# in builtins.mapAttrs (name: container: {
			# 	name = name;
			# 	value = {
			# 		image = container.image;
			# 		exec = lib.mkIf (builtins.hasAttr "exec" container) container.exec;
			# 		addCapabilities = lib.mkIf (builtins.hasAttr "addCapabilities" container) container.addCapabilities;
			# 		environment = {
			# 			PUID = 0;
			# 			PGID = 0;
			# 			TZ = "Europe/Paris";
			# 		} // (if (builtins.hasAttr "environment" container) then container.environment else {});
			# 		volumes = lib.mkIf (builtins.hasAttr "volumes" container) container.volumes;
			# 		devices = lib.mkIf (builtins.hasAttr "devices" container) container.devices;
			# 		ports = lib.mkIf (builtins.hasAttr "ports" container) container.ports;
			# 		extraPodmanArgs = lib.mkIf (builtins.hasAttr "extraPodmanArgs" container) container.extraPodmanArgs;
			# 		network = [ "docker-like" ];
			# 		autoUpdate = if (builtins.match "^localhost.*" container.image) == [] then "local" else "registry";
			# 	};
			# }) containers;
		};
	};
}