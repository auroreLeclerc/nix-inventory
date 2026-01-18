{ unstablePkgs, pkgs, lib, ... }:
{
	programs.steam = {
		enable = true;
		extraCompatPackages = [ unstablePkgs.proton-ge-bin ];
		localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
	};
	environment.systemPackages =
		(with pkgs; [
			bottles dolphin-emu-primehack dolphin-emu azahar ppsspp itch xrgears archipelago
		]) ++
		(with unstablePkgs; [ discord celeste64 freeciv_qt ryubing shipwright ])
	;
	hardware = {
		xone.enable = true;
		graphics = { # RADV
			enable = true;
			enable32Bit = true;
		};
	};

	specialisation."Steam Deck (Gamescope)".configuration = let 
		decky-loader = import (builtins.fetchurl {
			url = "https://raw.githubusercontent.com/Jovian-Experiments/Jovian-NixOS/refs/heads/development/pkgs/decky-loader/default.nix";
			sha256 = "0afjb8jcqb4kx4sld3b0jpxfxwvs9y3d5lhkdvavhw5ajzx1m5bh";
		}) {
			inherit lib;
			fetchFromGitHub = pkgs.fetchFromGitHub;
			nodejs = pkgs.nodejs;
			pnpm_9 = pkgs.pnpm_9;
			fetchPnpmDeps = pkgs.fetchPnpmDeps;
			pnpmConfigHook = pkgs.pnpmConfigHook;
			python3 = pkgs.python3;
			coreutils = pkgs.coreutils;
			psmisc = pkgs.psmisc;
		};
	in {
		home-manager.users.dawn = {
			home.file = {
				cef = {
					text = "";
					target = ".steam/steam/.cef-enable-remote-debugging";
				};
				pluginLoader = {
					source = "${decky-loader}/bin/decky-loader";
					executable = true;
					target = "homebrew/services/PluginLoader";
				};
			};
		};
		systemd.services.decky-loader = {
			unitConfig = {
				Description = "SteamDeck Plugin Loader";
				After = "network.target";
			};
			serviceConfig = let
				HOMEBREW_FOLDER = "/home/dawn/homebrew";
			in {
				Type = "simple";
				User = "root";
				Restart = "always";
				KillMode = "process";
				TimeoutStopSec = 15;
				ExecStart = "${HOMEBREW_FOLDER}/services/PluginLoader";
				WorkingDirectory = "${HOMEBREW_FOLDER}/services";
				Environment = [
					"UNPRIVILEGED_PATH=${HOMEBREW_FOLDER}"
					"PRIVILEGED_PATH=${HOMEBREW_FOLDER}"
					"LOG_LEVEL=INFO"
				];
			};
			wantedBy = [ "multi-user.target" ];
		};

		services.desktopManager.plasma6.enable = lib.mkForce false;
		programs = {
			gamescope = {
				enable = true;
				capSysNice = true;
			};
			steam.gamescopeSession.enable = true;
		};
		environment = let
			steamdeck = pkgs.writeShellScriptBin "steamdeck" (builtins.readFile ./gamescope.sh);
		in {
			systemPackages = with pkgs; [ mangohud ] ++ [ steamdeck decky-loader ];
			loginShellInit = ''
				[[ "$(tty)" = "/dev/tty1" ]] && steamdeck
			'';
		};
	};
}
