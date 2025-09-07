{ myLibs, osConfig, ... }: {
	 config.services.podman.containers = let
		homerConfig = {
			title = "App dashboard";
			subtitle = "UwU";
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
				light.background-image = "assets/light.png";
				dark.background-image = "assets/dark.png";
			};
			services = [
				{
					name = "Homelab";
					icon = "fas fa-code-branch";
					items = [
						{
							name = "Jellyfin";
							logo = "assets/jellyfin.svg";
							type = "Jellyfin";
							apikey = myLibs.impureSopsReading osConfig.sops.secrets.jellyfin.path;
							url = "https://jellyfin.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						}	{
							name = "Transmission";
							logo = "assets/transmission.png";
							url = "https://transmission.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
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
							name = "Jackett";
							logo = "assets/jackett.png";
							url = "https://jackett.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						}	{
							name = "Bazarr";
							logo = "assets/bazarr.png";
							url = "https://bazarr.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						}	{
							name = "Nginx";
							logo = "assets/nginx.png";
							url = "https://nginx.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						}	{
							name = "Proxy Manager";
							logo = "assets/proxy.svg";
							url = "https://proxy-manager.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						}	{
							name = "Pi-hole";
							logo = "assets/pi.svg";
							type = "PiHole";
							# apikey = myLibs.impureSopsReading osConfig.sops.secrets.pihole.path;
							url = "https://pihole.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/admin";
						}	{
							name = "Vaultwarden - Server";
							logo = "assets/vaultwarden.svg";
							type = "Vaultwarden";
							url = "https://vaultwarden.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
						}	{
							name = "FreshRSS";
							logo = "assets/freshrss.svg";
							type = "FreshRSS";
							url = "https://freshrss.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
							username = "admin";
							password = "admin";
							updateInterval = 5000;
						}
					];
				}	{
				name = "Workbench";
				icon = "fas fa-heartbeat";
				items = [
					{
						name = "Reactive Resume";
						logo = "assets/resume.svg";
						url = "http://localhost:3000/";
					} {
						name = "Deemix";
						logo = "assets/deemix.svg";
						url = "http://localhost:6595/";
					}
				];
			}
		];
	};
	in {
		homer = {
			image = "b4bz/homer";
			volumes = [
				"${ builtins.toFile "homerConfig" (builtins.toJSON homerConfig)}:/www/assets/config.yml"
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
					url = "https://raw.githubusercontent.com/NginxProxyManager/nginx-proxy-manager/refs/heads/develop/docs/src/public/logo.svg";
					sha256 = "sha256-Hp5XU/e4hSXYcM9+Y94GZzFmZqE/0Ob0CFcLj7kFc84=";
				}}:/www/assets/proxy.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/pi-hole/web/refs/heads/master/img/logo.svg";
					sha256 = "sha256-xYQy+/XuOdWv2Ntg/7vURhBYHnF5PUCPbMFfz5AEYpw=";
				}}:/www/assets/pi.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/dani-garcia/vaultwarden/refs/heads/main/resources/vaultwarden-icon.svg";
					sha256 = "sha256-xY/pFVS9puG+Ub0M9WrISrY/eY1Rc+QeceGqHeUVx+8=";
				}}:/www/assets/vaultwarden.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/FreshRSS/FreshRSS/refs/heads/edge/p/themes/icons/icon.svg";
					sha256 = "sha256-pn8nvgp2gGCT48YxdtZ/Gwq7Na0syRpqRsA5Rv1e+qI=";
				}}:/www/assets/freshrss.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/AmruthPillai/Reactive-Resume/refs/heads/main/apps/artboard/public/favicon.svg";
					sha256 = "sha256-NEhDw6TbcHvveQxDNFHKSrEudatpoYVGu0LR/lX5D3c=";
				}}:/www/assets/resume.svg"
				"${builtins.fetchurl {
					url = "https://raw.githubusercontent.com/bambanah/deemix/refs/heads/main/packages/webui/src/client/assets/deemix-icon.svg";
					sha256 = "sha256-9fjm/zWvZWEyI2Zj4FdbtkBmdsFR/7VH+62e9KrpRcA=";
				}}:/www/assets/deemix.svg"
			];
			environment = {
				INIT_ASSETS = 0;
			};
			ip4 = "172.18.0.10";
			network= ["docker-like"];
		};
	};
}