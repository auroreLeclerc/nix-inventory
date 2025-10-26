{ pkgs, osConfig, lib, myLibs, config, ... }: {
	config = {
		home.packages = lib.mkIf osConfig.services.desktopManager.plasma6.enable (with pkgs; [ podman-desktop podman-compose ]);
		services.podman = {
			enable = true;
			autoUpdate = {
				enable = true;
				onCalendar = "*-*-* 04:30:00";
			};
			networks.docker-like = {
				description = "Docker compatibilty (internal DNS resolution)";
				driver = "bridge";
				subnet = "172.18.0.0/24";
				gateway = config.services.podman.containers.adguardhome.ip4;
				extraPodmanArgs = [
					"--dns=${config.services.podman.containers.adguardhome.ip4}"
				];
			};
			builds = {
				postgres = {
					file = builtins.toFile "PostgresContainerfile" 
					''
						FROM docker.io/pgautoupgrade/pgautoupgrade:latest
						COPY ${builtins.baseNameOf (builtins.toFile "init-db.sql" (builtins.readFile ./init-db.sql))} /docker-entrypoint-initdb.d/
					'';
				};
				adguardhome = let
					adguardHomeConfig = {
						http = {
							address = "${config.services.podman.containers.adguardhome.ip4}:80";
						};
						users = []; # If set to an empty list, authentication is disabled.
						language = "fr";
						theme = "auto";
						dns = {
							bind_hosts = [
								"${config.services.podman.containers.adguardhome.ip4}"
							];
							port = 53;
							upstream_dns = [
								"https://dns10.quad9.net/dns-query"
							];
							# upstream_dns_file = "";
							bootstrap_dns = [
								"9.9.9.10"
								"149.112.112.10"
								"2620:fe::10"
								"2620:fe::fe:10"
							];
							# fallback_dns = [];
							# upstream_mode = "load_balance";
							# fastest_timeout = "1s";
							# allowed_clients = [];
							# disallowed_clients = [];
							# blocked_hosts = [
							# 	"version.bind"
							# 	"id.server"
							# 	"hostname.bind"
							# ];
							# trusted_proxies = [
							# 	"127.0.0.0/8"
							# 	"::1/128"
							# ];
						};
						# tls = {
						# 	enabled = false;
						# 	server_name = "";
						# 	force_https = false;
						# 	port_https = 443;
						# 	port_dns_over_tls = 853;
						# 	port_dns_over_quic = 853;
						# 	port_dnscrypt = 0;
						# 	dnscrypt_config_file = "";
						# 	allow_unencrypted_doh = false;
						# 	certificate_chain = "";
						# 	private_key = "";
						# 	certificate_path = "";
						# 	private_key_path = "";
						# 	strict_sni_check = false;
						# };
						# querylog = {
						# 	dir_path = "";
						# 	ignored = [];
						# 	interval = "2160h";
						# 	size_memory = 1000;
						# 	enabled = true;
						# 	file_enabled = true;
						# };
						# statistics = {
						# 	dir_path = "";
						# 	ignored = [];
						# 	interval = "24h";
						# 	enabled = true;
						# };
						filters = [
							{
								enabled = true;
								url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
								name = "AdGuard DNS filter";
								id = 1;
							} {
								enabled = true;
								url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
								name = "AdAway Default Blocklist";
								id = 2;
							}
						];
						# whitelist_filters = [];
						# user_rules = [];
						# dhcp = {
						# 	enabled = false;
						# 	interface_name = "";
						# 	local_domain_name = "lan";
						# 	dhcpv4 = {
						# 		gateway_ip = "";
						# 		subnet_mask = "";
						# 		range_start = "";
						# 		range_end = "";
						# 		lease_duration = 86400;
						# 		icmp_timeout_msec = 1000;
						# 		options = [];
						# 	};
						# 	dhcpv6 = {
						# 		range_start = "";
						# 		lease_duration = 86400;
						# 		ra_slaac_only = false;
						# 		ra_allow_slaac = false;
						# 	};
						# };
						filtering = {
							blocked_services.schedule.time_zone = "Europe/Paris";
							safe_search.enabled = false;
							rewrites = builtins.genList (i: {
								domain = "${builtins.elemAt (builtins.attrNames config.services.podman.containers) i}.${myLibs.impureSopsReading osConfig.sops.secrets.dns.path}";
								answer = config.services.podman.containers.${builtins.elemAt (builtins.attrNames config.services.podman.containers) i}.ip4;
							}) (builtins.length (builtins.attrNames config.services.podman.containers));
						};
						# log = {
						# 	enabled = true;
						# 	file = "";
						# 	max_backups = 0;
						# 	max_size = 100;
						# 	max_age = 3;
						# 	compress = false;
						# 	local_time = false;
						# 	verbose = false;
						# };
						schema_version = 30;
					};
				in { # https://github.com/AdguardTeam/AdGuardHome/issues/1964
					file = builtins.toFile "AdguardhomeContainerfile" 
					''
						FROM docker.io/adguard/adguardhome:latest
						COPY ${builtins.baseNameOf (builtins.toFile "AdGuardHome.json" (builtins.toJSON adguardHomeConfig))} /opt/adguardhome/conf/AdGuardHome.yaml
					'';
				};
			};
		};
		systemd.user.services.podman-auto-prune = {
			Unit = {
				Description = "Podman auto prune after update";
				After = [ "podman-auto-update.service" ];
			};
			Install = {
				WantedBy = [ "podman-auto-update.service" ];
			};
			Service = {
				Type = "simple";
				ExecStart = "${pkgs.podman} image prune -a -f";
			};
		};
	};
}