{
  lib,
  myLibs,
  ...
}:
{
  sops = lib.mkIf (!lib.inPureEvalMode) {
    defaultSopsFormat = "yaml";
    age.keyFile = myLibs.const.AGE_KEY_FILE;
    defaultSopsFile = ./secrets/secrets.yml;
    secrets = {
      mail = { };
      ip = { };
      dns = { };
      duck = { };
      jellyfin = { };
      radarr = { };
      sonarr = { };
      lidarr = { };
      prowlarr = { };
      miniflux = { };
      paperless = { };
    };
  };
}
