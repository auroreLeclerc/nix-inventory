{ ... }: {
	imports = [ ./podman.home.nix ];
	config = {
		services.podman = {
			volumes = {
				minio_data = {};
				postgres_data = {};
				ttrss_data = {};
				deemix_data = {};
			};
			containers = {
				deemix = {
					image = "ghcr.io/bambanah/deemix:latest";
					ports = [ "6595:6595" ];
					volumes = [
						"deemix_data:/config"
						"/home/dawn/Musique/Deezer:/downloads"
					];
					environment = {
						PUID = 0;
						PGID = 0;
					};
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				ollama = {
					image = "docker.io/ollama/ollama:rocm";
					ports = [ "11434:11434" ];
					devices = [
						"/dev/dri:/dev/dri"
						"/dev/kfd:/dev/kfd"
					];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
				open-webui = {
					image = "ghcr.io/open-webui/open-webui:main";
					ports = [ "3001:8080" ];
					network = [ "docker-like" ];
					autoUpdate = "registry";
				};
			};
		};
	};
}