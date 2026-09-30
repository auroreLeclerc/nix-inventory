{
  description = "nix-inventory";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    catppuccin.url = "github:catppuccin/nix/release-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/latest";
    sops-nix.url = "github:Mic92/sops-nix";
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mrchromebox-scripts = {
      url = "github:MrChromebox/scripts";
      flake = false;
    };
    ryubing-canary-src = {
      url = "git+https://git.ryujinx.app/projects/Ryubing.git?ref=master&shallow=1";
      flake = false;
    };
    catppuccin-konsole = {
      url = "github:catppuccin/konsole";
      flake = false;
    };
    catppuccin-yakuake = {
      url = "github:catppuccin/yakuake";
      flake = false;
    };
    xenia-kde6 = {
      url = "github:astro-cyberpaws/xenia-kde6";
      flake = false;
    };
    gemma = {
      url = "git+https://huggingface.co/unsloth/gemma-4-E4B-it-qat-mobile-GGUF";
      flake = false;
    };
  };
  outputs =
    { nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      myLibs = import ./lib/default.nix {
        inherit lib;
      };

      metaUnits = builtins.mapAttrs (
        name: _:
        let
          metaPath = ./units/${name}/meta.nix;
        in
        if builtins.pathExists metaPath then
          import metaPath
        else
          {
            isLinux = true;
          }
      ) (builtins.readDir ./units);

      mkSystem =
        {
          unit,
          isLinux ? false,
          isDarwin ? false,
          isLive ? false,
        }:
        (if isDarwin then inputs.nix-darwin.lib.darwinSystem else lib.nixosSystem) {
          system = if isDarwin then "aarch64-darwin" else "x86_64-linux";
          specialArgs = {
            inherit
              inputs
              myLibs
              isLinux
              isDarwin
              isLive
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
                overwriteBackup = true;
                sharedModules = [
                  inputs.catppuccin.homeModules.catppuccin
                  ./modules/core/core.home.nix
                ]
                ++ lib.optionals (!isDarwin) [
                  inputs.plasma-manager.homeModules.plasma-manager
                  inputs.nix-flatpak.homeManagerModules.nix-flatpak
                ];
                extraSpecialArgs = {
                  inherit
                    inputs
                    myLibs
                    isLinux
                    isDarwin
                    isLive
                    ;
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
                ./modules/core/options.nix
              ]
              ++ lib.optionals isLinux [
                inputs.sops-nix.nixosModules.sops
                ./units/${unit}/hardware-configuration.nix
              ]
          );
        };
    in
    {
      nixosConfigurations =
        let
          metaLinux = myLibs.filterSetOfSetByNameBool "isLinux" metaUnits;
          metaLive = myLibs.filterSetOfSetByNameBool "isLive" metaUnits;
        in
        builtins.mapAttrs (
          unit: meta:
          mkSystem {
            inherit unit;
            isLinux = meta ? isLinux;
            isLive = meta ? isLive;
          }
        ) (metaLinux // metaLive);

      darwinConfigurations =
        let
          metaDarwin = myLibs.filterSetOfSetByNameBool "isDarwin";
        in
        builtins.mapAttrs (
          unit: meta:
          mkSystem {
            inherit unit;
            isDarwin = meta ? isDarwin;
          }
        ) metaDarwin;

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
          nixfmt
          statix
          deadnix
        ];
      };

      apps.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          ryubingCanary = pkgs.callPackage ./modules/gaming/ryubing-canary.nix {
            ryubingCanarySrc = inputs.ryubing-canary-src;
          };
          mkApp = name: description: runtimeInputs: text: {
            type = "app";
            program = "${pkgs.writeShellApplication { inherit name runtimeInputs text; }}/bin/${name}";
            meta.description = description;
          };
        in
        {
          lint = mkApp "lint" "Check nix files with statix" [ pkgs.statix ] "statix check";
          fix = mkApp "fix" "Fix nix files with statix" [ pkgs.statix ] "statix fix";
          pre-commit-install = mkApp "pre-commit-install" "Install pre-commit hooks" [
            pkgs.pre-commit
          ] "pre-commit install --install-hooks";
          pre-commit-run = mkApp "pre-commit-run" "Run pre-commit on all files" [
            pkgs.pre-commit
          ] "pre-commit run --all-files";
          fetch-ryubing-canary-deps =
            mkApp "fetch-ryubing-canary-deps" "Regenerate ryubing-canary-deps.json" [ ]
              "exec ${ryubingCanary.passthru.fetch-deps} \"$PWD/modules/gaming/ryubing-canary-deps.json\"";
        };
    };
}
