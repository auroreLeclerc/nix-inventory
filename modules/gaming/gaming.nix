{
  unstablePkgs,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs.steam = {
    enable = true;
    extraCompatPackages = [ unstablePkgs.proton-ge-bin ];
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  environment.systemPackages =
    (with pkgs; [
      bottles
      dolphin-emu-primehack
      dolphin-emu
      azahar
      ppsspp
      itch
      xrgears
      archipelago
    ])
    ++ (with unstablePkgs; [
      discord
      celeste64
      freeciv_qt
      ryubing
      # dusklight
      # shipwright
    ]);
  hardware = {
    xone.enable = true;
    graphics = {
      # RADV
      enable = true;
      enable32Bit = true;
    };
  };

  specialisation."Steam Deck (Gamescope)".configuration =
    let
      inherit (inputs.jovian-nixos.legacyPackages.${pkgs.stdenv.hostPlatform.system}) decky-loader;
    in
    {
      home-manager.users.dawn = {
        home.file = {
          cef = {
            text = "";
            target = ".steam/steam/.cef-enable-remote-debugging";
          };
          pluginLoader = {
            source = "${decky-loader}/bin/decky-loader";
            executable = true;
            target = "homebrew/services/PluginLoader";
          };
        };
      };
      systemd.services.decky-loader = {
        unitConfig = {
          Description = "SteamDeck Plugin Loader";
          After = "network.target";
        };
        serviceConfig =
          let
            HOMEBREW_FOLDER = "/home/dawn/homebrew";
          in
          {
            Type = "simple";
            User = "root";
            Restart = "always";
            KillMode = "process";
            TimeoutStopSec = 15;
            ExecStart = "${HOMEBREW_FOLDER}/services/PluginLoader";
            WorkingDirectory = "${HOMEBREW_FOLDER}/services";
            Environment = [
              "UNPRIVILEGED_PATH=${HOMEBREW_FOLDER}"
              "PRIVILEGED_PATH=${HOMEBREW_FOLDER}"
              "LOG_LEVEL=INFO"
            ];
          };
        wantedBy = [ "multi-user.target" ];
      };

      services.desktopManager.plasma6.enable = lib.mkForce false;
      programs = {
        gamescope = {
          enable = true;
          capSysNice = true;
        };
        steam.gamescopeSession.enable = true;
      };
      environment =
        let
          steamdeck = pkgs.writeShellScriptBin "steamdeck" (builtins.readFile ./gamescope.sh);
        in
        {
          systemPackages =
            with pkgs;
            [ mangohud ]
            ++ [
              steamdeck
              decky-loader
            ];
          loginShellInit = ''
            [[ "$(tty)" = "/dev/tty1" ]] && steamdeck
          '';
        };
    };
}
