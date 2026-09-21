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
    packages =
      lib.optionals osConfig.programs.vscodium.enable [
        "org.raspberrypi.rpi-imager"
        "io.github.ferraridamiano.ConverterNOW"
      ]
      ++ lib.optionals osConfig.programs.steam.enable [ "org.DolphinEmu.dolphin-emu" ];
  };
  home.packages = with pkgs; [
    flatpak
    appimage-run
  ];
}
