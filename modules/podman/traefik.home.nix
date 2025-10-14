{ osConfig, config, myLibs, ... }: {
	config = {
		services.podman.traefik = let
			traefikConfig = {
				api = {
					insecure = true;
					# dashboard = true;
				};
				providers.docker.exposedbydefault=false;
				entrypoints = {
					web.address = ":80";
					websecure.address = ":443";
					websecure.http.tls = true;
				};
				certificatesresolvers.duckresolver.acme = {
					dnschallenge.provider = "duckdns";
					email = myLibs.impureSopsReading osConfig.sops.secrets.secondaryMail.path;
					storage = /letsencrypt/acme.json;
				};

			};
		in {
			image = "docker.io/doijanky/traefik:latest";
			volumes = [
				"/run/user/1000/podman/podman.sock:/var/run/docker.sock"
				"${builtins.toFile "traefikConfig.json" (builtins.toJSON traefikConfig)}:/etc/traefik/traefik.yml"
			];
			user = 0;
			environment = {
				DUCKDNS_TOKEN = myLibs.impureSopsReading osConfig.sops.secrets.duck.path;
			};
			ports = [
				"80:80"
				"443:443"
				"3002:8080"
			];
			network = [ "docker-like" ];
			autoUpdate = "registry";
		};
	};
}