# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, ... }:
{
	imports = [
		../../modules/kde/kde.nix
		../../modules/workstation.nix
		../../modules/android-studio.nix
		../../modules/gaming/gaming.nix
		../../modules/virtualbox.nix
		inputs.nixos-hardware.nixosModules.framework-13-7040-amd
		{
			home-manager.users.dawn = {
				imports = [
					../../modules/kde/kde.home.nix
					../../modules/vscode.home.nix
					../../modules/flatpak.home.nix
					../../modules/firefox.home.nix
					../../modules/podman/workbench.home.nix
					../../modules/gaming/mprisenc.home.nix
				];
			};
		}
	];
	config = {
		# Use latest kernel.
		#   boot.kernelPackages = pkgs.linuxPackages_latest;

		networking.hostName = "exelo"; # Define your hostname.

		# Enable automatic login for the user.
		#   services.displayManager.autoLogin.enable = true;
		#   services.displayManager.autoLogin.user = "dawn";

		# This value determines the NixOS release from which the default
		# settings for stateful data, like file locations and database versions
		# on your system were taken. It‘s perfectly fine and recommended to leave
		# this value at the release version of the first install of this system.
		# Before changing this value read the documentation for this option
		# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
		system.stateVersion = "25.05"; # Did you read the comment?
	};
}
