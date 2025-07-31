{ pkgs, unstablePkgs, ... }:
{
	imports = [
		./android-studio.nix
	];
	config = {
		environment.systemPackages = 
			(with pkgs.kdePackages; [ kdenlive	]) ++
			(with pkgs; [
				blender libreoffice-qt6-fresh hunspell hunspellDicts.fr-moderne hunspellDicts.en-gb-large inkscape gimp krita
				signal-desktop tor-browser-bundle-bin sirikali wineWowPackages.stable
				]) ++
			(with unstablePkgs; [ sublime3 ventoy-full-qt google-chrome ])
		;
	};
}
