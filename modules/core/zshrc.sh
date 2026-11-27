# shellcheck shell=bash

if [[ $(uname -s) == "Darwin" ]]; then
	export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
	export PATH="$HOME/.local/bin:$PATH"
	export ANDROID_HOME="$HOME/Library/Android/sdk"
	export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"
	export GHIDRA_INSTALL_DIR="$HOME/tools/ghidra_12.1.4_PUBLIC"
	export JAVA_HOME="/opt/homebrew/opt/openjdk@25/libexec/openjdk.jdk/Contents/Home"
	export REA_JADX_MCP_JAR="$HOME/tools/jadx-headless-mcp-0.7.1-all.jar"
fi
if [[ ( -z "$SSH_TTY" && -z "$DISPLAY" && -z $TERM_PROGRAM ) || "$TERM_PROGRAM" == 'vscode' ]] || ((! ${+functions[p10k]} )); then
	(( ${+functions[powerlevel10k_plugin_unload]} )) && powerlevel10k_plugin_unload
	autoload -Uz promptinit
	promptinit
	prompt redhat
elif [[ ! -f "$XDG_CONFIG_HOME/zsh/.p10k.zsh" ]]; then
	p10k configure
else
	# shellcheck disable=SC1090
	source "$XDG_CONFIG_HOME/zsh/.p10k.zsh"
	case "$HOST" in
		bellum)       icon='󰼁' ;;
		exelo)        icon='' ;;
		fierce-deity) icon='󰓥' ;;
		midna)        icon='' ;;
		kimado)       icon='󱑷' ;;
		work)         icon='' ;;
		*)            icon='' ;;
	esac
	# shellcheck disable=SC2034
	POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION="$icon"
	motd
fi