{
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  services.flatpak = {
    enable = true;
    update.auto.enable = true;
    uninstallUnmanaged = true;
    packages = lib.mkIf osConfig.programs.steam.enable [ "org.DolphinEmu.dolphin-emu" ];
  };
  home.packages = with pkgs; [
    flatpak
    appimage-run
  ];
}
