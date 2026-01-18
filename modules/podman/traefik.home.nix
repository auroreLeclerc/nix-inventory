{ config, osConfig, myLibs, lib, ... }: {
	config.services.podman.containers = let
		debug = false;
	in {
		whoami = lib.mkIf debug {
			image = "docker.io/traefik/whoami:latest";
			environment.PORT = 80;
			network = [ "docker-like" ];
			autoUpdate = "registry";
		};
		traefik = {
			image = "docker.io/library/traefik:latest";
			volumes = let
				traefikConfig = {
					log.level = "INFO";
					api = {
						dashboard = true;
						insecure = true;
						disabledashboardad = true;
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
							propagation.delaybeforechecks = 120;
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
								status = [ "400-404" "500-599" ]; # transmission needs 409 untouch
								service = "error-handler";
								query = "/{status}";
							};
							cors-handler.headers = {
								accessControlAllowMethods = [ "GET" "HEAD" "OPTIONS" ];
								accessControlAllowHeaders = "*";
								accessControlAllowOriginList = "*";
								accessControlMaxAge = 100;
								addVaryHeader = true;
							}; 
						};
						routers = builtins.mapAttrs (name: container: if (builtins.hasAttr "PORT" container.environment) then {
							rule = "Host(`${name}.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}`)";
							entryPoints = [ "websecure" ];
							service = name;
							middlewares = [ "cors-handler" "error-handler" ];
						} else null) config.services.podman.containers;
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
				"/run/media/dawn/cubus/traefik/letsencrypt:/letsencrypt"
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
				PORT = lib.mkIf debug 8080;
				TEMPLATE_NAME = "connection";
			};
			network = [ "docker-like" ];
			autoUpdate = "registry";
		};
	};
}