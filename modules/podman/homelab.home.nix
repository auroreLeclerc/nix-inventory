{ osConfig, myLibs, ... }: {
	imports = [ ./podman.home.nix ./homer.home.nix ];
	config = {
		services.podman.containers = {
			wireguard = {
				image = "lscr.io/linuxserver/wireguard:latest";
				addCapabilities = [ "NET_ADMIN" ];
				environment = {
					PUID = 0;
					PGID = 0;
					TZ = "Europe/Paris";
					SERVERURL = "auto";
					PEERS = "fierceDeity,exelo,taya";
					PEERDNS = "172.18.0.20";
					PERSITENTKEEPALIVE_PEERS = "all";
					LOG_CONFS = false;
				};
				volumes = [ "/home/dawn/docker/wireguard/config:/config" ];
				ports = [ "51820:51820/udp" ];
				extraPodmanArgs = [
					"--sysctl net.ipv4.conf.all.src_valid_mark=1"
					"--sysctl net.ipv4.ip_forward=1"
				];
				network= ["docker-like"];
			};
			transmission = {
					image = "lscr.io/linuxserver/transmission:latest";
					environment = {
						PUID = 0;
						PGID = 0;
						TZ = "Europe/Paris";
					};
					volumes = [
						"/media/bellum/gohma/data:/config"
						"/media/bellum/gohma/downloads:/downloads"
						"/media/bellum/gohma/watchdir:/watch"
					];
					ip4 = "172.18.0.11";
				network= ["docker-like"];
			};
			sonarr = {
				image = "lscr.io/linuxserver/sonarr:latest";
				environment = {
					PUID = 0;
					PGID = 0;
					TZ = "Europe/Paris";
				};
				volumes = [
					"/home/dawn/docker/sonarr:/config"
					"/media/bellum/gohma/downloads:/downloads"
					"/media/bellum/main/Multimédia/Séries:/tv"
				];
				ip4 = "172.18.0.12";
				network= ["docker-like"];
			};
			radarr = {
				image = "lscr.io/linuxserver/radarr:latest";
				environment = {
					PUID = 0;
					PGID = 0;
					TZ = "Europe/Paris";
				};
				volumes = [
					"/home/dawn/docker/radarr:/config"
					"/media/bellum/gohma/downloads:/downloads"
					"/media/bellum/main/Multimédia/Films:/movies"
				];
				ip4 = "172.18.0.13";
				network= ["docker-like"];
			};
			jackett = {
				image = "lscr.io/linuxserver/jackett:latest";
				environment = {
					PUID = 0;
					PGID = 0;
					TZ = "Europe/Paris";
					AUTO_UPDATE = true;
				};
				volumes = [ "/home/dawn/docker/jackett:/config" ];
				ip4 = "172.18.0.14";
				network= ["docker-like"];
			};
			bazarr = {
				image = "lscr.io/linuxserver/bazarr:latest";
				environment = {
					PUID = 0;
					PGID = 0;
					TZ = "Europe/Paris";
				};
				volumes = [
					"/home/dawn/docker/bazarr:/config"
					"/media/bellum/main/Multimédia/Films:/movies"
					"/media/bellum/main/Multimédia/Séries:/tv"
				];
				ip4 = "172.18.0.15";
				network= ["docker-like"];
			};
			jellyfin = {
				image = "lscr.io/linuxserver/jellyfin:latest";
				environment = {
					PUID = 0;
					PGID = 0;
					TZ = "Europe/Paris";
					DOCKER_MODS = [
						"linuxserver/mods:jellyfin-amd"
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
				ip4 = "172.18.0.16";
				network= ["docker-like"];
			};
			lidarr = {
				image = "youegraillot/lidarr-on-steroids";
				environment = {
					PUID = 0;
					PGID = 0;
					TZ = "Europe/Paris";
				};
				volumes = [
					"/home/dawn/docker/lidarr:/config"
					"/media/bellum/main/new_Deezer:/music"
					"/media/bellum/main/new_Deezer:/downloads"
				];
				ip4 = "172.18.0.17";
				network= ["docker-like"];
			};
			nginx = {
				image = "lscr.io/linuxserver/nginx:latest";
				environment = {
					PUID = 0;
					PGID = 0;
					TZ = "Europe/Paris";
				};
				volumes = [ "/home/dawn/docker/nginx/config:/config" ];
				ip4 = "172.18.0.18";
				network= ["docker-like"];
			};
			proxy-manager = {
				image = "jc21/nginx-proxy-manager:latest";
				environment = {
					PUID = 0;
					PGID = 0;
				};
				volumes = [
					"/home/dawn/docker/proxy-manager/data:/data"
					"/home/dawn/docker/proxy-manager/letsencrypt:/etc/letsencrypt"
				];
				ip4 = "172.18.0.19";
				network= ["docker-like"];
			};
			pihole = {
				image = "pihole/pihole:latest";
				environment = {
					TZ = "Europe/Paris";
					FTLCONF_webserver_api_password = "";
					FTLCONF_dns_listeningMode = "all"; # If using Docker's default `bridge` network setting the dns listening mode should be set to 'all'
				};
				user = 0;
				ip4 = "172.18.0.20";
				network= ["docker-like"];
			};
			vaultwarden = {
				image = "vaultwarden/server:latest";
				environment = {
					PUID = 0;
					PGID = 0;
					DOMAIN = "https://vaultwarden.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
					SIGNUPS_ALLOWED = "false";
				};
				volumes = [ "/home/dawn/docker/vaultwarden/data:/data" ];
				ip4 = "172.18.0.21";
				network= ["docker-like"];
			};
			freshrss = {
				image = "freshrss/freshrss";
				environment = {
					TZ = "Europe/Paris";
					CRON_MIN = 0;
				};
				user = 0;
				volumes = [ "/home/dawn/docker/freshrss/:/var/www/FreshRSS/data" ];
				ip4 = "172.18.0.22";
				network= ["docker-like"];
			};
		};
	};
}