{ pkgs, lib, config, ... }:
{
	config = lib.mkIf config.users.mutableUsers {
		boot = { # Use the systemd-boot EFI boot loader.
			loader = {
				systemd-boot.enable = true;
				efi.canTouchEfiVariables = true;
			};
		};
		services.udev.extraRules = ''
			SUBSYSTEM=="block", KERNEL=="sd[a-z]", GROUP="smart", MODE="0660"
		'';
		users = {
			users.dawn = {
				description = "Aurore";
				initialPassword = "dawn";
				isNormalUser = true;
				shell = pkgs.zsh;
				extraGroups = [ "wheel" ];
				linger = config.networking.hostName == "bellum";
			};
			groups.smart = {
				members = [ "dawn" ];
			};
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

