{ ... } : {
	imports = [ ./podman/podman.home.nix ];
	config = {
		programs.distrobox = {
			enable = true;
			containers = {
				debian-python = {
					image = "docker.io/debian:bookworm";
					additional_packages = "git nano apt-file python3 python3-pip python3-wheel pipenv";
					init_hooks = [ "apt-file update;" ];
				};
				arch-wine = {
					image = "docker.io/archlinux:multilib-devel";
					additional_packages = "wine wine-gecko wine-mono winetricks";
					init_hooks = [ "winetricks --force vcrun2022;" ];
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