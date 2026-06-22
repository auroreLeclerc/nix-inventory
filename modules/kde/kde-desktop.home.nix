{
  pkgs,
  ...
}:
{
  imports = [ ./kde.home.nix ];
  config = {
    manual.html.enable = true;
    programs = {
      plasma = {
        desktop.widgets = [
          {
            digitalClock = {
              date.format = "longDate";
              position = {
                horizontal = 1000;
                vertical = 500;
              };
              size = {
                width = 400;
                height = 400;
              };
            };
          }
        ];
        panels = [
          {
            location = "top";
            hiding = "autohide";
            height = 48;
            lengthMode = "fill";
            widgets = [
              {
                kickoff = {
                  icon = builtins.fetchurl {
                    url = "https://xenia-images.efi.pages.gay/questfortori3.png";
                    sha256 = "sha256-I7+vQ4R0AAXaZVwEohYCOnOSsM8sBSk18or56PrGZVc=";
                  };
                };
              }
              {
                name = "org.kde.plasma.taskmanager";
                config.General.launchers = [ ];
              }
              {
                name = "org.kde.plasma.weather";
                config.WeatherStation.source = "bbcukmet|weather|Amiens, France, FR|3037854";
              }
              {
                plasmusicToolbar = {
                  panelIcon = {
                    icon = builtins.fetchurl {
                      url = "https://publish-01.obsidian.md/access/d32b95288f15249fa01b04513b6b05f3/Art%20files/Celeste/promo/ots.png";
                      sha256 = "14yiswvfsszi38k7sc8bqclhhbm8kbnzzb0ybxqq1p2cqsn6ncvb";
                    };
                    albumCover = {
                      useAsIcon = true;
                      fallbackToIcon = true;
                      radius = 8;
                    };
                  };
                  songText = {
                    maximumWidth = 0;
                    scrolling = {
                      enable = true;
                      behavior = "scrollOnHover";
                    };
                  };
                  playbackSource = "auto";
                  musicControls.showPlaybackControls = false;
                };
              }
              {
                name = "org.kde.plasma.systemtray";
                config.items.hidden = [
                  "org.kde.plasma.notifications"
                  "org.kde.plasma.clipboard"
                  "org.kde.plasma.mediacontroller"
                ];
              }
              "org.kde.plasma.digitalclock"
            ];
          }
          {
            location = "bottom";
            hiding = "autohide";
            height = 72;
            lengthMode = "fit";
            floating = true;
            widgets = [
              "org.kde.plasma.trash"
              "org.kde.plasma.marginsseparator"
              {
                name = "org.kde.plasma.quicklaunch";
                config.General.launcherUrls = [
                  "file:///etc/profiles/per-user/dawn/share/applications/firefox.desktop"
                  "file:///run/current-system/sw/share/applications/google-chrome.desktop"
                  "file:///run/current-system/sw/share/applications/discord.desktop"
                  "file:///home/dawn/.local/share/applications/chrome-hnpfjngllnobngcgfapefoaidbinmjnm-Default.desktop" # Whatsapp Web
                  "file:///run/current-system/sw/share/applications/steam.desktop"
                  "file:///run/current-system/sw/share/applications/com.usebottles.bottles.desktop"
                  "file:///home/dawn/.local/share/applications/chrome-lgnggepjiihbfdbedefdhcffnmhcahbm-Default.desktop" # Reddit
                  "file:///home/dawn/.local/share/applications/chrome-agimnkijcaahngcdmfeangaknmldooml-Default.desktop" # YouTube
                  "file:///etc/profiles/per-user/dawn/share/applications/codium.desktop"
                  "file:///run/current-system/sw/share/applications/sublime_text.desktop"
                  "file:///run/current-system/sw/share/applications/org.strawberrymusicplayer.strawberry.desktop"
                  "file:///home/dawn/.local/share/applications/chrome-cinhimbnkkaeohfgghhklpknlkffjgod-Default.desktop" # YT Music
                  "file:///run/current-system/sw/share/applications/org.inkscape.Inkscape.desktop"
                  "file:///home/dawn/.local/share/applications/wine/Programs/PhotoFiltre 7/PhotoFiltre 7.desktop"
                  "file:///home/dawn/.local/share/applications/wine/Programs/7-Zip/7-Zip File Manager.desktop"
                  "file:///run/current-system/sw/share/applications/startcenter.desktop" # LibreOffice
                  "file:///run/current-system/sw/share/applications/org.kde.discover.desktop"
                  "file:///run/current-system/sw/share/applications/org.kde.dolphin.desktop"
                ];
              }
              "org.kde.plasma.marginsseparator"
              "org.kde.plasma.showdesktop"
            ];
          }
          {
            location = "right";
            hiding = "autohide";
            height = 72;
            lengthMode = "fit";
            floating = true;
            widgets =
              let
                colors = builtins.fromJSON (builtins.readFile ./kde_colors.json);
              in
              [
                {
                  systemMonitor = {
                    displayStyle = "org.kde.ksysguard.horizontalbars";
                    sensors =
                      assert builtins.isList colors.GPU;
                      [
                        {
                          name = "gpu/all/usage";
                          color = builtins.elemAt colors.GPU 0;
                          label = "GPU";
                        }
                        {
                          name = "gpu/all/usedVram";
                          color = builtins.elemAt colors.GPU 1;
                          label = "VRAM";
                        }
                      ];
                    textOnlySensors = [ "gpu/all/temperature" ];
                  };
                }
                {
                  systemMonitor = {
                    title = "CPU";
                    displayStyle = "org.kde.ksysguard.piechart";
                    sensors =
                      assert builtins.isList colors.CPU;
                      builtins.genList (i: {
                        name = "cpu/cpu${toString i}/usage";
                        color = builtins.elemAt colors.CPU i;
                        label = "Thread n°${toString (builtins.add i 1)}";
                      }) (builtins.length colors.CPU);
                    totalSensors = [ "cpu/all/usage" ];
                    textOnlySensors = [ "cpu/all/maximumTemperature" ];
                  };
                }
                {
                  systemMonitor = {
                    displayStyle = "org.kde.ksysguard.horizontalbars";
                    sensors =
                      assert builtins.isList colors.RAM;
                      [
                        {
                          name = "memory/physical/used";
                          color = builtins.elemAt colors.RAM 0;
                          label = "RAM";
                        }
                        {
                          name = "memory/swap/used";
                          color = builtins.elemAt colors.RAM 1;
                          label = "SWAP";
                        }
                      ];
                  };
                }
                {
                  systemMonitor = {
                    title = "I/O";
                    displayStyle = "org.kde.ksysguard.linechart";
                    sensors =
                      assert builtins.isList colors.NETWORK;
                      assert builtins.isList colors.STORAGE;
                      [
                        {
                          name = "disk/all/read";
                          color = builtins.elemAt colors.STORAGE 0;
                          label = "Read";
                        }
                        {
                          name = "disk/all/write";
                          color = builtins.elemAt colors.STORAGE 1;
                          label = "Write";
                        }
                        {
                          name = "network/all/download";
                          color = builtins.elemAt colors.NETWORK 0;
                          label = "Download";
                        }
                        {
                          name = "network/all/upload";
                          color = builtins.elemAt colors.NETWORK 1;
                          label = "Upload";
                        }
                      ];
                    textOnlySensors = [ "os/system/uptime" ];
                  };
                }
              ];
          }
        ];
        configFile = {
          kteatimerc = {
            General = {
              PopupAutoHide = false;
              UsePopup = true;
              UseVisualize = false;
            };
            Tealist = {
              "Tea0 Name" = "Tortellini";
              "Tea0 Time" = 3 * 60;
              "Tea1 Name" = "Girasoli";
              "Tea1 Time" = 4 * 60;
              "Tea2 Name" = "Tortellini";
              "Tea2 Time" = 5 * 60;
              "Tea3 Name" = "Coquillettes";
              "Tea3 Time" = 8 * 60;
            };
          };
          "kteatime.notifyrc" = {
            "Event/ready" = {
              Action = "Sound|Popup";
              Sound = "/run/current-system/sw/share/sounds/freedesktop/stereo/suspend-error.oga";
            };
            "Event/popup" = {
              Action = "Popup";
            };
          };
        };
      };
    };
    home =
      let
        foldersorter = pkgs.writeShellScriptBin "foldersorter" (builtins.readFile ./foldersorter.sh);
        downloadsort = pkgs.writeShellScriptBin "downloadsort" "foldersorter ~/Téléchargements";
      in
      {
        packages = [
          downloadsort
          foldersorter
        ]
        ++ (with pkgs.kdePackages; [
          wacomtablet
          discover
          ghostwriter
          isoimagewriter
          kcolorchooser
          kolourpaint
          korganizer
          arianna
          kteatime
          kweather
          ktimer
          koi
          dolphin-plugins
        ])
        ++ (with pkgs; [
          strawberry
          gnome-firmware
          vlc
          mission-center
        ]);
        file = {
          koi = {
            source = "${pkgs.kdePackages.koi}/share/applications/local.KoiDbusInterface.desktop";
            target = ".config/autostart/local.KoiDbusInterface.desktop";
          };
          kteatime = {
            source = "${pkgs.kdePackages.kteatime}/share/applications/org.kde.kteatime.desktop";
            target = ".config/autostart/org.kde.kteatime.desktop";
          };
          foldersorter = {
            source = "${downloadsort}/bin/downloadsort";
            target = ".config/plasma-workspace/env/downloadsort.sh";
          };
          photofiltre = {
            source = builtins.fetchurl {
              url = "https://web.archive.org/web/20200331083451if_/http://static.infomaniak.ch/photofiltre/utils/pf7/pf7-setup-en-7.2.1.exe";
              sha256 = "1rz5is6awq2lw33pq6bw9991rylwgk2pagk2k8mgxqkglah261dj";
            };
            target = "Téléchargements/Photofiltre 7.exe";
          };
          sevenZip = {
            source = builtins.fetchurl {
              url = "https://github.com/ip7z/7zip/releases/latest/download/7z2601-x64.msi";
              sha256 = "1wh2rl8vzzpzvsan13sjrciglcg05347gbjc8zgfc25wz3fahzm4";
            };
            target = "Téléchargements/7-Zip.exe";
          };
        };
      };
  };
}
