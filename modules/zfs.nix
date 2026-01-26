{ config, ... }: {
	boot = {
		supportedFilesystems = [ "zfs" ];
		zfs = {
			requestEncryptionCredentials = false;
			extraPools = let
			pools = {
				"bellum" = [ "bellum" "cubus" ];
				"fierce-deity" = [];
			}.${config.networking.hostName};
			in pools;
		};
	};
	services.zfs = {
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
}