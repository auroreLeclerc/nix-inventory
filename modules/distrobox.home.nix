{ ... } : {
	imports = [ ./podman/podman.home.nix ];
	config = {
		programs.distrobox = {
			enable = true;
			containers = {
				debian = {
					entry = true;
					image = "docker.io/debian:bookworm";
					additional_packages = "git nano apt-file python3 python3-pip python3-wheel pipenv";
					init_hooks = [ "apt-file update;" ];
				};
				arch = {
					entry = true;
					image = "docker.io/archlinux:multilib-devel";
					init_hooks = [ "sudo pacman -Fy core extra multilib;" ];
				};
			};
			settings.container_manager = "podman";
		};
	};
}