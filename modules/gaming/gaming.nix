{ unstablePkgs, pkgs, lib, ... }:
{
	programs.steam = {
		enable = true;
		extraCompatPackages = [ unstablePkgs.proton-ge-bin ];
		localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
	};
	environment.systemPackages =
		(with pkgs; [
			bottles dolphin-emu-primehack dolphin-emu azahar ppsspp /* itch */ xrgears radeontop
		]) ++
		(with unstablePkgs; [ discord celeste64 freeciv_qt ryubing ])
	;
	hardware = {
		xone.enable = true;
		amdgpu.amdvlk = {
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
		hardware.amdgpu.amdvlk = { # https://github.com/GPUOpen-Drivers/AMDVLK/issues/403
			enable = lib.mkForce false;
			support32Bit.enable = lib.mkForce false;
		};
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
