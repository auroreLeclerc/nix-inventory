{ myLibs, osConfig, ... }: {
	config.services.podman.containers = let
		homerConfig = {
			title = "Laboratoire Maison";
			subtitle = "OwO";
			icon = "fas fa-dragon";
			header = true;
			footer = false;
			columns = "auto";
			connectivityCheck = true;
			defaults = {
				layout = "columns";
				colorTheme = "auto";
			};
			theme = "neon";
			colors = {
				light.background-image = "/assets/light.png";
				dark.background-image = "/assets/dark.png";
			};
			services = [
				{
					name = "Administration";
					icon = "fas fa-hammer";
					items = let
						piholeEndpoint = "https://pihole.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
					in [
						{
							name = "Transmission";
							logo = "assets/transmission.png";
  						type = "Transmission";
							url = "https://transmission.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						} {
							name = "Jackett";
							logo = "assets/jackett.png";
							url = "https://jackett.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						} {
							name = "Traefik";
							logo = "assets/traefik.svg";
  						type = "Traefik";
							url = "https://traefik.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						}	{
							name = "Pi-hole";
							logo = "assets/pi.svg";
							type = "PiHole";
							endpoint = piholeEndpoint;
							apiVersion = 6;
							url = "${piholeEndpoint}/admin";
						}	{
							name = "Vaultwarden - Server";
							logo = "assets/vaultwarden.svg";
							type = "Vaultwarden";
							url = "https://vaultwarden.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
						}
					];
				}	{
					name = "Multimédia";
					icon = "fas fa-clapperboard";
					items = [
						{
							name = "Jellyfin";
							logo = "assets/jellyfin.svg";
							type = "Emby";
							apikey = myLibs.impureSopsReading osConfig.sops.secrets.jellyfin.path;
							url = "https://jellyfin.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
							libraryType = "series";
						}	{
							name = "Radarr";
							logo = "assets/radarr.svg";
							type = "Radarr";
							apikey = myLibs.impureSopsReading osConfig.sops.secrets.radarr.path;
							url = "https://radarr.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						}	{
							name = "Sonarr";
							logo = "assets/sonarr.svg";
							type = "Sonarr";
							apikey = myLibs.impureSopsReading osConfig.sops.secrets.sonarr.path;
							url = "https://sonarr.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						}	{
							name = "Lidarr";
							logo = "assets/lidarr.svg";
							type = "Lidarr";
							apikey = myLibs.impureSopsReading osConfig.sops.secrets.lidarr.path;
							url = "https://lidarr.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						}	{
							name = "Deemix";
							logo = "assets/deemix.svg";
							url = "http://localhost:6595/";
						} {
							name = "Bazarr";
							logo = "assets/bazarr.png";
							url = "https://bazarr.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						}	
					];
				} {
					name = "Documents";
					icon = "fas fa-briefcase";
					items = [
						{
							name = "Reactive Resume";
							logo = "assets/resume.svg";
							url = "https://reactive-resume.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						}	{
							name = "Miniflux";
  						type = "Miniflux";
							logo = "assets/miniflux.svg";
							url = "https://miniflux.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
						}	{
							name = "Photoprism";
							logo = "assets/photoprism.svg";
							url = "https://photoprism.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
						}	{
							name = "Paperless";
							logo = "assets/paperless.svg";
							type = "PaperlessNG";
							apikey = "<---insert-api-key-here--->";
							url = "https://paperless.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
						} {
							name = "IT-Tools";
							logo = "assets/it-tools.svg";
							url = "https://it-tools.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
						}
					];
				}
			];
		};
	in {
		homer = {
			image = "docker.io/b4bz/homer:latest";
			volumes = [
				"${builtins.toFile "homerConfig.json" (builtins.toJSON homerConfig)}:/www/assets/config.yml"
				"${builtins.fetchurl {
					url = "https://xenia-images.efi.pages.gay/chimmie_egg-wallpaper_light.png";
					sha256 = "sha256-sEwFNdWClC1I3mc49EgJHSQJ4j1eAqReKQNOE+mZRus=";
				}}:/www/assets/light.png"
				"${builtins.fetchurl {
					url = "https://xenia-images.efi.pages.gay/chimmie_egg-wallpaper_dark.png";
					sha256 = "sha256-XXLFsFyULzshW7FA09swQHzFkVp2W0YXrSGXncv+66Y=";
				}}:/www/assets/dark.png"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/jellyfin/jellyfin-ux/refs/heads/master/branding/SVG/icon-transparent.svg";
					sha256 = "sha256-gXwltHRCsZIlBEj+SM1fJl/pGDvHWqEgMLvjNUlSVdE=";
				}}:/www/assets/jellyfin.svg"
				"${builtins.fetchurl {
					url = "https://transmissionbt.com/assets/images/Transmission_icon.png";
					sha256 = "sha256-zGsbzhZPGzmlceJTE7NvhGcat933Hq78+v1cRAblcmE=";
				}}:/www/assets/transmission.png"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/Radarr/Radarr/refs/heads/develop/Logo/Radarr.svg";
					sha256 = "sha256-rZwdLjTtfQPn3SiKEuSfai9fXR1JF2vz+/0vSpx9wME=";
				}}:/www/assets/radarr.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/Sonarr/Sonarr/refs/heads/v5-develop/Logo/Sonarr.svg";
					sha256 = "sha256-51sYu/L2YniCFEN+R7rPY5NnYjHO3a4y5tAs/6vFDHU=";
				}}:/www/assets/sonarr.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/Lidarr/Lidarr/refs/heads/develop/Logo/Lidarr.svg";
					sha256 = "sha256-IWVWk7rM1taRafVCnXyjYL4xeWzDQ2JKy1eHUetjn8c=";
				}}:/www/assets/lidarr.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/linuxserver/docker-templates/refs/heads/master/linuxserver.io/img/jacket-icon.png";
					sha256 = "sha256-meOHrn7w088jXGGXiDM5NrmI3oR61LGVe5DPrxeoMAE=";
				}}:/www/assets/jackett.png"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/linuxserver/docker-templates/refs/heads/master/linuxserver.io/img/bazarr-logo.png";
					sha256 = "sha256-29v0BEQHdemkkB7H3q6fG7faS0KawvOZK/Ld6XN/8/k=";
				}}:/www/assets/bazarr.png"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/linuxserver/docker-templates/refs/heads/master/linuxserver.io/img/nginx-logo.png";
					sha256 = "sha256-hewoVqgtHEBlGr6cI1/6AUTJnsJSWA/s5yTAzAbYaMg=";
				}}:/www/assets/nginx.png"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/traefik/traefik/refs/heads/master/docs/content/assets/img/traefikproxy-icon-color.png";
					sha256 = "sha256-GEWtfkxKSI/QZIw0jPozwAwSkqZn9vnZNcr9OHWloBA=";
				}}:/www/assets/traefik.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/pi-hole/web/refs/heads/master/img/logo.svg";
					sha256 = "sha256-xYQy+/XuOdWv2Ntg/7vURhBYHnF5PUCPbMFfz5AEYpw=";
				}}:/www/assets/pi.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/dani-garcia/vaultwarden/refs/heads/main/resources/vaultwarden-icon.svg";
					sha256 = "sha256-xY/pFVS9puG+Ub0M9WrISrY/eY1Rc+QeceGqHeUVx+8=";
				}}:/www/assets/vaultwarden.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/miniflux/website/refs/heads/main/static/logo/icon_bg_white.svg";
					sha256 = "sha256-j5glb/1FMilIOO9p///A/WAfcYXH6on6OzDJUtFbKlY=";
				}}:/www/assets/miniflux.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/AmruthPillai/Reactive-Resume/refs/heads/main/apps/artboard/public/favicon.svg";
					sha256 = "sha256-NEhDw6TbcHvveQxDNFHKSrEudatpoYVGu0LR/lX5D3c=";
				}}:/www/assets/resume.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/bambanah/deemix/refs/heads/main/packages/webui/src/client/assets/deemix-icon.svg";
					sha256 = "sha256-9fjm/zWvZWEyI2Zj4FdbtkBmdsFR/7VH+62e9KrpRcA=";
				}}:/www/assets/deemix.svg"
				"${builtins.fetchurl {
					url = "https://www.photoprism.app/static/icons/logo.svg";
					sha256 = "sha256-QWaJiZgQ7HXgpi8NO3zfLHylmeV3J/rX66LkkDGH1qA=";
				}}:/www/assets/photoprism.svg"	
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/paperless-ngx/paperless-ngx/refs/heads/dev/resources/logo/web/svg/square.svg";
					sha256 = "sha256-yr3c21EUv/pYhfS0N/efeyZUwgLEBaW6betIU+1yLyg=";
				}}:/www/assets/paperless.svg"	
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/CorentinTh/it-tools/refs/heads/main/public/safari-pinned-tab.svg";
					sha256 = "sha256-2ehrE3XcBR95E0S6EibxfkU7F67sCt9gCw1r0kB45sU=";
				}}:/www/assets/it-tools.svg"	
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