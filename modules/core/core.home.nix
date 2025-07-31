{ pkgs, lib, osConfig, unstablePkgs, myLibs, ... }:
{
	config = {
		home = {
			stateVersion = osConfig.system.stateVersion;
			packages = with pkgs; [ nerd-fonts.meslo-lg ];
			file.docker-compose = lib.mkIf osConfig.virtualisation.docker.rootless.enable { # TODO: move to docker component
				text = let
					s = "    ";
					dns = (myLibs.impureSopsReading osConfig.sops.secrets.dns.path);
					isDns = (dns != "");
				in
				lib.mkIf isDns builtins.readFile ../docker/docker-compose.yml + ''
${s}vaultwarden:
${s}${s}image: vaultwarden/server:latest
${s}${s}container_name: vaultwarden
${s}${s}environment:
${s}${s}${s}PUID: 0
${s}${s}${s}PGID: 0
${s}${s}${s}DOMAIN: "https://vaultwarden.${dns}/"
${s}${s}${s}SIGNUPS_ALLOWED: "false"
${s}${s}volumes:
${s}${s}${s}- /home/dawn/docker/vaultwarden/data:/data
${s}${s}networks:
${s}${s}${s}default:
${s}${s}${s}${s}ipv4_address: 172.18.0.21
${s}${s}restart: unless-stopped''
				;
				target = "docker-compose.yml";
			};
		};
		programs = {
			thefuck = {
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
					plugins = [ "sudo" "node" "npm" "git" "repo" "nvm" "emoji" ];
				};
				localVariables = lib.mkIf osConfig.programs.adb.enable  {
					"export CHROME_EXECUTABLE" = "${pkgs.chromium}/bin/chromium-browser";
					"export CAPACITOR_ANDROID_STUDIO_PATH" = unstablePkgs.android-studio;
					"export JAVA_HOME" = pkgs.jdk;
					"export ANDROID_HOME" = "/home/dawn/Android/Sdk/";
				};
				initContent = ''
					if [[ "$TERM_PROGRAM" != 'vscode' ]] && (( ''${+functions[p10k]} )) && [[ -f ~/.p10k.zsh ]]; then
						source ~/.p10k.zsh
						typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION='${
						{
							"bellum" = "👩🏻‍🏭";
							"exelo" = "👩🏻‍💻";
							"fierce-deity" = "🎮";
							"midna" = "📼";
							"kimado" = "🧟‍♀️";
							"nixos" = "❄️";
						}.${osConfig.networking.hostName}}	'
						# https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#i-see-duplicate-typed-characters-after-i-complete-a-command
						# https://github.com/nix-community/home-manager/issues/3711
						motd
					else
						POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
						autoload -Uz promptinit
						promptinit
						prompt redhat
					fi
				'';
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
