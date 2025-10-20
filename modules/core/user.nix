{ pkgs, lib, config, ... }:
{
	config = lib.mkIf config.users.mutableUsers {
		boot = { # Use the systemd-boot EFI boot loader.
			loader = {
				systemd-boot.enable = true;
				efi.canTouchEfiVariables = true;
			};
			plymouth = {
				enable = lib.mkIf config.desktopManager.plasma6.enable;
				theme = "angular";
				themePackages = with pkgs; [
					(adi1090x-plymouth-themes.override {
						selected_themes = [ "angular" ];
					})
				];
			};
		};
		users.users.dawn = {
			description = "Aurore";
			initialPassword = "dawn";
			isNormalUser = true;
			shell = pkgs.zsh;
			extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
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
			size = size;
			device = "/var/lib/${config.networking.hostName}.swap";
  	} ];
	};
}

