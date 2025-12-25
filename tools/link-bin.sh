#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src_dir="$repo_root/scripts"
bin_dir="$HOME/bin"

mkdir -p "$bin_dir"

# remove links that only point to the current repo
for link in "$bin_dir"/*; do
	[ -L "$link" ] || continue
	target="$(readlink "$link")"
	case "$target" in
	"$src_dir"/*)
		rm -f "$link"
		;;
	esac
done

# create the links
for script in "$src_dir"/*; do
	[ -f "$script" ] || continue
	chmod +x "$script"
	ln -sfn "$script" "$bin_dir/$(basename "$script")"
done

printf "linked scripts to %s" "$bin_dir"
