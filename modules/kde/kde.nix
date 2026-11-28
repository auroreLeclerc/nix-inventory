{
  pkgs,
  lib,
  config,
  ...
}:
let
  secrets = config.secrets.values;
in
{
  imports = [
    ./sddm.nix
  ];
  services = {
    desktopManager.plasma6.enable = true;
    geoclue2.enable = false;
  };
  security.rtkit.enable = true;
  #	services.printing.enable = true; # Enable CUPS to print documents.
  hardware.bluetooth.enable = true;

  environment = {
    systemPackages =
      (with pkgs.kdePackages; [
        plasma-welcome
        kcrash
        drkonqi
        kate
        yakuake
        plasma-disks
        kcalc
        filelight
        plasma-browser-integration
        partitionmanager
      ])
      ++ (with pkgs; [
        nil
        bash-language-server
        papirus-icon-theme
        wireguard-tools
      ]);
    plasma6.excludePackages = with pkgs.kdePackages; [
      elisa
      oxygen
      kmahjongg
      kmines
      kpat
      ksudoku
      ktorrent
      kwalletmanager
      plasma-systemmonitor
    ];
  };
  programs.kdeconnect.enable = true;

  users.users.dawn.extraGroups = [ "networkmanager" ];

  fileSystems."/home/dawn/bellum" =
    let
      inherit (secrets) ip;
      isIp = ip != "";
      ssh = /home/dawn/.ssh/bellum;
      isSsh = isIp && (builtins.trace "SSH credentials are missing" (builtins.pathExists ssh));
    in
    lib.mkIf isSsh {
      device = "dawn@${ip}:/run/media/dawn/";
      fsType = "sshfs";
      options = [
        "x-systemd.automount"
        "x-systemd.mount-timeout=10"
        "_netdev"
        "IdentityFile=${ssh}"
      ];
    };
}
