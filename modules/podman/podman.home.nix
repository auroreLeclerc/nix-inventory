{ pkgs, osConfig, lib, ... }: {
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
				gateway = "172.18.0.1";
			};
			builds = {
				postgres = {
					file = builtins.toFile "PostgresContainerfile" 
					''
						FROM docker.io/pgautoupgrade/pgautoupgrade:latest
						COPY ${builtins.baseNameOf (builtins.toFile "init-db.sql" (builtins.readFile ./init-db.sql))} /docker-entrypoint-initdb.d/
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