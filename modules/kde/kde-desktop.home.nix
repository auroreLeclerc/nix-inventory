{
  pkgs,
  lib,
  osConfig,
  config,
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
                      url = "https://images.spr.so/cdn-cgi/imagedelivery/j42No7y-dcokJuNgXeA0ig/f50a4ba8-e3d6-4a76-8259-12aba129b9eb/ots/w=512";
                      sha256 = "sha256-6Fhb/6/VdiVWk3TVoVg2l3E4++zQfoQhn8JDyichTz0=";
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
                        name = "cpu/cpu${builtins.toString i}/usage";
                        color = builtins.elemAt colors.CPU i;
                        label = "Thread n°${builtins.toString (builtins.add i 1)}";
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
          dolphin-plugins
        ])
        ++ (with pkgs; [
          strawberry
          gnome-firmware
          vlc
          mission-center
        ]);
        file = {
          kteatime = {
            source = "${pkgs.kdePackages.kteatime}/share/applications/org.kde.kteatime.desktop";
            target = ".config/autostart/org.kde.kteatime.desktop";
          };
          foldersorter = {
            source = "${downloadsort}/bin/downloadsort";
            target = ".config/plasma-workspace/env/downloadsort.sh";
          };
          adb = lib.mkIf osConfig.programs.adb.enable {
            source = "${pkgs.android-tools}/bin/adb";
            target = "Android/Sdk/platform-tools/adb";
          };
          css = lib.mkIf config.programs.vscode.enable {
            source = builtins.fetchurl {
              url = "https://www.dl.dropboxusercontent.com/scl/fi/mk0zd3iavho0asyh7zm2y/CSS-selectors-cheatsheet.pdf?rlkey=2wn3w9bkbizcjpi5f822brj6m&e=2&st=q0d5f1uh&dl=1";
              name = "CSS-selectors-cheatsheet.pdf";
              sha256 = "sha256-hZXNDiT+nk6KbdKctCPeZqv7MBx2C8b7224l3rAXhew=";
            };
            target = "Bureau/CSS selectors cheatsheet.pdf";
          };
          html = lib.mkIf config.programs.vscode.enable {
            source = builtins.fetchurl {
              url = "https://user.oc-static.com/upload/2022/11/25/16693925991605_FR_1603881_HTML-CSS_Static-Graphics_p3c1-1.jpg";
              sha256 = "sha256-om0kUy1I8gOb1NK+7FqI8JnnGvzv3mhiLQBZJoFtcRY=";
            };
            target = "Bureau/Structurez votre page.jpg";
          };
          strategique = lib.mkIf config.programs.vscode.enable {
            source = builtins.fetchurl {
              url = "https://messervices.cyber.gouv.fr/documents-guides/20231218_Volet_strat%C3%A9gique_cyberattaquesetrem%C3%A9diation_v1g.pdf";
              name = "volet-strategique.pdf";
              sha256 = "sha256-ASn4GzwXZj5gsLBcz4RyK8gsofksha+k0eVtwm1d0KA=";
            };
            target = "Bureau/Volet stratégique.pdf";
          };
          operationnel = lib.mkIf config.programs.vscode.enable {
            source = builtins.fetchurl {
              url = "https://messervices.cyber.gouv.fr/documents-guides/20231218_Volet_operationnel_cyberattaquesetremediation_a5_v1j.pdf";
              sha256 = "sha256-MAcd0Nx3CD3YTphLobfB84R6qpoCNWb0SdrziGVpPys=";
            };
            target = "Bureau/Volet opérationnel.pdf";
          };
          technique = lib.mkIf config.programs.vscode.enable {
            source = builtins.fetchurl {
              url = "https://messervices.cyber.gouv.fr/documents-guides/20231218_Volet_technique_cyberattaquesetremediation_a5_v1h.pdf";
              sha256 = "sha256-MrAcv3PqlmW1uyigRV80GwQGcTyQkRFtDOuvBN82v8c=";
            };
            target = "Bureau/Volet technique.pdf";
          };
          photofiltre = {
            source = builtins.fetchurl {
              url = "https://web.archive.org/web/20200331083451if_/http://static.infomaniak.ch/photofiltre/utils/pf7/pf7-setup-en-7.2.1.exe";
              sha256 = "sha256-sgUjoKJv4v4qmmI+dcV8nPocUkp8GXzH4FRgroyO5ec=";
            };
            target = "Téléchargements/Photofiltre 7.exe";
          };
          sevenZip = {
            source = builtins.fetchurl {
              url = "https://7-zip.org/a/7z2501-x64.exe";
              sha256 = "sha256-eK+iocdzyvPPft9i+FfSqKXaVfsP/12kFgdMDSiytV8=";
            };
            target = "Téléchargements/7-Zip.exe";
          };
        };
      };
  };
}
