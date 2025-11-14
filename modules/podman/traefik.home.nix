{ config, osConfig, myLibs, ... }: {
	config.services.podman.containers.traefik = {
		image = "docker.io/traefik:latest";
		volumes = let
			traefikConfig = {
				log.level = "INFO";
				api.dashboard = true;
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
						http.tls = {
							certResolver = "duckresolver";
							domains = [{
								main = myLibs.impureSopsReading osConfig.sops.secrets.dns.path;
								sans = "*.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
							}];
						};
					};
				};
				# serversTransport.insecureSkipVerify = true;
				certificatesresolvers.duckresolver.acme = {
					dnschallenge = {
						provider = "duckdns";
						propagation = {
							# disableChecks = true;
							delaybeforechecks = 120;
						};
					};
					email = myLibs.impureSopsReading osConfig.sops.secrets.secondaryMail.path;
					storage = "/letsencrypt/acme.json";
				};
				providers.file.filename = "/etc/traefik/dynamic.yml";
			};
			dynamicConfig = {
				http = {
					middlewares = {
						errors-config = {
							errors = {
								service = "error-handler";
								query = "/{status}.html";
							};
						};
					};
					routers = builtins.mapAttrs (name: container: if ((builtins.hasAttr "environment" container) && (builtins.hasAttr "PORT" container)) then {
						rule = "Host(`${name}.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}`)";
						entryPoints = [ "websecure" ];
						service = name;
					} else null) config.services.podman.containers;
					services = (builtins.mapAttrs (name: container: if ((builtins.hasAttr "environment" container) && (builtins.hasAttr "PORT" container)) then {
						loadBalancer.servers = [
							{ url = "http://${name}:${builtins.toString container.environment.PORT}"; }
						];
					} else null) config.services.podman.containers) // {
						error-handler.loadBalancer.servers = [ { url = "https://http.cat/"; } ];
					};
				};
			};
		in [
			"/home/dawn/docker/traefik/letsencrypt:/letsencrypt"
			"${builtins.toFile "traefikConfig.json" (builtins.toJSON traefikConfig)}:/etc/traefik/traefik.yml"
			"${builtins.toFile "dynamicConfig.json" (builtins.toJSON dynamicConfig)}:/etc/traefik/dynamic.yml"
		];
		environment = {
			PORT = 443;
			DUCKDNS_TOKEN = myLibs.impureSopsReading osConfig.sops.secrets.duck.path;
		};
		network = [ "docker-like" ];
		autoUpdate = "registry";
	};
}