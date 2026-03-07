# shellcheck shell=bash

RSYNC_OPTS=(-e ssh -avh -zz --compress-level=9 --progress --delete-after)

DOCS_EXCLUDES=(
	--exclude='node_modules'
	--exclude='dist'
	--exclude='minimal-manifest*/.repo'
	--exclude='minimal-manifest*/bionic'
	--exclude='minimal-manifest*/development'
	--exclude='minimal-manifest*/external'
	--exclude='minimal-manifest*/hardware'
	--exclude='minimal-manifest*/libcore'
	--exclude='minimal-manifest*/packages'
	--exclude='minimal-manifest*/sdk'
	--exclude='minimal-manifest*/test'
	--exclude='minimal-manifest*/tools'
	--exclude='minimal-manifest*/art'
	--exclude='minimal-manifest*/bootable'
	--exclude='minimal-manifest*/build'
	--exclude='minimal-manifest*/dalvik'
	--exclude='minimal-manifest*/frameworks'
	--exclude='minimal-manifest*/libnativehelper'
	--exclude='minimal-manifest*/out'
	--exclude='minimal-manifest*/prebuilts'
	--exclude='minimal-manifest*/system'
	--exclude='minimal-manifest*/toolchain'
	--exclude='minimal-manifest*/compatibility'
	--exclude='minimal-manifest*/android'
	--exclude='minimal-manifest*/bootstrap.bash'
	--exclude='minimal-manifest*/Android.bp'
	--exclude='minimal-manifest*/Makefile'
)

WITH_GAMES=false
NO_DOWNLOADS=false
DRY_RUN=false
ACTION=""

for arg in "$@"; do
	case $arg in
		push|pull) ACTION="$arg" ;;
		--with-games) WITH_GAMES=true ;;
		--nodownloads) NO_DOWNLOADS=true ;;
		--dry-run) DRY_RUN=true ;;
	esac
done

if [[ "$DRY_RUN" == true ]]; then
	RSYNC_OPTS+=(-n)
	echo "🔍 Mode dry-run activé (aucune modification ne sera effectuée)"
fi

if [[ -z "${BELLUM:-}" ]]; then
	echo "Erreur: Variable BELLUM non définie"
	exit 1
fi

sync_folder() {
	local src="$1" dst="$2"
	shift 2
	rsync "${RSYNC_OPTS[@]}" "$@" "$src" "$dst"
}

REMOTE="dawn@${BELLUM}:/run/media/dawn/bellum/Dawn"

case "$ACTION" in
	'push')
		echo '📤 Beginning Upload 📤'

		sync_folder ~/Documents/ "${REMOTE}/Documents/" "${DOCS_EXCLUDES[@]}"
		sync_folder ~/Games/ "${REMOTE}/Games/" --exclude='*.desktop'
		sync_folder ~/Images/ "${REMOTE}/Images/"
		sync_folder ~/Musique/ "${REMOTE}/Musique/"
		sync_folder ~/Vidéos/ "${REMOTE}/Vidéos/"

		if [[ "$NO_DOWNLOADS" == false ]]; then
			rsync -e ssh -avh -zz --compress-level=9 --progress \
				${DRY_RUN:+-n} \
				~/Téléchargements/ "${REMOTE}/Téléchargements/"
		fi

		echo '📤 Upload finished 📤'
	;;
	'pull')
		echo '📥 Beginning Download 📥'

		sync_folder "${REMOTE}/Documents/" ~/Documents/ "${DOCS_EXCLUDES[@]}"
		if [[ "$WITH_GAMES" == true ]]; then
			sync_folder "${REMOTE}/Games/" ~/Games/ --exclude='*.desktop'
		fi
		sync_folder "${REMOTE}/Images/" ~/Images/
		sync_folder "${REMOTE}/Musique/" ~/Musique/
		sync_folder "${REMOTE}/Vidéos/" ~/Vidéos/

		# Téléchargements toujours exclu en pull

		echo '📥 Download finished 📥'
	;;
	*)
		echo "Usage: $0 {push|pull} [options]"
		echo "  push          - Envoyer les fichiers vers le serveur distant"
		echo "  pull          - Récupérer les fichiers depuis le serveur distant"
		echo ""
		echo "Options:"
		echo "  --with-games  - Inclure Games (exclu par défaut en pull)"
		echo "  --nodownloads - Exclure Téléchargements (push uniquement)"
		echo "  --dry-run     - Prévisualiser les changements sans les appliquer"
		exit 1
	;;
esac
