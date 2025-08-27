{ osConfig, pkgs, ... }:
{
	services.flatpak = {
		enable = true;
		update.auto.enable = true;
		uninstallUnmanaged = true;
		# packages = (if osConfig.programs.steam.enable then [
		# 	"org.azahar_emu.Azahar"
		# 	"org.DolphinEmu.dolphin-emu"
		# 	"org.ppsspp.PPSSPP"
		# 	"io.github.shiiion.primehack"
		# 	"io.github.ryubing.Ryujinx"
		# ] else [])
		# ++ (if config.core.android then [
		# 	"com.google.AndroidStudio"
		# ] else [])
		# ;
	};
	home.packages = with pkgs; [ appimage-run ];
}
