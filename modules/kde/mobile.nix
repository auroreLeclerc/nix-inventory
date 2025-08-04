{ pkgs, lib, ... }:
{
	# desktopManager.plasma6.enable = lib.mkforce true;
	environment = {
		systemPackages = with pkgs.kdePackages; [ plasma-mobile plasma-phonebook plasma-dialer calindori kclock kweather ];
		plasma6.excludePackages = with pkgs.kdePackages; [ elisa oxygen ];
	};
}
