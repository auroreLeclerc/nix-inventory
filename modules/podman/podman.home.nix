{
  pkgs,
  osConfig,
  lib,
  config,
  ...
}:
{
  config =
    let
      containersNames = builtins.attrNames config.services.podman.containers;
    in
    {
      home.packages =
        let
          quadlets = map (name: "podman-" + name + ".service") containersNames;
          quadlets-start = pkgs.writeShellScriptBin "quadlets-start" "systemctl --user start ${toString quadlets}";
          quadlets-stop = pkgs.writeShellScriptBin "quadlets-stop" "systemctl --user stop ${toString quadlets}";
        in
        [
          quadlets-start
          quadlets-stop
        ]
        ++ lib.optionals osConfig.services.desktopManager.plasma6.enable (
          with pkgs;
          [
            podman-desktop
            podman-compose
          ]
        );
      home.file.".config/podman/nix-declared-containers".text = toString (
        builtins.length containersNames
      );
      services.podman = {
        enable = true;
        autoUpdate = {
          enable = true;
          onCalendar = "weekly";
        };
        networks = {
          docker-like = {
            description = "Main network";
            driver = "bridge";
            subnet = "172.18.0.0/24";
            gateway = "172.18.0.1";
          };
          friends = {
            description = "Network for friends (WIP)";
            driver = "bridge";
            subnet = "172.19.0.0/24";
            gateway = "172.19.0.1";
          };
          integration = {
            description = "CI/CD network";
            driver = "bridge";
            subnet = "172.16.0.0/24";
            gateway = "172.16.0.1";
          };
        };
        builds = {
          postgres = {
            file = builtins.toFile "PostgresContainerfile" ''
              FROM docker.io/pgautoupgrade/pgautoupgrade:latest
              COPY ${baseNameOf (builtins.toFile "init-db.sql" (builtins.readFile ./init-db.sql))} /docker-entrypoint-initdb.d/
            '';
          };
        };
      };
      systemd.user.services.podman-auto-prune = {
        Unit = {
          Description = "Podman auto prune after update";
          After = [ "podman-auto-update.service" ];
        };
        Install = {
          WantedBy = [ "podman-auto-update.service" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.podman} image prune -a -f";
        };
      };
    };
}
