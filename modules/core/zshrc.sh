# shellcheck disable=SC2148
if (( ${+functions[p10k]} )) && [[ ! -f ~/.p10k.zsh ]]; then
	p10k configure
elif
	(( ${+functions[p10k]} )) && [[ -f ~/.p10k.zsh ]] &&
	[[ "$TERM_PROGRAM" != 'vscode' ]] && { [[ "$SSH_TTY" ]] || [[ "$DISPLAY" ]]; };
then
	# shellcheck disable=SC1090
	source ~/.p10k.zsh
	case "$(hostname)" in 
		"bellum")
			icon='👩🏻‍🏭';;
		"exelo")
			icon='👩🏻‍💻';;
		"fierce-deity")
			icon='🎮';;
		"midna")
			icon='📼';;
		"kimado")
			icon='🧟‍♀️';;
		*)
			icon='❄️';;
	esac
	# shellcheck disable=SC2034
	POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION="$icon	"
	# https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#i-see-duplicate-typed-characters-after-i-complete-a-command
	# https://github.com/nix-community/home-manager/issues/3711
	motd
else
	powerlevel10k_plugin_unload
	autoload -Uz promptinit
	promptinit
	prompt redhat
fi