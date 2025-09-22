{ pkgs, osConfig, lib, ... }: {
	config = {
		home.packages = lib.mkIf osConfig.services.desktopManager.plasma6.enable (with pkgs; [ podman-desktop podman-compose ]);
		services.podman = {
			enable = true;
			autoUpdate = {
				enable = true;
				onCalendar = "daily";
			};
			networks.docker-like = {
				description = "Docker compatibilty (internal DNS resolution)";
				driver = "bridge";
				subnet = "172.18.0.0/24";
				gateway = "172.18.0.1";
			};
		};
	};
}