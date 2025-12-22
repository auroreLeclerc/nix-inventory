{ pkgs, ... }:
{
	services.flatpak = {
		enable = true;
		update.auto.enable = true;
		uninstallUnmanaged = true;
		packages = [ "fr.handbrake.ghb" ];
	};
	home.packages = with pkgs; [ flatpak appimage-run ];
}
