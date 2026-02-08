{ lib, config, myLibs, ... }: {
	options = {
		hardware.ramSizeGiB = lib.mkOption {
			type = lib.types.int;
			default = 0;
			description = "RAM size in GiB. Set to 0 to disable swap.";
		};
		secrets.values = let
			mkSecretOption = name: lib.mkOption {
				type = lib.types.str;
				default = "";
				description = "Value of the ${name} secret. Populated automatically in impure mode.";
			};
		in {
			dns = mkSecretOption "dns";
			ip = mkSecretOption "ip";
			mail = mkSecretOption "mail";
			name = mkSecretOption "name";
			secondaryMail = mkSecretOption "secondaryMail";
			duck = mkSecretOption "duck";
			jellyfin = mkSecretOption "jellyfin";
			radarr = mkSecretOption "radarr";
			sonarr = mkSecretOption "sonarr";
			lidarr = mkSecretOption "lidarr";
			prowlarr = mkSecretOption "prowlarr";
			miniflux = mkSecretOption "miniflux";
			paperless = mkSecretOption "paperless";
		};
	};
	config.secrets.values = let
		readSecret = path: myLibs.impureSopsReading path;
	in lib.mkIf (config.users.mutableUsers && !lib.inPureEvalMode) {
		dns = readSecret config.sops.secrets.dns.path;
		ip = readSecret config.sops.secrets.ip.path;
		mail = readSecret config.sops.secrets.mail.path;
		name = readSecret config.sops.secrets.name.path;
		secondaryMail = readSecret config.sops.secrets.secondaryMail.path;
		duck = readSecret config.sops.secrets.duck.path;
		jellyfin = readSecret config.sops.secrets.jellyfin.path;
		radarr = readSecret config.sops.secrets.radarr.path;
		sonarr = readSecret config.sops.secrets.sonarr.path;
		lidarr = readSecret config.sops.secrets.lidarr.path;
		prowlarr = readSecret config.sops.secrets.prowlarr.path;
		miniflux = readSecret config.sops.secrets.miniflux.path;
		paperless = readSecret config.sops.secrets.paperless.path;
	};
}