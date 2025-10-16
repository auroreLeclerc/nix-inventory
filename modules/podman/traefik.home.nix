{ config, osConfig, myLibs, ... }: {
	config = {
		services.podman.containers.traefik = let
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
				providers = {
					file.filename = "/etc/traefik/dynamic.yml";
					# docker.exposedbydefault = false;
				};
			};
			dynamicConfig = {
				http = {
					routers = builtins.mapAttrs (name: content: {
						entryPoints = [ "web" ];
						rule = "Host(`${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}`) && PathPrefix(`${name}`)";
						service = name;
						tls = {
							certResolver = "duckresolver";
							domains = [ {
								main = myLibs.impureSopsReading osConfig.sops.secrets.dns.path;
								# sans = [ "${name}.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}" ];
							} ];
						};
					}) (config.services.podman.containers);
					services = builtins.mapAttrs (name: content: {
						loadBalancer.servers = [ { url = "http://${content.ip4}:8080"; } ];
					}) (config.services.podman.containers);
				};
			};
		in {
			image = "docker.io/traefik:latest";
			volumes = [
				# "/run/user/1000/podman/podman.sock:/var/run/docker.sock"
				"/home/dawn/docker/traefik/letsencrypt:/letsencrypt"
				"${builtins.toFile "traefikConfig.json" (builtins.toJSON traefikConfig)}:/etc/traefik/traefik.yml"
				"${builtins.toFile "dynamicConfig.json" (builtins.toJSON dynamicConfig)}:/etc/traefik/dynamic.yml"
			];
			user = 0;
			environment = {
				DUCKDNS_TOKEN = myLibs.impureSopsReading osConfig.sops.secrets.duck.path;
			};
			ip4 = "172.18.0.27";
			network = [ "docker-like" ];
			autoUpdate = "registry";
		};
	};
}