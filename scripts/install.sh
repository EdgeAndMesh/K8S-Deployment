#!/bin/sh
set -e

usage() {
	echo "Usage: $(basename "$0") <cloud | edge> <master | worker>"
	exit 1
}

[ "$#" -lt 2 ] && usage

scripts_dir="$(dirname "$0")"
scripts_install_dir="$HOME/.local/bin"
mkdir --parents "$scripts_install_dir"

installation() {
	directory="$1"

	[ ! -d "$directory" ] && return

	find "$directory" -type f \
		| while read -r filepath
		do
			file="$(basename "$filepath")"
			install \
				--mode=755 \
				--verbose \
				"$filepath" "$scripts_install_dir/$file"
		done
}

_install() {
	installation "$scripts_dir/all"
	installation "$scripts_dir/$1/all"
	installation "$scripts_dir/$1/$2"
}

case "$1 $2" in
	"cloud master" | "cloud worker" | "edge master" | "edge worker")
		_install "$1" "$2"
		;;
	*) usage ;;
esac
