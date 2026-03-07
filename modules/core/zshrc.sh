# shellcheck shell=bash
if (( ${+functions[p10k]} )); then
	if [[ ! -f ~/.p10k.zsh ]]; then
		p10k configure
	elif [[ "$TERM_PROGRAM" != 'vscode' ]] && { [[ "$SSH_TTY" ]] || [[ "$DISPLAY" ]]; }; then
		# shellcheck disable=SC1090
		source ~/.p10k.zsh
		case "$HOST" in
			bellum)       icon='👩🏻‍🏭' ;;
			exelo)        icon='👩🏻‍💻' ;;
			fierce-deity) icon='🎮' ;;
			midna)        icon='📼' ;;
			kimado)       icon='🧟‍♀️' ;;
			*)            icon='❄️' ;;
		esac
		# shellcheck disable=SC2034
		POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION="%2g$icon"
		# https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#i-see-duplicate-typed-characters-after-i-complete-a-command
		# https://github.com/nix-community/home-manager/issues/3711
		motd
	fi
else
	(( ${+functions[powerlevel10k_plugin_unload]} )) && powerlevel10k_plugin_unload
	autoload -Uz promptinit
	promptinit
	prompt redhat
fi
