# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, ... }:
{
	imports = [
		../../modules/kde/kde.nix
		../../modules/gaming/gaming.nix
		../../modules/workstation.nix
		inputs.nixos-hardware.nixosModules.common-cpu-amd
		inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
		inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
		inputs.nixos-hardware.nixosModules.common-gpu-amd
		{
			home-manager.users.dawn = {
				imports = [
					../../modules/kde/kde.home.nix
					../../modules/firefox.home.nix
				];
			};
		}
	];
	config = {
		networking.hostName = "fierce-deity"; # Define your hostname.

		# This value determines the NixOS release from which the default
		# settings for stateful data, like file locations and database versions
		# on your system were taken. It‘s perfectly fine and recommended to leave
		# this value at the release version of the first install of this system.
		# Before changing this value read the documentation for this option
		# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
		system.stateVersion = "24.11"; # Did you read the comment?
	};
}
