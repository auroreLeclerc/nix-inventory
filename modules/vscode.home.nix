{ pkgs, ... }:
{
	programs.vscode = {
		enable = true;
		package = pkgs.vscodium;
		profiles.default = {
			extensions = with pkgs.vscode-extensions; [
				ms-ceintl.vscode-language-pack-fr
				ms-python.python
				ms-python.debugpy
				ms-python.pylint
				ms-pyright.pyright
				# ms-azuretools.vscode-docker
				redhat.vscode-yaml
				stylelint.vscode-stylelint
				sonarsource.sonarlint-vscode
				dbaeumer.vscode-eslint
				jnoortheen.nix-ide
				jgclark.vscode-todo-highlight
				timonwong.shellcheck
			];
			userSettings = {
				"window.autoDetectColorScheme" = true;
				"workbench.preferredLightColorTheme" = "Catppuccin Latte";
				"workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
				"editor.tabSize" = 2;
				"diffEditor.ignoreTrimWhitespace" = false;
				"nix.serverPath" = "nixd";
				# "nix.serverPath" = "nil";
				"nix.enableLanguageServer" = true;
				"nix.formatterPath" = "nixfmt";
				"nix.serverSettings.nixd" = {
					"options.nixos.expr" = "${builtins.getFlake "/home/dawn/Documents/Projets/nix-inventory"}.nixosConfigurations.exelo.options";
					"options.home-manager.expr" = "${builtins.getFlake "/home/dawn/Documents/Projets/nix-inventory"}.homeConfigurations.exelo.options";
				};
				"redhat.telemetry.enabled" = false;
				"sonarlint.pathToNodeExecutable" = "${pkgs.nodejs}/bin/node";
				"python.languageServer" = "Jedi";
				"git.autofetch" = true;
				"git.enableSmartCommit" = true;
				"git.confirmSync" = false;
			};
		};
	};
	catppuccin.vscode.profiles.default = {
		enable = true;
		icons.enable = false;
	};
	home.packages = (with pkgs; [ nodejs nixfmt-rfc-style nixd typescript python3 graphviz ]);
}
