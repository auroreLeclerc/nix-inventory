{ unstablePkgs, pkgs, lib, ... }:
{
	programs.steam = {
		enable = true;
		extraCompatPackages = [ unstablePkgs.proton-ge-bin ];
		localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
	};
	environment.systemPackages =
		(with pkgs; [
			bottles dolphin-emu-primehack dolphin-emu azahar ppsspp itch xrgears radeontop
		]) ++
		(with unstablePkgs; [ discord celeste64 freeciv_qt ryubing ])
	;
	hardware = {
		xone.enable = true;
		graphics = { # RADV
			enable = true;
			enable32Bit = true;
		};
	};

	specialisation."Steam Deck (Gamescope)".configuration = {
		home-manager.users.dawn = {
			home.file = {
				cef = {
					text = "";
					target = ".steam/steam/.cef-enable-remote-debugging";
				};
				pluginLoader = {
					source = builtins.fetchurl {
						url = "https://github.com/SteamDeckHomebrew/decky-loader/releases/latest/download/PluginLoader";
						sha256 = "0xq18mpd9yn21wf0ggf5hf692s41aavmph4bvi7kgwz0zjgqsaif";
					};
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
			systemPackages = with pkgs; [ mangohud ] ++ [ steamdeck ];
			loginShellInit = ''
				[[ "$(tty)" = "/dev/tty1" ]] && steamdeck
			'';
		};
	};
}
