{ config, osConfig, myLibs, ... }: {
	config.services.podman.containers = {
		traefik = {
			image = "docker.io/library/traefik:latest";
			volumes = let
				traefikConfig = {
					log.level = "INFO";
					api = {
						dashboard = true;
						insecure = true;
					};
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
							error-handler.errors = {
								status = [ "300-599" ];
								service = "error-handler";
								query = "/{status}";
							};
							cors-handler.headers = {
								accessControlAllowMethods = [ "GET" "OPTIONS" ];
								accessControlAllowHeaders = "*";
								accessControlAllowOriginList = let
									keys = builtins.attrNames config.services.podman.containers;
								in builtins.genList (i :
									"${builtins.elemAt keys i}.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}"
								) (builtins.length keys);
								accessControlMaxAge = 100;
								addVaryHeader = true;
							}; 
						};
						routers = (builtins.mapAttrs (name: container: if (builtins.hasAttr "PORT" container.environment) then {
							rule = "Host(`${name}.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}`)";
							entryPoints = [ "websecure" ];
							service = name;
							middlewares = [ "cors-handler" "error-handler" ];
						} else null) config.services.podman.containers);
						services = (builtins.mapAttrs (name: container: if (builtins.hasAttr "PORT" container.environment) then {
							loadBalancer.servers = [
								{ url = "http://${name}:${builtins.toString container.environment.PORT}"; }
							];
						} else null) config.services.podman.containers) // {
							error-handler.loadBalancer.servers = [ { url = "http://error-pages:8080"; } ]; # static
						};
					};
				};
			in [
				"/home/dawn/docker/traefik/letsencrypt:/letsencrypt"
				"${builtins.toFile "traefikConfig.json" (builtins.toJSON traefikConfig)}:/etc/traefik/traefik.yml"
				"${builtins.toFile "dynamicConfig.json" (builtins.toJSON dynamicConfig)}:/etc/traefik/dynamic.yml"
			];
			environment = {
				PORT = 8080;
				DUCKDNS_TOKEN = myLibs.impureSopsReading osConfig.sops.secrets.duck.path;
			};
			ip4 = "172.18.0.254"; # IMPORTANT: the ip of the domain's dns must be traefik's ip !
			network = [ "docker-like" ];
			autoUpdate = "registry";
		};
		error-pages = {
			image = "ghcr.io/tarampampam/error-pages:3";
			environment = {
				PORT = 8080;
				TEMPLATE_NAME = "hacker-terminal";
			};
			network = [ "docker-like" ];
			autoUpdate = "registry";
		};
	};
}