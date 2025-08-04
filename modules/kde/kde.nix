{ pkgs, lib, myLibs, config, ... }:
{
	imports = [ ./sddm.nix ./fprintd.nix ];
	services = {
		desktopManager.plasma6.enable = true; # Enable the KDE Plasma Desktop Environment.
		pulseaudio.enable = false; # Enable sound with pipewire.
		pipewire = {
			enable = true;
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
		};
	};
#	services.printing.enable = true; # Enable CUPS to print documents.
	hardware.bluetooth.enable = true;
	security.rtkit.enable = true; # https://nixos.wiki/wiki/PipeWire

	environment = {
		systemPackages = (
			with pkgs.kdePackages; [
				plasma-welcome kcrash drkonqi kate koi yakuake wacomtablet plasma-disks plasma-vault kcalc discover filelight
				ghostwriter isoimagewriter k3b kcolorchooser kolourpaint kweather plasma-sdk plasma-browser-integration
				umbrello kalarm kteatime kasts itinerary partitionmanager kontact korganizer kongress kompare ktimer
				plasma-browser-integration arianna
			]
			) ++ (
			with pkgs; [ nil bash-language-server strawberry papirus-icon-theme gnome-firmware vlc wireguard-tools poppler-utils ]
		);
		plasma6.excludePackages = with pkgs.kdePackages; [ elisa oxygen ];
	};
	programs.kdeconnect.enable = true;

	users.users.dawn.extraGroups = [ "networkmanager" ];

	fileSystems."/media/dawn/bellum" = let
		ip = (myLibs.impureSopsReading config.sops.secrets.ip.path);
		isIp = (ip != "");
		ssh = /home/dawn/.ssh/bellum;
		isSsh = isIp && (myLibs.consoleWarn (builtins.pathExists ssh) "SSH credentials are missing");
	in lib.mkIf isSsh {
		device = "dawn@${ip}:/media/bellum/main/";
		fsType = "sshfs";
		options = [
			"x-systemd.automount"
			"_netdev"
			"users"
			"idmap=user"
			# "allow_other"
			"reconnect"
			"IdentityFile=${ssh}"
		];
	};
}
