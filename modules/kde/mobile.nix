{ pkgs, lib, ... }:
{
	imports = [ ./kde.nix ];
	services.displayManager = {
		sessionPackages = [ pkgs.kdePackages.plasma-mobile ];
		defaultSession = lib.mkForce "plasma-mobile";
	};
	environment.systemPackages = with pkgs.kdePackages; [
		plasma-mobile plasma-nano pkgs.maliit-framework
		pkgs.maliit-keyboardcalindori keysmith koko plasma-dialer spacebar
	];
	hardware.sensor.iio.enable = true;
}