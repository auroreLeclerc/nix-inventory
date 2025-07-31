{ pkgs, unstablePkgs, ... }:
{
	config = {
		users.users.dawn.extraGroups = [ "adbusers" ];
		programs.adb.enable = true;
		environment.systemPackages = (with pkgs; [ flutter chromium jdk git-repo ]) ++ (with unstablePkgs; [ android-studio ]);
		services.udev.packages = [ pkgs.android-udev-rules ];
	};
}
