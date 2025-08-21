{ unstablePkgs, pkgs, lib, ... }:
{
	programs.steam = {
		enable = true;
		extraCompatPackages = [ unstablePkgs.proton-ge-bin ];
		localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
	};
	environment.systemPackages =
		(with pkgs; [ lutris ryubing dolphin-emu-primehack dolphin-emu azahar ppsspp itch xrgears radeontop mprisence ]) ++
		(with unstablePkgs; [ discord ])
	;
	hardware = {
		xpadneo.enable = true;
		amdgpu.amdvlk = { # default but won't work in gamescope
			enable = true;
			support32Bit.enable = true;
		};
		graphics = { # RADV
			enable = true;
			enable32Bit = true;
		};
	};

	specialisation."Steam Deck".configuration = {
		services.desktopManager.plasma6.enable = lib.mkForce false;
		programs = {
			gamescope = {
				enable = true;
				capSysNice = true;
			};
			steam.gamescopeSession.enable = true;
		};
		environment = {
			systemPackages = with pkgs; [ mangohud (writeShellScriptBin "steamdeck" (builtins.readFile ./gamescope.sh)) ];
			loginShellInit = ''
				[[ "$(tty)" = "/dev/tty1" ]] && steamdeck
			'';
		};
	};
}
