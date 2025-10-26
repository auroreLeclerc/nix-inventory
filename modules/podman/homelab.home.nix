{ osConfig, config, myLibs, lib, ... }: {
	imports = [ ./podman.home.nix ];
	config = {
		services.podman = {
			containers = let
				traefikConfig = {
					api = {
						insecure = true;
						dashboard = true;
					};
					# log.level = "DEBUG";
					entrypoints = {
						web = {
							address = ":80";
							http.redirections.entryPoint = {
								to = "websecure";
								scheme = "https";
							};
						};
						websecure = {
							address = ":443";
							http.tls = true;
						};
					};
					certificatesresolvers.duckresolver.acme = {
						dnschallenge.provider = "duckdns";
						email = myLibs.impureSopsReading osConfig.sops.secrets.secondaryMail.path;
						storage = "/letsencrypt/acme.json";
						httpChallenge.entryPoint = "web";
					};
					providersfile.filename = "/etc/traefik/dynamic.yml";
				};
				dynamicConfig = {
					http = {
						routers = builtins.mapAttrs (name: _: {
							entryPoints = [ "web" ];
							rule = "Host(`${name}.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}`)";
							service = name;
							tls = {
								certResolver = "duckresolver";
								domains = [ {
									main = myLibs.impureSopsReading osConfig.sops.secrets.dns.path;
									sans = [ "${name}.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}" ];
								} ];
							};
						}) containers;
						services = builtins.mapAttrs (name: _: {
							loadBalancer.servers = [ { url = "http://${name}.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}"; } ];
						}) containers;
					};
				};
				containers = {
					wireguard = {
						image = "lscr.io/linuxserver/wireguard:latest";
						addCapabilities = [ "NET_ADMIN" ];
						environment = {
							SERVERURL = "auto";
							PEERS = "fierceDeity,exelo,taya";
							PEERDNS = config.services.podman.containers.adguardhome.ip4;
							PERSITENTKEEPALIVE_PEERS = "all";
							LOG_CONFS = false;
						};
						volumes = [ "/home/dawn/docker/wireguard/config:/config" ];
						ports = [ "51820:51820/udp" ];
						extraPodmanArgs = [
							"--sysctl net.ipv4.conf.all.src_valid_mark=1"
							"--sysctl net.ipv4.ip_forward=1"
						];
					};
					transmission = {
						image = "lscr.io/linuxserver/transmission:latest";
						volumes = [
							"/media/bellum/gohma/data:/config"
							"/media/bellum/gohma/downloads:/downloads"
							"/media/bellum/gohma/watchdir:/watch"
						];
					};
					sonarr = {
						image = "lscr.io/linuxserver/sonarr:latest";
						volumes = [
							"/home/dawn/docker/sonarr:/config"
							"/media/bellum/gohma/downloads:/downloads"
							"/media/bellum/main/Multimédia/Séries:/tv"
						];
					};
					radarr = {
						image = "lscr.io/linuxserver/radarr:latest";
						volumes = [
							"/home/dawn/docker/radarr:/config"
							"/media/bellum/gohma/downloads:/downloads"
							"/media/bellum/main/Multimédia/Films:/movies"
						];
					};
					jackett = {
						image = "lscr.io/linuxserver/jackett:latest";
						environment = {
							AUTO_UPDATE = true;
						};
						volumes = [ "/home/dawn/docker/jackett:/config" ];
					};
					bazarr = {
						image = "lscr.io/linuxserver/bazarr:latest";
						volumes = [
							"/home/dawn/docker/bazarr:/config"
							"/media/bellum/main/Multimédia/Films:/movies"
							"/media/bellum/main/Multimédia/Séries:/tv"
						];
					};
					jellyfin = {
						image = "lscr.io/linuxserver/jellyfin:latest";
						environment = {
							DOCKER_MODS = [
								"lscr.io/linuxserver/mods:jellyfin-amd"
								"ghcr.io/intro-skipper/intro-skipper-docker-mod"
							];
						};
						volumes = [
							"/media/bellum/main/Multimédia/Films:/data/movies"
							"/media/bellum/main/Multimédia/Séries:/data/tvshows"
							"/media/bellum/main/new_Deezer:/data/music"
							"/media/bellum/jellyfin:/config"
						];
						devices = [
							"/dev/dri:/dev/dri"
							"/dev/kfd:/dev/kfd"
						];
					};
					lidarr = {
						image = "docker.io/youegraillot/lidarr-on-steroids";
						volumes = [
							"/home/dawn/docker/lidarr:/config"
							"/media/bellum/main/new_Deezer:/music"
							"/media/bellum/main/new_Deezer:/downloads"
						];
					};
					vaultwarden = {
						image = "docker.io/vaultwarden/server:latest";
						environment = {
							DOMAIN = "https://vaultwarden.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
							SIGNUPS_ALLOWED = "false";
						};
						volumes = [ "/home/dawn/docker/vaultwarden/data:/data" ];
					};
					miniflux = {
						image = "docker.io/miniflux/miniflux:latest";
						environment = {
							DATABASE_URL = "postgres://postgres:postgres@${config.services.podman.containers.postgres.ip4}:5432/miniflux?sslmode=disable";
							RUN_MIGRATIONS = 1;
							CREATE_ADMIN = 1;
							ADMIN_USERNAME = "admin";
							ADMIN_PASSWORD = "adminadmin";
						};
					};
					minio = { # Storage (for image uploads)
						image = "docker.io/minio/minio:latest";
						exec = "server /data";
						environment = {
							MINIO_ROOT_USER = "minioadmin";
							MINIO_ROOT_PASSWORD = "minioadmin";
						};
					};
					chrome = { # Chrome Browser (for printing and previews)
						image = "ghcr.io/browserless/chromium:latest";
						environment = {
							TOKEN = "chrome_token";
							HEALTH = "true";
							PROXY_HOST = "chrome.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
							PROXY_PORT = 443;
							PROXY_SSL = "true";
						};
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
							DATABASE_URL = "postgresql://postgres:postgres@${config.services.podman.containers.postgres.ip4}:5432/resume";
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
					};
					postgres = {
						image = "localhost/homemanager/postgres";
						volumes = [ "/home/dawn/docker/postgres/:/var/lib/postgresql/data" ];
						environment = {
							POSTGRES_USER = "postgres";
							POSTGRES_PASSWORD = "postgres";
						};
						extraPodmanArgs = [
							"--health-cmd 'CMD-SHELL,pg_isready -U postgres -d postgres'"
							"--health-interval 10s"
							"--health-retries 5"
							"--health-timeout 5s"
						];
					};
					whoami = {
						image = "docker.io/traefik/whoami:latest";
					};
					traefik = {
						image = "docker.io/traefik:latest";
						volumes = [
							"/home/dawn/docker/traefik/letsencrypt:/letsencrypt"
							"${builtins.toFile "traefikConfig.json" (builtins.toJSON traefikConfig)}:/etc/traefik/traefik.yml"
							"${builtins.toFile "dynamicConfig.json" (builtins.toJSON dynamicConfig)}:/etc/traefik/dynamic.yml"
						];
						environment = {
							DUCKDNS_TOKEN = myLibs.impureSopsReading osConfig.sops.secrets.duck.path;
						};
					};
				};
			in builtins.listToAttrs (builtins.genList (i: 
				assert (i + 2) < 255;
			let 
				name = builtins.elemAt (builtins.attrNames containers) i;
				container = containers.${name};
			in {
				name = name;
				value = {
					image = container.image;
					exec = lib.mkIf (builtins.hasAttr "exec" container) container.exec;
					addCapabilities = lib.mkIf (builtins.hasAttr "addCapabilities" container) container.addCapabilities;
					environment = {
						PUID = 0;
						PGID = 0;
						TZ = "Europe/Paris";
					} // lib.mkIf (builtins.hasAttr "environment" container) container.environment;
					user = 0;
					group = 0;
					volumes = lib.mkIf (builtins.hasAttr "volumes" container) container.volumes;
					devices = lib.mkIf (builtins.hasAttr "devices" container) container.devices;
					ports = lib.mkIf (builtins.hasAttr "ports" container) container.ports;
					extraPodmanArgs = lib.mkIf (builtins.hasAttr "extraPodmanArgs" container) container.extraPodmanArgs;
					network = [ "docker-like" ];
					ip4 = "172.18.0.${builtins.toString (i + 2)}";
					autoUpdate = if (builtins.match "^localhost.*" container.image) == [] then "local" else "registry";
				};
			}) (builtins.length (builtins.attrNames containers)) );
		#{
		# 		wireguard = {
		# 			image = "lscr.io/linuxserver/wireguard:latest";
		# 			addCapabilities = [ "NET_ADMIN" ];
		# 			environment = {
		# 				PUID = 0;
		# 				PGID = 0;
		# 				TZ = "Europe/Paris";
		# 				SERVERURL = "auto";
		# 				PEERS = "fierceDeity,exelo,taya";
		# 				PEERDNS = "172.18.0.20";
		# 				PERSITENTKEEPALIVE_PEERS = "all";
		# 				LOG_CONFS = false;
		# 			};
		# 			volumes = [ "/home/dawn/docker/wireguard/config:/config" ];
		# 			ports = [ "51820:51820/udp" ];
		# 			extraPodmanArgs = [
		# 				"--sysctl net.ipv4.conf.all.src_valid_mark=1"
		# 				"--sysctl net.ipv4.ip_forward=1"
		# 			];
		# 			network = [ "docker-like" ];
		# 			# ip4 = "172.18.0.9";
		# 			autoUpdate = "registry";
		# 		};
		# 		transmission = {
		# 			image = "lscr.io/linuxserver/transmission:latest";
		# 			environment = {
		# 				PUID = 0;
		# 				PGID = 0;
		# 				TZ = "Europe/Paris";
		# 			};
		# 			volumes = [
		# 				"/media/bellum/gohma/data:/config"
		# 				"/media/bellum/gohma/downloads:/downloads"
		# 				"/media/bellum/gohma/watchdir:/watch"
		# 			];
		# 			ip4 = "172.18.0.11";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		sonarr = {
		# 			image = "lscr.io/linuxserver/sonarr:latest";
		# 			environment = {
		# 				PUID = 0;
		# 				PGID = 0;
		# 				TZ = "Europe/Paris";
		# 			};
		# 			volumes = [
		# 				"/home/dawn/docker/sonarr:/config"
		# 				"/media/bellum/gohma/downloads:/downloads"
		# 				"/media/bellum/main/Multimédia/Séries:/tv"
		# 			];
		# 			ip4 = "172.18.0.12";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		radarr = {
		# 			image = "lscr.io/linuxserver/radarr:latest";
		# 			environment = {
		# 				PUID = 0;
		# 				PGID = 0;
		# 				TZ = "Europe/Paris";
		# 			};
		# 			volumes = [
		# 				"/home/dawn/docker/radarr:/config"
		# 				"/media/bellum/gohma/downloads:/downloads"
		# 				"/media/bellum/main/Multimédia/Films:/movies"
		# 			];
		# 			ip4 = "172.18.0.13";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		jackett = {
		# 			image = "lscr.io/linuxserver/jackett:latest";
		# 			environment = {
		# 				PUID = 0;
		# 				PGID = 0;
		# 				TZ = "Europe/Paris";
		# 				AUTO_UPDATE = true;
		# 			};
		# 			volumes = [ "/home/dawn/docker/jackett:/config" ];
		# 			ip4 = "172.18.0.14";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		bazarr = {
		# 			image = "lscr.io/linuxserver/bazarr:latest";
		# 			environment = {
		# 				PUID = 0;
		# 				PGID = 0;
		# 				TZ = "Europe/Paris";
		# 			};
		# 			volumes = [
		# 				"/home/dawn/docker/bazarr:/config"
		# 				"/media/bellum/main/Multimédia/Films:/movies"
		# 				"/media/bellum/main/Multimédia/Séries:/tv"
		# 			];
		# 			ip4 = "172.18.0.15";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		jellyfin = {
		# 			image = "lscr.io/linuxserver/jellyfin:latest";
		# 			environment = {
		# 				PUID = 0;
		# 				PGID = 0;
		# 				TZ = "Europe/Paris";
		# 				DOCKER_MODS = [
		# 					"lscr.io/linuxserver/mods:jellyfin-amd"
		# 					"ghcr.io/intro-skipper/intro-skipper-docker-mod"
		# 				];
		# 			};
		# 			volumes = [
		# 				"/media/bellum/main/Multimédia/Films:/data/movies"
		# 				"/media/bellum/main/Multimédia/Séries:/data/tvshows"
		# 				"/media/bellum/main/new_Deezer:/data/music"
		# 				"/media/bellum/jellyfin:/config"
		# 			];
		# 			devices = [
		# 				"/dev/dri:/dev/dri"
		# 				"/dev/kfd:/dev/kfd"
		# 			];
		# 			ip4 = "172.18.0.16";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		lidarr = {
		# 			image = "docker.io/youegraillot/lidarr-on-steroids";
		# 			environment = {
		# 				PUID = 0;
		# 				PGID = 0;
		# 				TZ = "Europe/Paris";
		# 			};
		# 			volumes = [
		# 				"/home/dawn/docker/lidarr:/config"
		# 				"/media/bellum/main/new_Deezer:/music"
		# 				"/media/bellum/main/new_Deezer:/downloads"
		# 			];
		# 			ip4 = "172.18.0.17";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		# nginx = {
		# 		# 	image = "lscr.io/linuxserver/nginx:latest";
		# 		# 	environment = {
		# 		# 		PUID = 0;
		# 		# 		PGID = 0;
		# 		# 		TZ = "Europe/Paris";
		# 		# 	};
		# 		# 	volumes = [ "/home/dawn/docker/nginx/config:/config" ];
		# 		# 	ip4 = "172.18.0.18";
		# 		# 	network = [ "docker-like" ];
		# 		# 	autoUpdate = "registry";
		# 		# };
		# 		# proxy-manager = {
		# 		# 	image = "docker.io/jc21/nginx-proxy-manager:latest";
		# 		# 	environment = {
		# 		# 		PUID = 0;
		# 		# 		PGID = 0;
    #  		# 		DISABLE_IPV6 = true;
		# 		# 	};
		# 		# 	volumes = [
		# 		# 		"/home/dawn/docker/proxy-manager/data:/data"
		# 		# 		"/home/dawn/docker/proxy-manager/letsencrypt:/etc/letsencrypt"
		# 		# 	];
		# 		# 	ip4 = "172.18.0.19";
		# 		# 	network = [ "docker-like" ];
		# 		# 	autoUpdate = "registry";
		# 		# # };
		# 		# pihole = {
		# 		# 	image = "docker.io/pihole/pihole:latest";
		# 		# 	environment = {
		# 		# 		TZ = "Europe/Paris";
		# 		# 		FTLCONF_webserver_api_password = "";
		# 		# 		FTLCONF_dns_listeningMode = "all"; # If using Docker's default \\\"bridge\\\" network setting the dns listening mode should be set to 'all'
		# 		# 	};
		# 		# 	user = 0;
		# 		# 	ip4 = "172.18.0.20";
		# 		# 	network = [ "docker-like" ];
		# 		# 	autoUpdate = "registry";
		# 		# };
		# 		adguard = {
		# 			image = "docker.io/adguard/adguardhome:latest";
		# 			volumes = [
		# 				"/home/dawn/docker/adguard/work:/opt/adguardhome/work"
		# 				"/home/dawn/docker/adguard/conf:/opt/adguardhome/conf"
		# 				];
		# 			user = 0;
		# 			ip4 = "172.18.0.20";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		vaultwarden = {
		# 			image = "docker.io/vaultwarden/server:latest";
		# 			environment = {
		# 				PUID = 0;
		# 				PGID = 0;
		# 				DOMAIN = "https://vaultwarden.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
		# 				SIGNUPS_ALLOWED = "false";
		# 			};
		# 			volumes = [ "/home/dawn/docker/vaultwarden/data:/data" ];
		# 			ip4 = "172.18.0.21";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		miniflux = {
		# 			image = "docker.io/miniflux/miniflux:latest";
		# 			environment = {
		# 				DATABASE_URL = "postgres://postgres:postgres@${config.services.podman.containers.postgres.ip4}:5432/miniflux?sslmode=disable";
		# 				RUN_MIGRATIONS = 1;
		# 				CREATE_ADMIN = 1;
		# 				ADMIN_USERNAME = "admin";
		# 				ADMIN_PASSWORD = "adminadmin";
		# 			};
		# 			user = 0;
		# 			ip4 = "172.18.0.22";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		minio = { # Storage (for image uploads)
		# 			image = "docker.io/minio/minio:latest";
		# 			exec = "server /data";
		# 			environment = {
		# 				MINIO_ROOT_USER = "minioadmin";
		# 				MINIO_ROOT_PASSWORD = "minioadmin";
		# 			};
		# 			ip4 = "172.18.0.23";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		chrome = { # Chrome Browser (for printing and previews)
		# 			image = "ghcr.io/browserless/chromium:latest";
		# 			environment = {
		# 				TOKEN = "chrome_token";
    #   			HEALTH = "true";
		# 				PROXY_HOST = "chrome.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
		# 				PROXY_PORT = 443;
		# 				PROXY_SSL = "true";
		# 			};
		# 			ip4 = "172.18.0.24";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		reactive-resume = {
		# 			image = "docker.io/amruthpillai/reactive-resume:latest";
		# 			environment = {
		# 				PORT = 3000;
		# 				NODE_ENV = "production";
		# 				PUBLIC_URL = "https://reactive-resume.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
		# 				STORAGE_URL = "https://minio.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/default";
		# 				CHROME_TOKEN = "chrome_token";
		# 				CHROME_URL = "wss://chrome.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
		# 				DATABASE_URL = "postgresql://postgres:postgres@${config.services.podman.containers.postgres.ip4}:5432/resume";
		# 				ACCESS_TOKEN_SECRET = "access_token_secret";
		# 				REFRESH_TOKEN_SECRET = "refresh_token_secret";
		# 				MAIL_FROM = "noreply@localhost.gay";
		# 				STORAGE_ENDPOINT = "minio";
		# 				STORAGE_PORT = 9000;
		# 				STORAGE_BUCKET = "default";
		# 				STORAGE_ACCESS_KEY = "minioadmin";
		# 				STORAGE_SECRET_KEY = "minioadmin";
		# 				STORAGE_USE_SSL = false;
		# 				STORAGE_SKIP_BUCKET_CHECK = false;
		# 			};
		# 			ip4 = "172.18.0.25";
		# 			network = [ "docker-like" ];
		# 			autoUpdate = "registry";
		# 		};
		# 		postgres = {
		# 			image = "localhost/homemanager/postgres";
		# 			volumes = [ "/home/dawn/docker/postgres/:/var/lib/postgresql/data" ];
		# 			user = 0;
		# 			environment = {
		# 				POSTGRES_USER = "postgres";
		# 				POSTGRES_PASSWORD = "postgres";
		# 			};
		# 			extraPodmanArgs = [
		# 				"--health-cmd 'CMD-SHELL,pg_isready -U postgres -d postgres'"
		# 				"--health-interval 10s"
		# 				"--health-retries 5"
		# 				"--health-timeout 5s"
		# 			];
		# 			network = [ "docker-like" ];
		# 			ip4 = "172.18.0.26";
		# 			autoUpdate = "local";
		# 		};
		# 	};
		};
	};
}