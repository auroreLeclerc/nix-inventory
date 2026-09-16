{
  pkgs,
  lib,
  osConfig,
  config,
  isDarwin,
  ...
}:
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
        dotDir = "${config.xdg.configHome}/zsh";
        localVariables = {
          XDG_CONFIG_HOME = config.xdg.configHome;
        };
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
        initContent = builtins.readFile ./zshrc.sh;
      };
      diff-highlight.enable = true;
      git = {
        enable = !isDarwin;
        settings = lib.mkIf (osConfig.users.mutableUsers or false) {
          user.email = "96054190+auroreLeclerc@users.noreply.github.com";
          user.name = "Aurore Leclerc";
        };
      };
    };
  };
}
