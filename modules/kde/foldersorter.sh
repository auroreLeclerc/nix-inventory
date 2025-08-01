#!/usr/bin/env bash

# 'https://doc.ubuntu-fr.org/dossier_magique'

if [ -z "$1" ]; then
	echo "No instructions"
	echo "$0 /path/to/directory"
	exit 1
fi

DIR="$1"
if [ ! -d "$DIR" ]; then
	echo "Can't find '$DIR'"
	exit 1
fi

function move() {
	mkdir -p "${2}"
	mv "${1}" "${2}"
	heure=$(date +%D-%H:%m)
	echo "[${heure}] ""${1}"" ➡️ ""${2}"""
	return 0
}

TXT="${DIR}/Documents"
PDF="${DIR}/Documents/PDF"
AUDIO="${DIR}/Musiques"
MUSICS="${DIR}/Musiques/Compositions"
VIDEO="${DIR}/Vidéos"
SUBTITLES="${DIR}/Vidéos/Sous-titres"
IMG="${DIR}/Images"
SVG="${DIR}/Images/Illustrations"
DISK="${DIR}/Images/Disques"
ARCHIVES="${DIR}/Archives"
DOCS="${DIR}/Documents"
DOC="${DIR}/Documents/Textes"
PPT="${DIR}/Documents/Présentations"
XLS="${DIR}/Documents/Classeurs"
FONTS="${DIR}/Documents/Fonts"
TMPLT="${DIR}/Documents/Modèles"
BOOKS="${DIR}/Documents/Livres"
CODE="${DIR}/Documents/Code"
MISC="${DIR}/Autres"
BIN="${DIR}/Exécutables"

for file in "$DIR"/*; do
	[ -f "$file" ] || continue

	nom=$(basename "$file")
	ext="${nom##*.}"
	ext="${ext,,}"

	case "$ext" in
		crdownload) continue;;
		wma) move "$file" "${AUDIO}";;
		cue|bin|cdr|img) move "$file" "${DISK}";;
		pfi) move "$file" "${SVG}";;
		tsv|csv) move "$file" "${XLS}";;
		aup) move "$file" "${MUSICS}";;
		pls) move "$file" "${AUDIO}";;
		srt) move "$file" "${SUBTITLES}";;
		scala|php|js|css|java|sql|h|c|jnlp|xml|json) move "$file" "${CODE}";;
		*) mime=$(file -bi "$file")
			case "${mime}" in
				*symlink*) continue;;
				*template*) move "$file" "${TMPLT}";;
				*font*) move "$file" "${FONTS}";;
				*script*|*msi*|*exec*) move "$file" "${BIN}";;
				*pdf*|*dvi*) move "$file" "${PDF}";;
				*epub*) move "$file" "${BOOKS}";;
				*html*) move "$file" "${CODE}";;
				*audio*|*ogg*) move "$file" "${AUDIO}";;
				*video*|*flash*) move "$file" "${VIDEO}";;
				*iso*|*zlib*) move "$file" "${DISK}";;
				*svg*|*tiff*|*graphics*) move "$file" "${SVG}";;
				*image*) move "$file" "${IMG}";;
				*bzip*|*x-xz*|*gzip*|*tar*|*compressed*|*rar*|*zip*) move "$file" "${ARCHIVES}";;
				*word*|*text*|*rtf*) move "$file" "${DOC}";;
				*excel*|*spreadsheet*|*csv*) move "$file" "${XLS}";;
				*powerpoint*|*presentation*) move "$file" "${PPT}";;
				*opendocument*) move "$file" "${DOCS}";;
				*) mime=$(file -b "$file")
					mime="${mime,,}"
					case "$mime" in
						*directory*) continue;;
						*byte-compiled*|*apk*|*script*|*calculator*) move "$file" "${BIN}";;
						*disk*) move "$file" "${DISK}";;
						*crlf*) move "$file" "${XLS}";;
						*latex*) move "$file" "${CODE}";;
						*asf*) move "$file" "${VIDEO}";;
						*text*) move "$file" "${TXT}";;
						*) move "$file" "${MISC}";;
					esac
				;;
			esac
		;;
	esac	
done

exit 0