#!/bin/sh
set -e

usage() {
	echo "Usage: $(basename "$0") <cloud | edge> <master | worker>"
	exit 1
}

[ "$#" -lt 2 ] && usage

dotfiles_dir="$(dirname "$0")"

installation() {
	directory="$1"

	[ ! -d "$directory" ] && return

	find "$directory" -type f \
		| while read -r filepath
		do
			file="$(echo "$filepath" | sed 's|'"$directory/"'||')"
			install --mode=644 --verbose "$filepath" "$HOME/$file"
		done
}

_install() {
	installation "$dotfiles_dir/all"
	installation "$dotfiles_dir/$1/all"
	installation "$dotfiles_dir/$1/$2"
}

case "$1 $2" in
	"cloud master" | "cloud worker" | "edge master" | "edge worker")
		_install "$1" "$2"
		;;
	*) usage ;;
esac
