{ pkgs, lib, ... }:
{
	imports = [ ./kde.nix ];
	services.displayManager = {
		sessionPackages = [ pkgs.kdePackages.plasma-mobile ];
		defaultSession = lib.mkForce "plasma-mobile";
	};
	environment.systemPackages = (with pkgs.kdePackages; [
		plasma-mobile plasma-nano keysmith koko plasma-dialer spacebar calindori
	]) ++ (with pkgs; [ maliit-framework maliit-keyboard ]);
	hardware.sensor.iio.enable = true;
}