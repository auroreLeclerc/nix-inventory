{
  description = "nix-inventory";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    unstableNixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    catppuccin.url = "github:catppuccin/nix/release-25.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "unstableNixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    sops-nix.url = "github:Mic92/sops-nix";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-infra = {
      url = "github:NixOS/infra";
      flake = false;
    };
  };
  outputs =
    { nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      myLibs = import ./lib/default.nix {
        inherit lib;
        inherit (inputs) nixos-infra;
      };

      units = builtins.mapAttrs (
        name: _:
        let
          metaPath = ./units/${name}/meta.nix;
          hasMeta = builtins.pathExists metaPath;
        in
        {
          system = if hasMeta then (import metaPath).system else "x86_64-linux";
        }
      ) (builtins.readDir ./units);

      filterBySystem = kernel: lib.filterAttrs (_: unit: lib.hasSuffix kernel unit.system) units;
      linuxUnits = filterBySystem "-linux";
      darwinUnits = filterBySystem "-darwin";

      mkSystem =
        {
          unit,
          meta,
          isDarwin,
        }:
        let
          inherit (meta) system;
          mkUnstablePkgs =
            let
              check = myLibs.checkSupportedVersion nixpkgs.lib.trivial.release;
            in
            system:
            import inputs.unstableNixpkgs {
              inherit system;
              config = {
                allowUnfree = builtins.trace "NixOS ${nixpkgs.lib.trivial.codeName}		${nixpkgs.lib.trivial.version}" check;
                android_sdk.accept_license = check;
              };
            };
          unstablePkgs = mkUnstablePkgs system;
        in
        (if isDarwin then inputs.nix-darwin.lib.darwinSystem else lib.nixosSystem) {
          inherit system;
          specialArgs = {
            inherit
              inputs
              myLibs
              isDarwin
              unstablePkgs
              ;
          };
          modules = [
            ./modules/core/core.nix
            ./units/${unit}/configuration.nix
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                sharedModules = [
                  inputs.catppuccin.homeModules.catppuccin
                  ./modules/core/core.home.nix
                ]
                ++ lib.optionals (!isDarwin) [
                  inputs.plasma-manager.homeModules.plasma-manager
                  inputs.nix-flatpak.homeManagerModules.nix-flatpak
                ];
                extraSpecialArgs = {
                  inherit myLibs isDarwin unstablePkgs;
                };
              };
            }
          ]
          ++ (
            if isDarwin then
              [
                inputs.home-manager.darwinModules.home-manager
              ]
            else
              [
                inputs.nix-index-database.nixosModules.nix-index
                inputs.home-manager.nixosModules.home-manager
                inputs.catppuccin.nixosModules.catppuccin
                inputs.sops-nix.nixosModules.sops
                ./modules/core/options.nix
                ./units/${unit}/hardware-configuration.nix
              ]
          );
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs (
        unit: meta:
        mkSystem {
          inherit unit meta;
          isDarwin = false;
        }
      ) linuxUnits;

      darwinConfigurations = builtins.mapAttrs (
        unit: meta:
        mkSystem {
          inherit unit meta;
          isDarwin = true;
        }
      ) darwinUnits;

      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
          nano
          nanorc
          wget
          openssl
          curl
          age
          htop
          parted
          fastfetch
          p7zip
          unzip
          file
          sops
          python3
          pre-commit
          nixfmt-rfc-style
          statix
          deadnix
        ];
      };
    };
}
