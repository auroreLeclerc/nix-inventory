{
  pkgs,
  inputs,
  lib,
  config,
  isDarwin,
  ...
}:
let
  motd = pkgs.writeShellScriptBin "motd" (builtins.readFile ./motd.sh);
  bellum-sync = pkgs.writeShellScriptBin "bellum-sync" ''
    set -euo pipefail
    BELLUM="${config.secrets.values.ip}"
    ${builtins.readFile ./rsync.sh}
  '';
in
{
  imports = lib.optionals (!isDarwin) [
    ./user.nix
    ./sops.nix
  ];
  config = {
    time.timeZone = "Europe/Paris";
    nix = {
      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    };
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (final: _prev: {
          pnpm_10_29_2 = final.pnpm_10; # https://github.com/NixOS/nixpkgs/issues/536623
          pnpm_9 = final.pnpm_10; # decky-loader use insecure
        })
      ];
    };
    fonts.packages = with pkgs; [
      open-sans
      noto-fonts
      noto-fonts-color-emoji
      liberation_ttf
      roboto
      ubuntu-classic
    ];
    environment.systemPackages =
      (with pkgs; [
        nano
        nanorc
        wget
        openssl
        curl
        age
        htop
        jq
        fastfetch
        cowsay
        lolcat
        p7zip
        unzip
        unrar
        file
        ffmpeg
        libwebp
      ])
      ++ lib.optionals (!isDarwin) (
        with pkgs;
        [
          pciutils
          parted
        ]
        ++ [ motd ]
      )
      ++ lib.optionals (
        !builtins.elem config.networking.hostName [
          "bellum"
          "work"
          "nixos"
        ]
      ) [ bellum-sync ];
    programs.zsh.enable = true;
  }
  // lib.optionalAttrs (!isDarwin) {
    networking.networkmanager.enable = true;
    i18n = {
      defaultLocale = "fr_FR.UTF-8";
      supportedLocales = [
        "C.UTF-8/UTF-8"
        "fr_FR.UTF-8/UTF-8"
        "en_GB.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];
    };
    console = {
      packages = [ pkgs.terminus_font ];
      font = "ter-v16n";
      keyMap = "fr";
    };
    services.fwupd.enable = true;
    security = {
      sudo.package = pkgs.sudo.override { withInsults = true; };
      pam.services = {
        login.fprintAuth = false;
        sudo.fprintAuth = false;
      };
    };
  };
}
