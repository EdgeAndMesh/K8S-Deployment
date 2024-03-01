#!/bin/sh
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

base_directory="$(dirname "$0")"

for cast in "$base_directory/casts"/*.cast
do
	filename="$(basename "$cast")"
	output_file="$base_directory/gifs/$filename.gif"
	if [ -f "$output_file" ]
	then
		echo "${YELLOW}File: $output_file already generated${RESET}"
	fi
	[ -f "$output_file" ] && continue
	aggw "$cast" "$output_file"
done

echo "${GREEN}Done converting generating all gifs${RESET}"
