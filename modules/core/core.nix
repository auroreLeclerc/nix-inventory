{ pkgs, inputs, lib, config, ... }:
let
	motd = pkgs.writeShellScriptBin "motd" (builtins.readFile ./motd.sh);
	bellum-sync = pkgs.writeShellScriptBin "bellum-sync" ''
		set -euo pipefail
		BELLUM="${config.secrets.values.ip}"
		${builtins.readFile ./rsync.sh}
	'';
in
{
	imports = [ ./user.nix ./sops.nix ];
	config = {
		networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
		time.timeZone = "Europe/Paris"; # Set your time zone.
		i18n = { # Select internationalisation properties.
			defaultLocale = "fr_FR.UTF-8";
			supportedLocales = [ "C.UTF-8/UTF-8" "fr_FR.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
		};
		console = {
			packages = [ pkgs.terminus_font ];
			font = "ter-v16n";
			keyMap = "fr";
		};
		services.fwupd.enable = true;
		security.sudo.package = pkgs.sudo.override { withInsults = true; };
		nix = {
			settings = {
				auto-optimise-store = true;
				experimental-features = [ "nix-command" "flakes" ];
			};
			nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
		};
		nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
			"steam" "steam-original" "steam-unwrapped" "steam-run" "unrar" "xow_dongle-firmware"
		];
		fonts.packages = with pkgs; [ noto-fonts noto-fonts-color-emoji liberation_ttf roboto ubuntu-classic ];
		environment.systemPackages = (with pkgs; [
			nano nanorc wget openssl curl age htop parted jq fastfetch cowsay lolcat p7zip
			unzip unrar file ffmpeg pciutils openseachest sg3_utils
		]) ++ [ motd ]++ lib.optionals (!builtins.elem config.networking.hostName [ "bellum" "nixos" ]) [ bellum-sync ];
		programs.zsh.enable = true;
	};
}

