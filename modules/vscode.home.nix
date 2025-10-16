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
				redhat.java
				vscjava.vscode-java-debug
				redhat.vscode-yaml
				stylelint.vscode-stylelint
				# sonarsource.sonarlint-vscode
				dbaeumer.vscode-eslint
				jnoortheen.nix-ide
				jgclark.vscode-todo-highlight
				timonwong.shellcheck
				davidanson.vscode-markdownlint
			];
			userSettings = {
				"window.autoDetectColorScheme" = true;
				"workbench.preferredLightColorTheme" = "Catppuccin Latte";
				"workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
				"editor.tabSize" = 2;
				"diffEditor.ignoreTrimWhitespace" = false;
  			"nix.enableLanguageServer" = true;
				"nix.serverPath" = "nil";
				"redhat.telemetry.enabled" = false;
				"sonarlint.pathToNodeExecutable" = "${pkgs.nodejs}/bin/node";
				"sonarlint.disableTelemetry" = true;
				"python.languageServer" = "Jedi";
				"git.autofetch" = true;
				"git.enableSmartCommit" = true;
				"git.confirmSync" = false;
  			"[css].editor.defaultFormatter" = "stylelint.vscode-stylelint";
				"java.debug.settings.vmArgs" = "-ea";
  			"java.jdt.ls.java.home" = pkgs.jdk17;
			};
		};
	};
	catppuccin.vscode.profiles.default = {
		enable = true;
		icons.enable = false;
	};
	home.packages = (with pkgs; [ nodejs electron nixfmt-rfc-style nixd typescript python3 graphviz sops jdk17 ]);
}
