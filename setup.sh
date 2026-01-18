#!/usr/bin/env bash

set -euo pipefail

print_usage() {
    extra_message="${1:-}"

    {
        if [[ -n "$extra_message" ]]; then
            printf "%s\n\n" "$extra_message"
        fi

        cat <<'EOF'
usage: setup.sh

set up shell initialization for this repo by sourcing setup/init
EOF
    } >&2
}

detect_shell() {
    shell_path="${SHELL:-}"
    if [[ -z "$shell_path" ]]; then
        print_usage "SHELL is not set"
        exit 2
    fi

    shell_name="${shell_path##*/}"
    case "$shell_name" in
    bash | zsh)
        printf "%s\n" "$shell_name"
        ;;
    *)
        print_usage "Unsupported shell: $shell_name"
        exit 2
        ;;
    esac
}

ensure_placeholders() {
    file_path="$1"
    start_marker="$2"
    end_marker="$3"
    search_cmd=(rg -Fq)

    if ! command -v rg >/dev/null 2>&1; then
        search_cmd=(grep -Fq)
    fi

    if [[ ! -f "$file_path" ]]; then
        : >"$file_path"
    fi

    has_start=0
    has_end=0
    if "${search_cmd[@]}" "$start_marker" "$file_path"; then
        has_start=1
    fi
    if "${search_cmd[@]}" "$end_marker" "$file_path"; then
        has_end=1
    fi

    if ((has_start && has_end)); then
        return 0
    fi

    if ((has_start || has_end)); then
        print_usage "Placeholder markers are incomplete in $file_path"
        exit 2
    fi

    {
        printf "\n%s\n%s\n" "$start_marker" "$end_marker"
    } >>"$file_path"
}

update_block() {
    file_path="$1"
    start_marker="$2"
    end_marker="$3"
    block_file="$4"

    tmp_file="$(mktemp)"
    awk -v start="$start_marker" -v end="$end_marker" -v block_file="$block_file" '
        $0 == start {
            print $0
            while ((getline line < block_file) > 0) {
                print line
            }
            close(block_file)
            inblock = 1
            next
        }
        $0 == end {
            print $0
            inblock = 0
            updated = 1
            next
        }
        inblock { next }
        { print }
        END {
            if (!updated) { exit 3 }
        }
    ' "$file_path" >"$tmp_file"

    mv "$tmp_file" "$file_path"
}

main() {
    if [[ $# -gt 0 ]]; then
        print_usage "This script takes no arguments"
        exit 2
    fi

    shell_name="$(detect_shell)"
    rc_file="$HOME/.${shell_name}rc"
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    init_path="$repo_root/setup/init"

    if [[ ! -f "$init_path" ]]; then
        print_usage "Init script not found: $init_path"
        exit 2
    fi

    start_marker="# ---start_of_bash_scripts_setup---"
    end_marker="# ---end_of_bash_scripts_setup---"

    ensure_placeholders "$rc_file" "$start_marker" "$end_marker"

    block_file="$(mktemp)"
    cat <<EOF >"$block_file"
# managed by Bash-scripts-for-daily-task (do not edit inside this block)
source "$init_path"
EOF

    update_block "$rc_file" "$start_marker" "$end_marker" "$block_file"
    rm -f "$block_file"

    printf "updated %s to source %s\n" "$rc_file" "$init_path"
}

main "$@"
