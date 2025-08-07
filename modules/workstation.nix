{ pkgs, unstablePkgs, ... }:
{
	config = {
		environment.systemPackages = 
			(with pkgs.kdePackages; [ kdenlive kompare kongress plasma-sdk ]) ++
			(with pkgs; [
				blender libreoffice-qt6-fresh hunspell hunspellDicts.fr-moderne hunspellDicts.en-gb-large inkscape gimp krita
				signal-desktop tor-browser-bundle-bin sirikali wineWowPackages.stable
			]) ++
			(with unstablePkgs; [ sublime3 google-chrome ]) # ventoy-full-qt https://github.com/ventoy/Ventoy/issues/3224
		;
	};
}
