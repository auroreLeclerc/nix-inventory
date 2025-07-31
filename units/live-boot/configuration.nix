{ pkgs, modulesPath, inputs, ... }:
{
	imports = [
		"${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
		"${modulesPath}/installer/cd-dvd/channel.nix"
		inputs.home-manager.nixosModules.home-manager
		{
			home-manager.useGlobalPkgs = true;
			home-manager.useUserPackages = true;
			home-manager.backupFileExtension = "backup";
			home-manager.users.nixos = {
				imports = [
					{ programs.librewolf.enable = true; }
				];
			};
		}
	];
	config = {
		users = {
			mutableUsers = false;
			users.nixos = {
				password = "nixos";
				shell = pkgs.zsh;
			};
		};

		networking.wireless.enable = false;

		nixpkgs.config.pulseaudio = true;
		services.xserver = {
			enable = true;
			excludePackages = [ pkgs.xterm ];
			desktopManager.lxqt.enable = true;
			xkb = {
				layout = "fr";
				variant = "azerty";
			};
			displayManager.lightdm = {
				enable = true;
				background = builtins.fetchurl {
					url = "https://images.spr.so/cdn-cgi/imagedelivery/j42No7y-dcokJuNgXeA0ig/983670de-d8f0-4afe-8503-443708773491/maddy/w=2256";
					sha256 = "sha256-pHLwF6f5qswN448Nj0QWuDhA+u41nC+nT9tsDmRSKAA=";
				};
			};
		};
		services.displayManager.autoLogin = {
			enable = true;
			user = "nixos";
		};

		environment = {
			systemPackages = (
				with pkgs; [ networkmanagerapplet calamares-nixos calamares-nixos-extensions glibcLocales nil bash-language-server ]
			) ++ (
				with pkgs.libsForQt5; [ kpmcore partitionmanager kate filelight ]
			);
			lxqt.excludePackages = with pkgs; [ adwaita-icon-theme adwaita-qt ];
		};
	};
}
