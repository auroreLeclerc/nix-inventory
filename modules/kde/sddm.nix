{
  pkgs,
  config,
  ...
}:
{
  boot.plymouth = {
    enable = true;
    theme = "blahaj";
    themePackages = with pkgs; [
      plymouth-blahaj-theme
      kdePackages.breeze-plymouth
    ];
  };
  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      autoNumlock = true;
    };
    xserver = {
      # TODO: https://nixos.wiki/wiki/Wayland
      enable = true; # Enable the X11 windowing system.
      xkb = {
        # Configure keymap in X11
        layout = "fr";
        variant = "azerty";
      };
      excludePackages = [ pkgs.xterm ];
    };
  };
  catppuccin = {
    sddm = {
      inherit (config.services.displayManager.sddm) enable;
      background = builtins.fetchurl {
        url = "https://publish-01.obsidian.md/access/d32b95288f15249fa01b04513b6b05f3/Art%20files/Celeste/Complete%20screens/complete-screen8.png";
        sha256 = "0rdxhwyg8rf31dwnzkpf1y0l0l40ni15x6icb3w9kj5xsbnmr9lp";
      };
      userIcon = true;
    };
  };
}
