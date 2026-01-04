{ pkgs, lib, config, ... }:
{
	config = lib.mkIf config.users.mutableUsers {
		boot = { # Use the systemd-boot EFI boot loader.
			loader = {
				systemd-boot.enable = true;
				efi.canTouchEfiVariables = true;
			};
		};
		users.users.dawn = {
			description = "Aurore";
			initialPassword = "dawn";
			isNormalUser = true;
			shell = pkgs.zsh;
			extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
			linger = config.networking.hostName == "bellum";
		};
		swapDevices = let
			size = {
				"bellum" = 0;
				"exelo" = 16;
				"fierce-deity" = 16;
				"midna" = 4;
				"kimado" = 6;
			}.${config.networking.hostName}*1024;
			isSwap = size != 0;
		in lib.mkIf isSwap [ {
			inherit size;
			device = "/var/lib/${config.networking.hostName}.swap";
  	} ];
	};
}

