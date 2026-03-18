{
  pkgs,
  lib,
  osConfig,
  unstablePkgs,
  isDarwin,
  ...
}:
let
  secrets =
    if !isDarwin then
      osConfig.secrets.values
    else
      {
        mail = "";
        name = "";
      };
  adbEnabled = !isDarwin && osConfig.programs.adb.enable;
in
{
  config = {
    catppuccin = {
      enable = false;
      flavor = "mocha";
      accent = "mauve";
    };
    home = {
      stateVersion = lib.mkIf (!isDarwin) osConfig.system.stateVersion;
      packages = with pkgs; [ nerd-fonts.meslo-lg ];
    };
    programs = {
      pay-respects = {
        enable = true;
        enableZshIntegration = true;
      };
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
        ];
        oh-my-zsh = {
          enable = true;
          plugins = [
            "sudo"
            "node"
            "npm"
            "git"
            "nvm"
            "emoji"
          ]
          ++ lib.optionals (!isDarwin) [
            "repo"
            "podman"
          ]
          ++ lib.optionals isDarwin [
            "macos"
            "brew"
          ];
        };
        localVariables = lib.mkIf adbEnabled {
          "CHROME_EXECUTABLE" = "${pkgs.chromium}/bin/chromium-browser";
          "CAPACITOR_ANDROID_STUDIO_PATH" = unstablePkgs.android-studio;
          "JAVA_HOME" = pkgs.jdk;
          "ANDROID_HOME" = "/home/dawn/Android/Sdk/";
          "ELECTRON_SKIP_BINARY_DOWNLOAD" = 1;
        };
        initContent = builtins.readFile ./zshrc.sh;
      };
      diff-highlight.enable = true;
      git = {
        enable = !isDarwin;
        settings = lib.mkIf (osConfig.users.mutableUsers or false) {
          user.email = secrets.mail;
          user.name = secrets.name;
        };
      };
    };
  };
}
