{ pkgs, ... }: {
  programs.vesktop = {
    enable = true;
    settings = {
      hardwareVideoAcceleration = true;
      hardwareVideoEncoding = true;
    };
    vencord.settings = {
      autoUpdate = true;
      autoUpdateNotification = true;
      notifyAboutUpdates = true;
      plugins = {
        ClearURLs.enabled = true;
        BlurNSFW.enabled = true;
        NoProfileThemes.enabled = true;
        NoServerEmojis.enabled = true;
        NoTrack.enabled = true;
        WhoReacted.enabled = true;
      };
    };
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.common = {
      default = [
        "kde"
      ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "kde" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "kde" ];
      "org.freedesktop.impl.portal.Secret" = [ "none" ];
    };
  };
}
