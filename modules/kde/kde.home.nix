{
  pkgs,
  osConfig,
  inputs,
  ...
}:
let
  darkWallpaper = builtins.fetchurl {
    url = "https://xenia-images.efi.pages.gay/neotheta2.png";
    sha256 = "sha256-GxGAo7uh717fy1aQREmMfZfuSdN1R0VflM7R3E4azU0=";
  };
  lightWallpaper = builtins.fetchurl {
    url = "https://xenia-images.efi.pages.gay/flyinghyena1.jpeg";
    sha256 = "sha256-Fe9bpTAYy8h26HG4WDOMwSl5oS56kHve5QXCrrhtlbU=";
  };
  hostDisplays = {
    exelo = [
      {
        "eDP-1" = ./icc/AMD-Framework-13.icm;
      }
    ];
    fierce-deity = [
      {
        "HDMI-A-1" = ./icc/Samsung-C27F39xF.icm;
      }
    ];
  };
  apply-icc = pkgs.writeShellScriptBin "apply-icc" (
    toString (
      map (script-line: (builtins.attrValues script-line)) (
        map (
          displays:
          (builtins.mapAttrs (
            screen-id: profile:
            "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.${screen-id}.iccprofile.'${profile}'\n"
          ))
            displays
        ) hostDisplays.${osConfig.networking.hostName} or [ ]
      )
    )
  );
in
{
  catppuccin = {
    zsh-syntax-highlighting.enable = true;
    cursors.enable = true;
  };
  programs = {
    konsole = {
      enable = true;
      customColorSchemes = {
        # https://github.com/nix-community/plasma-manager/pull/638
        # latte = "${inputs.catppuccin-konsole}/themes/catppuccin-latte.colorscheme";
        # mocha = "${inputs.catppuccin-konsole}/themes/catppuccin-mocha.colorscheme";
      };
      profiles.light = {
        colorScheme = "latte";
        font.name = "Hack";
      };
      profiles.dark = {
        colorScheme = "mocha";
        font.name = "Hack";
      };
      defaultProfile = "dark";
      ui.colorScheme = "mocha";
    };
    plasma = {
      enable = true;
      overrideConfig = true;
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
          url = "https://publish-01.obsidian.md/access/d32b95288f15249fa01b04513b6b05f3/Art%20files/Celeste/Complete%20screens/complete-screen7.png";
          sha256 = "10rsb73gpcx5fr69rwb5bswwn4iccfbjyh0ri2s1qdhsgprg4izr";
        };
        lockOnResume = true;
      };
      kwin.nightLight = {
        enable = true;
        location = {
          latitude = "49.8934486";
          longitude = "2.2954818";
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
          whenSleepingEnter = "hybridSleep";
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
          whenLaptopLidClosed = "hibernate";
          whenSleepingEnter = "standbyThenHibernate";
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
            latitude = 49.8934486;
            longitude = 2.2954818;
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
          KonsoleProfile = {
            enabled = false;
            dark = "dark";
            light = "light";
          };
        };
      };
    };
  };
  home = {
    packages = [ apply-icc ];
    file = {
      xeniaSplashScreen = {
        source = inputs.xenia-kde6;
        target = ".local/share/plasma/look-and-feel/xenia";
      };
      yakuakeLight = {
        source = "${inputs.catppuccin-yakuake}/latte";
        target = ".local/share/yakuake/kns_skins/latte";
      };
      yakuakeDark = {
        source = "${inputs.catppuccin-yakuake}/mocha";
        target = ".local/share/yakuake/kns_skins/mocha";
      };
      icon = {
        # https://github.com/NixOS/nixpkgs/issues/163080
        source = builtins.fetchurl {
          url = "https://publish-01.obsidian.md/access/d32b95288f15249fa01b04513b6b05f3/Art%20files/Celeste/portraits/badeline/07upset.gif";
          sha256 = "0c00qm7whjg31srfb7v6ky7y9y14klrpb006i6hfdqpnbd2al2h9";
        };
        target = ".face.icon";
      };
      yakuake = {
        source = "${pkgs.kdePackages.yakuake}/share/applications/org.kde.yakuake.desktop";
        target = ".config/autostart/org.kde.yakuake.desktop";
      };
      apply-icc = {
        source = "${apply-icc}/bin/apply-icc";
        target = ".config/plasma-workspace/env/apply-icc.sh";
      };
    };
  };
}
