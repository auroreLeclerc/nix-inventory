# shellcheck disable=SC2148
if (( ${+functions[p10k]} )) && [[ ! -f ~/.p10k.zsh ]]; then
	p10k configure
elif [[ "$TERM_PROGRAM" != 'vscode' ]] && (( ${+functions[p10k]} )) && [[ -f ~/.p10k.zsh ]]; then
	source /home/dawn/.p10k.zsh
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
	# typeset -g 
	# shellcheck disable=SC2034
	POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION="$icon	"
	# https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#i-see-duplicate-typed-characters-after-i-complete-a-command
	# https://github.com/nix-community/home-manager/issues/3711
	motd
else
	# shellcheck disable=SC2034
	POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
	autoload -Uz promptinit
	promptinit
	prompt redhat
fi