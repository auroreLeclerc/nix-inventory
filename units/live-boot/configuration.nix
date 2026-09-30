{
  pkgs,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
    {
      home-manager.users.nixos = {
        imports = [
          ../../modules/firefox.home.nix
          {
            config.catppuccin = {
              enable = lib.mkForce true;
              flavor = "mocha";
              accent = "mauve";
            };
          }
        ];
      };
    }
  ];
  config = {
    catppuccin = {
      enable = lib.mkForce true;
      flavor = "mocha";
      accent = "mauve";
    };
    boot.zfs.forceImportRoot = false; # to be removed after 26.11
    users.users.nixos.shell = pkgs.zsh;

    environment = {
      systemPackages =
        (with pkgs.kdePackages; [
          kate
          plasma-disks
          filelight
          partitionmanager
        ])
        ++ (with pkgs; [
          nil
          bash-language-server
          wireguard-tools
        ]);
    };
  };
}
