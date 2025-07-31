{
	description = "🏳️‍⚧️";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
		unstableNixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
		nixos-hardware.url = "github:NixOS/nixos-hardware/master";
		catppuccin.url = "github:catppuccin/nix";
		home-manager = {
			url = "github:nix-community/home-manager?ref=release-25.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		plasma-manager = {
			url = "github:nix-community/plasma-manager";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.home-manager.follows = "home-manager";
		};
		nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
		sops-nix.url = "github:Mic92/sops-nix";
	};
	outputs = { self, nixpkgs, home-manager, catppuccin, ... } @ inputs:
	let
# 		pkgs = nixpkgs.legacyPackages.x86_64-linux;
		myLibs = import ./lib/default.nix { lib = nixpkgs.lib; const = (import ./lib/const.nix); };
		check = myLibs.checkSupportedVersion nixpkgs.lib.trivial.release;
		unstablePkgs = import inputs.unstableNixpkgs {
			system = "x86_64-linux";
			config = {
				allowUnfree = builtins.trace "NixOS ${nixpkgs.lib.trivial.codeName}		${nixpkgs.lib.trivial.version}" check;
				android_sdk.accept_license = check;
			};
		};
	in {
		nixosConfigurations = builtins.mapAttrs ( unit: fileType: 
			assert fileType == "directory";
			nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				specialArgs = {
					inherit unstablePkgs;
					inherit inputs;
					inherit myLibs;
				};
				modules = [
					inputs.home-manager.nixosModules.home-manager
					inputs.catppuccin.nixosModules.catppuccin
					inputs.sops-nix.nixosModules.sops
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.backupFileExtension = "backup";
						home-manager.sharedModules = [
							inputs.plasma-manager.homeManagerModules.plasma-manager
							inputs.catppuccin.homeManagerModules.catppuccin
							inputs.nix-flatpak.homeManagerModules.nix-flatpak
							./modules/core/core.home.nix
						];
						home-manager.extraSpecialArgs = {
							inherit unstablePkgs;
							inherit myLibs;
						};
					}
					./units/${unit}/configuration.nix
					./units/${unit}/hardware-configuration.nix
					./modules/core/core.nix
				];
			} 
		) (builtins.readDir ./units);
# 		packages.x86_64-linux.default = pkgs.uwufetch;
	};
}
