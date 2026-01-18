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
							logo = "assets/transmission.svg";
  						type = "Transmission";
							url = "https://transmission.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						} {
							name = "Jackett";
							logo = "assets/jackett.svg";
							url = "https://jackett.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						} {
							name = "Prowlarr";
							logo = "assets/prowlarr.svg";
							type = "Prowlarr";
							apikey = myLibs.impureSopsReading osConfig.sops.secrets.prowlarr.path;
							url = "https://prowlarr.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
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
						} {
							name = "FileFlows";
							logo = "assets/fileflows.svg";
							url = "https://fileflows.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
						}	{
							name = "Deemix";
							logo = "assets/deemix.svg";
							url = "http://localhost:6595/";
						} {
							name = "Bazarr";
							logo = "assets/bazarr.svg";
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
  						apikey = myLibs.impureSopsReading osConfig.sops.secrets.miniflux.path;
							url = "https://miniflux.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
						}	{
							name = "Photoprism";
							logo = "assets/photoprism.svg";
							url = "https://photoprism.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}/";
						}	{
							name = "Paperless";
							logo = "assets/paperless.svg";
							type = "PaperlessNG";
							apikey = myLibs.impureSopsReading osConfig.sops.secrets.paperless.path;
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
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellyfin.svg";
					sha256 = "sha256-f1PPCD27MRnsjFrL2AScUDMidhfkYVQPcFkawQkSQwY=";
				}}:/www/assets/jellyfin.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/transmission.svg";
					sha256 = "sha256-+DTKLQAq/r6M2l1QBRJ5fU+5clatOM3qHJOupCK4dN4=";
				}}:/www/assets/transmission.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/radarr.svg";
					sha256 = "sha256-w9B+zfq0MsqX8mzwH+Btv8CZO1y2CTgns94cdCGm+5U=";
				}}:/www/assets/radarr.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sonarr.svg";
					sha256 = "sha256-pd6+VlKB6xa3RtdbnOcuIvL7FcGbT1VCj99iuEvnkwY=";
				}}:/www/assets/sonarr.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/lidarr.svg";
					sha256 = "sha256-L1X2lFCgygNiHodVDoHsD2eYxKV4tU5LmIqacjSoNkc==";
				}}:/www/assets/lidarr.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jackett.svg";
					sha256 = "sha256-tDCcmamBUUWNOoOviXcJBLrGk+GVC6XEv/Q45VfAjrg=";
				}}:/www/assets/jackett.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/prowlarr.svg";
					sha256 = "0rxwym371bkybg55gsabwj5dpscnbwhdgm2r7s2ssl35xyy3cxyd";
				}}:/www/assets/prowlarr.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/bazarr.svg";
					sha256 = "sha256-tCd37mIt34Ws4V2+mnDUcaLKNk50XHPqRn2joKdYYWI=";
				}}:/www/assets/bazarr.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nginx.svg";
					sha256 = "sha256-OGDw05nkj8qjDysh081eDWkyZxQPHijLLTQZgauNL0w=";
				}}:/www/assets/nginx.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/traefik-proxy.svg";
					sha256 = "sha256-ufA9hQ1pSuNmNkMcZc3jzo/pxr+WFDU6B2H0PWXO7l8=";
				}}:/www/assets/traefik.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pi-hole.svg";
					sha256 = "sha256-RJRONKcheXwycc/GsV3/gc1vu/ZsfJbaU6NO05vgbqU=";
				}}:/www/assets/pi.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/vaultwarden.svg";
					sha256 = "sha256-r6OvcjtN5/UC0syWI1KEKly0ECa7WUCp+XDLUnG5Rys=";
				}}:/www/assets/vaultwarden.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/miniflux.svg";
					sha256 = "sha256-EyAyRYpTOhRFHYw6EIovyYMF6AT8TschgxvoZ3vQqLU=";
				}}:/www/assets/miniflux.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/reactive-resume.svg";
					sha256 = "sha256-EuhtOleP7Pim3OFP0ymqkbyDZAVXVUHcqFi31gTVZLI==";
				}}:/www/assets/resume.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/deezer.svg";
					sha256 = "sha256-0End70IeMHnSXZ4sPjowZAAAgvj1QnKtrY5VD0Gk5cE=";
				}}:/www/assets/deemix.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/photoprism.svg";
					sha256 = "sha256-caAQMpjc7zzoyifC0zdb2AgE95Yu/nSEggWUS9zF8AE=";
				}}:/www/assets/photoprism.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/paperless-ngx.svg";
					sha256 = "sha256-rD9pCxUb3xTha+vqUnIReLN/9hmGYKEljslEXq+yuNA=";
				}}:/www/assets/paperless.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/it-tools.svg";
					sha256 = "sha256-8pBo65DI9D1oUX6YJZzRoKY+q3S765KtR9YrpH3YGTA=";
				}}:/www/assets/it-tools.svg"
				"${builtins.fetchurl {
					url = "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/fileflows.svg";
					sha256 = "sha256-G6O5PLpMRwVS5GSOs0EBAFqI0jBdzTbszQVnhL7xVh4=";
				}}:/www/assets/fileflows.svg"
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