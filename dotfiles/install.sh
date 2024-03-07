#!/bin/sh
set -e

usage() {
	echo "Usage: $(basename "$0") <master | worker>"
	exit 1
}

[ "$#" -lt 1 ] && usage

dotfiles_dir="$(dirname "$0")"

all() {
	find "$dotfiles_dir/all" -type f \
		| while read -r file
		do
			install --mode=644 "$file" "$HOME/$file"
		done
}

master() {
	all
	find "$dotfiles_dir/master" -type f \
		| while read -r file
		do
			install --mode=644 "$file" "$HOME/$file"
		done
}

worker() {
	all
	find "$dotfiles_dir/worker" -type f \
		| while read -r file
		do
			install --mode=644 "$file" "$HOME/$file"
		done
}

case "$1" in
	master) master ;;
	worker) worker ;;
	*)      usage  ;;
esac
