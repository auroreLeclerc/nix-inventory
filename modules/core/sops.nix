{ lib, config, myLibs, ... }:
	{
	sops = lib.mkIf config.users.mutableUsers {
		defaultSopsFormat = "yaml";
		age.keyFile = myLibs.const.AGE_KEY_FILE;
		defaultSopsFile = ./secrets/secrets.yml;
		secrets = {
			mail = {};
			secondaryMail = {};
			name = {};
			ip = {};
			dns = {};
			jellyfin = {};
			radarr = {};
			sonarr = {};
			lidarr = {};
		};
	};
}