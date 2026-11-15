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
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-kde
    ];
  };
}
