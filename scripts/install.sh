#!/bin/sh
set -e

usage() {
	echo "Usage: $(basename "$0") <master | worker>"
	exit 1
}

[ "$#" -lt 1 ] && usage

scripts_dir="$(dirname "$0")"
scripts_install_dir="$HOME/.local/bin"
mkdir --parents "$scripts_install_dir"

installation() {
	directory="$1"
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

all() {
	installation "$scripts_dir/all"
}

master() {
	all
	installation "$scripts_dir/master"
}

worker() {
	all
	installation "$scripts_dir/worker"
}

case "$1" in
	master) master ;;
	worker) worker ;;
	*)      usage  ;;
esac
