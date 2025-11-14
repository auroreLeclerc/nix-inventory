{ pkgs, lib, osConfig, unstablePkgs, myLibs, ... }:
{
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
				localVariables = lib.mkIf osConfig.programs.adb.enable  {
					"CHROME_EXECUTABLE" = "${pkgs.chromium}/bin/chromium-browser";
					"CAPACITOR_ANDROID_STUDIO_PATH" = unstablePkgs.android-studio;
					"JAVA_HOME" = pkgs.jdk;
					"ANDROID_HOME" = "/home/dawn/Android/Sdk/";
					"ELECTRON_SKIP_BINARY_DOWNLOAD" = 1;
				};
				initContent = builtins.readFile ./zshrc.sh;
			};
			git = let
				mail = (myLibs.impureSopsReading osConfig.sops.secrets.mail.path);
				isMail = (mail != "");
				name = (myLibs.impureSopsReading osConfig.sops.secrets.name.path);
				isName = (mail != "");
			in lib.mkIf osConfig.users.mutableUsers {
				enable = true;
				diff-highlight.enable = true;
				userEmail = lib.mkIf isMail mail;
				userName = lib.mkIf isName name;
			};
		};
	};
}
