{ pkgs, lib, osConfig, unstablePkgs, ... }:
let
	secrets = osConfig.secrets.values;
in {
	config = {
		catppuccin = {
			enable = false; # no global enable
			flavor = "mocha";
			accent = "mauve";
		};
		home = {
			stateVersion = osConfig.system.stateVersion;
			packages = with pkgs; [ nerd-fonts.meslo-lg ];
		};
		programs = {
			pay-respects = {
				enable = osConfig.users.mutableUsers;
				enableZshIntegration = true;
			};
			zsh = {
				enable = true;
				enableCompletion = true;
				autosuggestion.enable = true;
				syntaxHighlighting.enable = true;
				plugins = lib.mkIf osConfig.users.mutableUsers [{
					name = "powerlevel10k";
					src = pkgs.zsh-powerlevel10k;
					file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
				}];
				oh-my-zsh = {
					enable = osConfig.users.mutableUsers;
					plugins = [ "sudo" "node" "npm" "git" "repo" "nvm" "emoji" "podman" ];
				};
				localVariables = lib.mkIf osConfig.programs.adb.enable {
					"CHROME_EXECUTABLE" = "${pkgs.chromium}/bin/chromium-browser";
					"CAPACITOR_ANDROID_STUDIO_PATH" = unstablePkgs.android-studio;
					"JAVA_HOME" = pkgs.jdk;
					"ANDROID_HOME" = "/home/dawn/Android/Sdk/";
					"ELECTRON_SKIP_BINARY_DOWNLOAD" = 1;
				};
				initContent = builtins.readFile ./zshrc.sh;
			};
			diff-highlight.enable = true;
			git = {
				enable = true;
				settings = let
					mail = secrets.mail;
					isMail = mail != "";
					name = secrets.name;
					isName = name != "";
				in lib.mkIf osConfig.users.mutableUsers {
					user.email = lib.mkIf isMail mail;
					user.name = lib.mkIf isName name;
				};
			};
		};
	};
}
