{ config, pkgs, ... }:
{
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      requestEncryptionCredentials = false;
      extraPools =
        {
          "bellum" = [
            "cubus"
            "bellum"
          ];
          "fierce-deity" = [ "odolwa" ];
        }
        .${config.networking.hostName};
    };
  };
  services = {
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
      autoSnapshot = {
        enable = true; # Note that you must set the com.sun:auto-snapshot property to true on all datasets which you wish to auto-snapshot.
        frequent = 0;
        hourly = 0;
        daily = 7;
        weekly = 0;
        monthly = 24;
      };
    };
    scrutiny.collector = {
      enable = true;
      settings = {
        api.endpoint = "http://127.0.0.1:8080";
        devices = [
          {
            device = "/dev/sda";
            type = "ata";
          }
          {
            device = "/dev/sdb";
            type = "ata";
          }
          {
            device = "/dev/sdc";
            type = "ata";
          }
          {
            device = "/dev/sdd";
            type = "ata";
          }
          {
            device = "/dev/sde";
            type = "ata";
          }
          {
            device = "/dev/sdf";
            type = "ata";
          }
          {
            device = "/dev/sdg";
            type = "ata";
          }
          {
            device = "/dev/sdh";
            type = "ata";
          }
          {
            device = "/dev/sdi";
            type = "ata";
          }
          {
            device = "/dev/sdj";
            type = "ata";
          }
          {
            device = "/dev/sdk";
            type = "ata";
          }
          {
            device = "/dev/sdl";
            type = "ata";
          }
          {
            device = "/dev/sdm";
            type = "ata";
          }
          {
            device = "/dev/nvme0";
            type = "ata";
          }
        ];
      };
    };
  };
  environment.systemPackages = with pkgs; [
    openseachest
    sg3_utils
    scrutiny-collector
  ];
}
