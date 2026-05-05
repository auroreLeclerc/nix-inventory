# shellcheck shell=bash

if [[ ( -z "$SSH_TTY" && -z "$DISPLAY" ) || "$TERM_PROGRAM" == 'vscode' ]] || ((! ${+functions[p10k]} )); then
	(( ${+functions[powerlevel10k_plugin_unload]} )) && powerlevel10k_plugin_unload
	autoload -Uz promptinit
	promptinit
	prompt redhat
elif [[ ! -f ~/.p10k.zsh ]]; then
	p10k configure
else
	# shellcheck disable=SC1090
	source ~/.p10k.zsh
	case "$HOST" in
		bellum)       icon='' ;;
		exelo)        icon='' ;;
		fierce-deity) icon='󰖺' ;;
		midna)        icon='󰟴' ;;
		kimado)       icon='󱍔' ;;
		work)         icon='' ;;
		*)            icon='󰜗' ;;
	esac
	# shellcheck disable=SC2034
	POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION="$icon"
	if [[ "$OSTYPE" != "darwin"* ]]; then
		motd
	fi
fi
