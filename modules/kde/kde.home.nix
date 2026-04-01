{
  pkgs,
  ...
}:
{
  config = {
    catppuccin = {
      zsh-syntax-highlighting.enable = true;
      cursors.enable = true;
    };
    programs = {
      konsole = {
        enable = true;
        customColorSchemes = {
          Sweet = builtins.fetchurl {
            url = "https://raw.githubusercontent.com/EliverLara/Sweet/refs/heads/nova/kde/konsole/Sweet.colorscheme";
            sha256 = "sha256-wIamJFeTaJxZYpXsOr0RCjW6YlSc9v/1KRgXJ+gcztw=";
          };
        };
        profiles.Custom.colorScheme = "Sweet";
        defaultProfile = "Custom";
      };
      plasma =
        let
          darkWallpaper = builtins.fetchurl {
            url = "https://xenia-images.efi.pages.gay/neotheta2.png";
            sha256 = "sha256-GxGAo7uh717fy1aQREmMfZfuSdN1R0VflM7R3E4azU0=";
          };
          lightWallpaper = builtins.fetchurl {
            url = "https://xenia-images.efi.pages.gay/flyinghyena1.jpeg";
            sha256 = "sha256-Fe9bpTAYy8h26HG4WDOMwSl5oS56kHve5QXCrrhtlbU=";
          };
        in
        {
          enable = true;
          # overrideConfig = true;
          workspace = {
            wallpaper = lightWallpaper;
            wallpaperFillMode = "preserveAspectCrop";
            iconTheme = "Papirus";
            cursor = {
              theme = "catppuccin-mocha-mauve-cursors";
              size = 24;
            };
            splashScreen.theme = "xenia";
          };
          kscreenlocker = {
            appearance.wallpaper = builtins.fetchurl {
              url = "https://images.spr.so/cdn-cgi/imagedelivery/j42No7y-dcokJuNgXeA0ig/524746ff-5a2e-4cce-8121-c3b2f13fb224/complete-screen7/w=2256";
              sha256 = "sha256-K4YqRpyc1floZ4LGMuvQMeeGUYzLjAsqasYmGWiGP9U=";
            };
            lockOnResume = true;
          };
          kwin.nightLight = {
            enable = true;
            location = {
              latitude = "49.892";
              longitude = "2.299";
            };
            mode = "location";
            temperature.night = 2600;
          };
          powerdevil = {
            AC = {
              dimDisplay.enable = false;
              autoSuspend.action = "nothing";
              turnOffDisplay = {
                idleTimeout = 600;
                idleTimeoutWhenLocked = 300;
              };
              powerProfile = "performance";
              powerButtonAction = "showLogoutScreen";
              whenLaptopLidClosed = "lockScreen";
              whenSleepingEnter = "standby";
            };
            battery = {
              autoSuspend = {
                idleTimeout = 1800;
                action = "sleep";
              };
              turnOffDisplay = {
                idleTimeout = 600;
                idleTimeoutWhenLocked = 60;
              };
              powerProfile = "balanced";
              powerButtonAction = "showLogoutScreen";
              whenLaptopLidClosed = "sleep";
              whenSleepingEnter = "standbyThenHibernate";
            };
            lowBattery = {
              autoSuspend = {
                idleTimeout = 600;
                action = "sleep";
              };
              turnOffDisplay = {
                idleTimeout = 120;
                idleTimeoutWhenLocked = "immediately";
              };
              displayBrightness = 50;
              powerProfile = "powerSaving";
              powerButtonAction = "showLogoutScreen";
              whenLaptopLidClosed = "sleep";
              whenSleepingEnter = "hybridSleep";
            };
          };
          input.keyboard.numlockOnStartup = "on";
          session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
          shortcuts.ksmserver = {
            "Lock Session" = [
              "Screensaver"
              "Meta+L"
            ];
          };
          configFile = {
            kwinrc.Desktops.Number = 1;
            kwalletrc.Wallet.Enabled = false;
            kdeglobals.General.AccentColor = "#926EE4";
            plasmanotifyrc = {
              DoNotDisturb = {
                WhenFullscreen = false;
              };
            };
            koirc = {
              General = {
                latitude = 49.892;
                longitude = 2.299;
                notify = 2;
                schedule = 2;
                schedule-type = "sun";
                start-hidden = 2;
              };
              ColorScheme = {
                enabled = true;
                dark = "/run/current-system/sw/share/color-schemes/BreezeDark.colors";
                light = "/run/current-system/sw/share/color-schemes/BreezeLight.colors";
              };
              GTKTheme = {
                enabled = true;
                dark = "Breeze-Dark";
                light = "Breeze";
              };
              IconTheme = {
                enabled = true;
                dark = "Papirus-Dark";
                light = "Papirus-Light";
              };
              KvantumStyle.enabled = false;
              PlasmaStyle = {
                enabled = true;
                dark = "breeze-dark";
                light = "breeze-light";
              };
              Wallpaper = {
                enabled = true;
                dark = darkWallpaper;
                light = lightWallpaper;
              };
            };
          };
        };
    };
    home = {
      file = {
        xeniaSplashScreen = {
          source = builtins.fetchTarball {
            url = "https://github.com/astro-cyberpaws/xenia-kde6/releases/latest/download/xenia.tar.gz";
            sha256 = "08810rnv9ib3ixqdi8sd95ilng3r4s22q4xymvl7kdydnchligcc";
          };
          target = ".local/share/plasma/look-and-feel/xenia";
        };
        icon = {
          # https://github.com/NixOS/nixpkgs/issues/163080
          source = builtins.fetchurl {
            url = "https://images.spr.so/cdn-cgi/imagedelivery/j42No7y-dcokJuNgXeA0ig/d6f42c40-e039-4006-8991-a518b74c7506/upset/w=512";
            sha256 = "sha256-CQqqRFv24uagiQaAdTOdJPjkj59mn+WyDuNJyE/FADA=";
          };
          target = ".face.icon";
        };
        yakuake = {
          source = "${pkgs.kdePackages.yakuake}/share/applications/org.kde.yakuake.desktop";
          target = ".config/autostart/org.kde.yakuake.desktop";
        };
        koi = {
          source = "${pkgs.kdePackages.koi}/share/applications/local.KoiDbusInterface.desktop";
          target = ".config/autostart/local.KoiDbusInterface.desktop";
        };
      };
    };
  };
}
