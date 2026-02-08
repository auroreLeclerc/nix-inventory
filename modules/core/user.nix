{ pkgs, lib, config, ... }:
{
	config = let
		ramSize = config.hardware.ramSizeGiB;
		swapSize = builtins.ceil (ramSize*1024*0.4);
	in lib.mkIf config.users.mutableUsers {
		boot = { # Use the systemd-boot EFI boot loader.
			loader = {
				systemd-boot.enable = true;
				efi.canTouchEfiVariables = true;
			};
			kernelParams = lib.mkIf (ramSize <= 8) [
				"zswap.enabled=1"
				"zswap.shrinker_enabled=1"
  		];
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
		swapDevices = lib.mkIf (ramSize > 0) [ {
			size = swapSize;
			device = "/var/lib/${config.networking.hostName}.swap";
		} ];
	};
}

