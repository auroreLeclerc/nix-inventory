{ ... }: {
	config = {
		services.podman = {
			enable = true;
			autoUpdate.enable = true;
		};
		home.packages = (with pkgs; [ podman-desktop podman-compose ]);
	};
}