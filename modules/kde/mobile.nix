{ pkgs, lib, ... }:
{
	desktopManager.plasma6.package = lib.mkForce pkgs.kdePackages.plasma-mobile;
	environment = {
		systemPackages = with pkgs.kdePackages; [  plasma-phonebook plasma-dialer calindori kclock kweather ];
	};
}
