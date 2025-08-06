{ pkgs, config, lib, ... }:
{
	services = {
		displayManager.sddm = {
			enable = true;
			package = lib.mkForce pkgs.kdePackages.sddm; # TODO: libsForQt5.sddm is default in 25.05
			wayland.enable = true;
			autoNumlock = true;
		};
		xserver = { # TODO: https://nixos.wiki/wiki/Wayland
		 	enable = true; # Enable the X11 windowing system.
		 	xkb = { # Configure keymap in X11
		 		layout = "fr";
		 		variant = "azerty";
			};
			excludePackages = [ pkgs.xterm ];
		};
	};
	catppuccin = {
		sddm = {
			enable = config.services.displayManager.sddm.enable;
			background = builtins.fetchurl {
				url = "https://images.spr.so/cdn-cgi/imagedelivery/j42No7y-dcokJuNgXeA0ig/5d3b0bc1-03d4-4c56-b04d-70f7fe07d603/complete-screen8/w=2256";
				sha256 = "sha256-D5o0TmE9rGey35Uljjo9JtG5XGsY4TgkKxqmQWDiVvA=";
			};
			loginBackground = true;
		};
	};
}
