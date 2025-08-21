{ inputs, pkgs, lib, myLibs, config, ... }:
{
	imports = [
		inputs.nixos-hardware.nixosModules.common-cpu-amd
		inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
		inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
		inputs.nixos-hardware.nixosModules.common-gpu-amd
		{
			home-manager.users.dawn = {
				imports = [
					../../modules/podman/homelab.home.nix
				];
			};
		}
	];

	boot = {
		supportedFilesystems = [ "zfs" ];
		zfs.extraPools = [ "bellum" "gohma"];
	};

	networking = {
		hostId = "6dec770a";
		hostName = "bellum";
		networkmanager.enable = true;
		firewall = {
			enable = true;
			allowedUDPPorts = [ 51820 ];
		};
		nat = {
			enable = true;
			externalInterface = "enp10s0";
		};
	};

	services = {
		fail2ban = {
			enable = true;
			maxretry = 5;
			bantime = "730h";
			ignoreIP = let
				ip = (myLibs.impureSopsReading config.sops.secrets.ip.path);
				isIp = (ip != "");
			in lib.mkIf isIp [ ip ];
		};
		openssh = {
			enable = true;
			settings = {
				PasswordAuthentication = false;
				AllowUsers = [ "dawn" ];
				PermitRootLogin = "no";
			};
		};
		zfs.autoScrub.enable = true;
	};

	nix.gc = {
		automatic = true;
		dates = "weekly";
		options = "--delete-older-than 14d";
	};

	# Enable CUPS to print documents.
	# services.printing.enable = true;

	environment.systemPackages = (with pkgs; [ lm_sensors smartmontools ]); # TODO: kexec-tools

	system.autoUpgrade.enable = true;

	# This option defines the first version of NixOS you have installed on this particular machine,
	# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
	#
	# Most users should NEVER change this value after the initial install, for any reason,
	# even if you've upgraded your system to a new NixOS release.
	#
	# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
	# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
	# to actually do that.
	#
	# This value being lower than the current NixOS release does NOT mean your system is
	# out of date, out of support, or vulnerable.
	#
	# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
	# and migrated your data accordingly.
	#
	# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
	system.stateVersion = "24.05"; # Did you read the comment?
}

