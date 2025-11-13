{} : {
	imports = [ ../podman/podman.home.nix ];
	config.programs.distrobox = {
		enable = true;
		containers = {
			debian = {
				additional_packages = "git nano";
				image = "docker.io/debian/debian:stable";
			};
			pip3 = {
				clone = "debian";
				entry = true;
				additional_packages = "python3";
				init_hooks = "pip3 install numpy pandas";
			};
		};
		settings = {
			container_manager = "podman";
		};
	};
}