{ lib, config, myLibs, ... }:
	{
	sops = lib.mkIf config.users.mutableUsers {
		defaultSopsFormat = "yaml";
		age.keyFile = myLibs.const.AGE_KEY_FILE;
		defaultSopsFile = ./secrets/secrets.yml;
		secrets = {
			mail = "N/A";
			name = "N/A";
			ip = "N/A";
			dns = "N/A";
			homer = {
				jellyfin = "";
				radarr = "";
				sonarr = "";
				lidarr = "";
			};
		};
	};
}