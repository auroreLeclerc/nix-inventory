{
  pkgs,
  lib,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.nixos = {
          imports = [
            { programs.librewolf.enable = true; }
          ];
        };
      };
    }
  ];
  config = {
    users = {
      mutableUsers = false;
      users.nixos = {
        initialPassword = lib.mkForce "nixos";
        shell = pkgs.zsh;
      };
    };

    networking.wireless.enable = false;

    nixpkgs.config.pulseaudio = true;
    services.xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      desktopManager.lxqt.enable = true;
      xkb = {
        layout = "fr";
        variant = "azerty";
      };
      displayManager.lightdm = {
        enable = true;
        background = builtins.fetchurl {
          url = "https://publish-01.obsidian.md/access/d32b95288f15249fa01b04513b6b05f3/Art%20files/Celeste/extra/Maddy.png";
          sha256 = "084ln86mh1ib0mwrylk7kpfkkcvdn0am0m8xlxymlyza3ah7immz";
        };
      };
    };
    services.displayManager.autoLogin = {
      enable = true;
      user = "nixos";
    };

    environment = {
      systemPackages =
        (with pkgs; [
          networkmanagerapplet
          calamares-nixos
          calamares-nixos-extensions
          glibcLocales
          nil
          bash-language-server
        ])
        ++ (with pkgs.kdePackages; [
          kpmcore
          partitionmanager
          kate
          filelight
        ]);
      lxqt.excludePackages = with pkgs; [
        adwaita-icon-theme
        adwaita-qt
      ];
    };
  };
}
