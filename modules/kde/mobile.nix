{ pkgs, lib, ... }:
{
	imports = [ ./kde.nix ];
	services.displayManager = {
		sessionPackages = [ pkgs.kdePackages.plasma-mobile ];
		defaultSession = lib.mkForce "plasma-mobile";
	};
	environment.systemPackages = with pkgs.kdePackages; [ calindori keysmith koko plasma-dialer spacebar ];
}