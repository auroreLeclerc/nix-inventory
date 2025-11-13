{ ... } : {
	imports = [ ./podman/podman.home.nix ];
	config = {
		programs.distrobox = {
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
			# settings = { # FIXME: 25.11
			# 	container_manager = "podman";
			# };
		};
		home.file = {
			distroboxrc = {
				source = builtins.toFile "distroboxrc" ''container_manager="podman"'';
				target = ".distroboxrc";
			};
		};
	};
}