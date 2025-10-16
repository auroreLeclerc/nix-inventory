{ osConfig, myLibs, ... }: {
	config = {
		services.podman.containers.traefik = let
			traefikConfig = {
				api = {
					insecure = true;
					# dashboard = true;
				};
				providers.docker.exposedbydefault=false;
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
				};
				observability = {
					accessLogs = false;
					metrics = false;
					tracing = false;
				};
			};
		in {
			image = "docker.io/traefik:latest";
			volumes = [
				# "/run/user/1000/podman/podman.sock:/var/run/docker.sock"
				"/home/dawn/docker/traefik/letsencrypt:/letsencrypt"
				"${builtins.toFile "traefikConfig.json" (builtins.toJSON traefikConfig)}:/etc/traefik/traefik.yml"
			];
			user = 0;
			environment = {
				DUCKDNS_TOKEN = myLibs.impureSopsReading osConfig.sops.secrets.duck.path;
			};
			labels = {
				traefik.enable = true;
				traefik.http.routers.traefik.rule = "Host(`traefik.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}`)";
				traefik.http.routers.traefik.entrypoints = "web";
			};
			ip4 = "172.18.0.27";
			network = [ "docker-like" ];
			autoUpdate = "registry";
		};
	};
}