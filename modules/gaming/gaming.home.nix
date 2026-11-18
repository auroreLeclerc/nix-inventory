{ pkgs, ... }: {
  programs.vesktop = {
    enable = true;
    settings = {
      hardwareAcceleration = true;
      hardwareVideoAcceleration = true;
      hardwareVideoEncoding = true;
    };
    vencord.settings = {
      autoUpdate = true;
      autoUpdateNotification = true;
      notifyAboutUpdates = true;
      useQuickCss = false;
      plugins = {
        ClearURLs.enabled = true;
        BlurNSFW.enabled = true;
        NoProfileThemes.enabled = true;
        NoServerEmojis.enabled = true;
        NoTrack.enabled = true;
        WhoReacted.enabled = true;
        BetterGifPicker.enabled = true;
        BetterSearch.enabled = true;
        petpet.enabled = true;
        UserMessagesPronouns.enabled = true;
        PlatformIndicators.enabled = true;
        LoadingQuotes.enabled = true;
      };
      themeLinks = [ "https://allpurposemat.codeberg.page/Disblock-Origin/DisblockOrigin.theme.css" ];
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
