#!/bin/sh
set -e

usage() {
	echo "Usage: $(basename "$0") <master | worker>"
	exit 1
}

[ "$#" -lt 1 ] && usage

dotfiles_dir="$(dirname "$0")"

installation() {
	directory="$1"
	find "$directory" -type f \
		| while read -r filepath
		do
			file="$(basename "$0")"
			install --mode=644 --verbose "$filepath" "$HOME/$file"
		done
}

all() {
	installation "$dotfiles_dir/all"
}

master() {
	all
	installation "$dotfiles_dir/master"
}

worker() {
	all
	installation "$dotfiles_dir/worker"
}

case "$1" in
	master) master ;;
	worker) worker ;;
	*)      usage  ;;
esac
