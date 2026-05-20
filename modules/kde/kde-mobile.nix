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
    systemPackages = with pkgs; [
      kdePackages.plasma-mobile
      maliit-framework
      maliit-keyboard
    ];
  };
  documentation.enable = false;
  programs.kdeconnect.enable = lib.mkForce false;
  hardware.sensor.iio.enable = true;
}
