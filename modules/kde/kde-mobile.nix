{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./kde.nix ];
  services.displayManager = {
    sessionPackages = [ pkgs.kdePackages.plasma-mobile ];
    defaultSession = lib.mkForce "plasma-mobile";
  };
  environment = {
    systemPackages =
      (with pkgs.kdePackages; [
        plasma-mobile
        keysmith
        koko
        spacebar
        calindori
      ])
      ++ (with pkgs; [
        maliit-framework
        maliit-keyboard
      ]);
  };
  documentation.enable = false;
  hardware.sensor.iio.enable = true;
}
