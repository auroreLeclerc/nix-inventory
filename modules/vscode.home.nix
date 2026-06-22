{ pkgs, ... }:
{
  programs.vscodium = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        ms-ceintl.vscode-language-pack-fr
        ms-python.python
        ms-python.debugpy
        ms-python.pylint
        ms-pyright.pyright
        redhat.java
        vscjava.vscode-java-debug
        redhat.vscode-yaml
        stylelint.vscode-stylelint
        # sonarsource.sonarlint-vscode
        dbaeumer.vscode-eslint
        jnoortheen.nix-ide
        jgclark.vscode-todo-highlight
        timonwong.shellcheck
        davidanson.vscode-markdownlint
        leonardssh.vscord
        golang.go
      ];
      userSettings = {
        "window.autoDetectColorScheme" = true;
        "workbench.preferredLightColorTheme" = "Catppuccin Latte";
        "workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
        "editor.tabSize" = 2;
        "diffEditor.ignoreTrimWhitespace" = false;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          nixd = {
            formatting.command = [ "nixfmt" ];
            nixpkgs.expr = "(builtins.getFlake (builtins.toString ./.)).inputs.nixpkgs.legacyPackages.x86_64-linux";
            options = {
              nixos.expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.exelo.options";
              home-manager.expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.exelo.options.home-manager.users.type.getSubOptions []";
            };
          };
        };
        "redhat.telemetry.enabled" = false;
        # "sonarlint.pathToNodeExecutable" = "${pkgs.nodejs}/bin/node";
        # "sonarlint.disableTelemetry" = true;
        "python.languageServer" = "Jedi";
        "git.autofetch" = true;
        "git.enableSmartCommit" = true;
        "git.confirmSync" = false;
        "[css]" = {
          "editor.defaultFormatter" = "stylelint.vscode-stylelint";
        };
        "java.debug.settings.vmArgs" = "-ea";
        "java.jdt.ls.java.home" = pkgs.jdk;
        "go.alternateTools" = {
          dlv = "${pkgs.delve}/bin/dlv";
          go = "${pkgs.go}/bin/go";
          gopls = "${pkgs.gopls}/bin/gopls";
        };
        "network.meteredConnection" = "off";
      };
    };
  };
  catppuccin.vscode.profiles.default = {
    enable = true;
    icons.enable = false;
  };
  home = {
    packages = with pkgs; [
      nodejs
      electron
      nixfmt
      nixd
      statix
      deadnix
      typescript
      python3
      graphviz
      sops
      jdk
      shellcheck
      libcap
      go
      gcc
      gopls
      delve
      pre-commit
      android-tools
    ];
    file = {
      css = {
        source = builtins.fetchurl {
          url = "https://www.dl.dropboxusercontent.com/scl/fi/mk0zd3iavho0asyh7zm2y/CSS-selectors-cheatsheet.pdf?rlkey=2wn3w9bkbizcjpi5f822brj6m&e=2&st=q0d5f1uh&dl=1";
          name = "CSS-selectors-cheatsheet.pdf";
          sha256 = "sha256-hZXNDiT+nk6KbdKctCPeZqv7MBx2C8b7224l3rAXhew=";
        };
        target = "Bureau/CSS selectors cheatsheet.pdf";
      };
      html = {
        source = builtins.fetchurl {
          url = "https://user.oc-static.com/upload/2022/11/25/16693925991605_FR_1603881_HTML-CSS_Static-Graphics_p3c1-1.jpg";
          sha256 = "sha256-om0kUy1I8gOb1NK+7FqI8JnnGvzv3mhiLQBZJoFtcRY=";
        };
        target = "Bureau/Structurez votre page.jpg";
      };
      strategique = {
        source = builtins.fetchurl {
          url = "https://messervices.cyber.gouv.fr/documents-guides/20231218_Volet_strat%C3%A9gique_cyberattaquesetrem%C3%A9diation_v1g.pdf";
          name = "volet-strategique.pdf";
          sha256 = "sha256-ASn4GzwXZj5gsLBcz4RyK8gsofksha+k0eVtwm1d0KA=";
        };
        target = "Bureau/Volet stratégique.pdf";
      };
      operationnel = {
        source = builtins.fetchurl {
          url = "https://messervices.cyber.gouv.fr/documents-guides/20231218_Volet_operationnel_cyberattaquesetremediation_a5_v1j.pdf";
          sha256 = "sha256-MAcd0Nx3CD3YTphLobfB84R6qpoCNWb0SdrziGVpPys=";
        };
        target = "Bureau/Volet opérationnel.pdf";
      };
      technique = {
        source = builtins.fetchurl {
          url = "https://messervices.cyber.gouv.fr/documents-guides/20231218_Volet_technique_cyberattaquesetremediation_a5_v1h.pdf";
          sha256 = "sha256-MrAcv3PqlmW1uyigRV80GwQGcTyQkRFtDOuvBN82v8c=";
        };
        target = "Bureau/Volet technique.pdf";
      };
    };
  };
}
