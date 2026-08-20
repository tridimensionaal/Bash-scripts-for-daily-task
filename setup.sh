#!/usr/bin/env bash

set -euo pipefail

START_MARKER="# ---start_of_shellbox_setup---"
END_MARKER="# ---end_of_shellbox_setup---"
shell_override=""
rc_override=""
dry_run=0
load_examples=0
tmp_file=""

print_usage() {
    extra_message="${1:-}"

    {
        if [[ -n "$extra_message" ]]; then
            printf "%s\n\n" "$extra_message"
        fi

        cat <<'EOF'
usage: setup.sh [--shell zsh|bash] [--rc-file PATH] [--dry-run] [--with-examples]

set up shell initialization for this repo by sourcing setup/init

--with-examples also loads the bundled example domains
EOF
    } >&2
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --shell)
            [[ $# -ge 2 && "$2" != --* ]] || {
                print_usage "--shell requires a value"
                exit 2
            }
            shell_override="$2"
            shift
            ;;
        --rc-file)
            [[ $# -ge 2 && "$2" != --* ]] || {
                print_usage "--rc-file requires a value"
                exit 2
            }
            rc_override="$2"
            shift
            ;;
        --dry-run)
            dry_run=1
            ;;
        --with-examples)
            load_examples=1
            ;;
        *)
            print_usage "unknown argument: $1"
            exit 2
            ;;
        esac
        shift
    done
}

detect_shell() {
    local shell_path="${shell_override:-${SHELL:-}}"
    local shell_name
    if [[ -z "$shell_path" ]]; then
        print_usage "SHELL is not set"
        exit 2
    fi

    shell_name="${shell_path##*/}"
    case "$shell_name" in
    zsh | bash)
        printf "%s\n" "$shell_name"
        ;;
    *)
        print_usage "unsupported shell: $shell_name"
        exit 2
        ;;
    esac
}

discover_zdotdir() {
    local output
    local discovered

    if [[ -n "${ZDOTDIR:-}" ]]; then
        printf '%s\n' "$ZDOTDIR"
        return 0
    fi

    if command -v zsh >/dev/null 2>&1; then
        output=$(zsh -c 'printf "\n__SHELLBOX_ZDOTDIR__%s\n" "${ZDOTDIR:-$HOME}"') || true
        discovered=$(awk '
            index($0, "__SHELLBOX_ZDOTDIR__") == 1 {
                value = substr($0, length("__SHELLBOX_ZDOTDIR__") + 1)
            }
            END { print value }
        ' <<<"$output")
        if [[ -n "$discovered" ]]; then
            printf '%s\n' "$discovered"
            return 0
        fi
    fi

    printf '%s\n' "$HOME"
}

marker_state() {
    local file_path=$1

    if [[ ! -e "$file_path" && ! -L "$file_path" ]]; then
        printf 'absent\n'
        return 0
    fi

    awk -v start="$START_MARKER" -v end="$END_MARKER" '
        $0 == start {
            starts++
            if (ends > 0) malformed = 1
        }
        $0 == end {
            ends++
            if (starts != 1 || ends != 1) malformed = 1
        }
        END {
            if (starts == 0 && ends == 0) {
                print "absent"
            } else if (starts == 1 && ends == 1 && !malformed) {
                print "complete"
            } else {
                print "malformed"
            }
        }
    ' "$file_path"
}

select_rc_file() {
    local shell_name=$1
    local zdotdir
    local active_rc
    local compatibility_rc="$HOME/.zshrc"
    local active_state
    local compatibility_state
    local choice

    if [[ -n "$rc_override" ]]; then
        printf '%s\n' "$rc_override"
        return 0
    fi

    if [[ "$shell_name" == bash ]]; then
        printf '%s\n' "$HOME/.bashrc"
        return 0
    fi

    zdotdir=$(discover_zdotdir)
    active_rc="$zdotdir/.zshrc"
    if [[ "$active_rc" == "$compatibility_rc" ]]; then
        printf '%s\n' "$active_rc"
        return 0
    fi

    active_state=$(marker_state "$active_rc")
    compatibility_state=$(marker_state "$compatibility_rc")

    if [[ "$active_state" == malformed ]]; then
        print_usage "managed block markers are malformed in $active_rc"
        return 2
    fi
    if [[ "$compatibility_state" == malformed ]]; then
        print_usage "managed block markers are malformed in $compatibility_rc"
        return 2
    fi

    if [[ "$active_state" == complete && "$compatibility_state" == complete ]]; then
        print_usage "managed blocks exist in both Zsh candidates; choose one with --rc-file"
        return 2
    fi
    if [[ "$active_state" == complete ]]; then
        printf '%s\n' "$active_rc"
        return 0
    fi
    if [[ "$compatibility_state" == complete ]]; then
        printf '%s\n' "$compatibility_rc"
        return 0
    fi

    if [[ ! -t 0 ]]; then
        print_usage "Zsh uses $active_rc, but $compatibility_rc is also available; choose one with --rc-file"
        return 2
    fi

    {
        printf 'Choose the Zsh startup file to update:\n'
        printf '  1) %s (active ZDOTDIR file)\n' "$active_rc"
        printf '  2) %s (local compatibility file; the active config must source it)\n' "$compatibility_rc"
        printf 'Selection [1-2]: '
    } >&2
    IFS= read -r choice
    case "$choice" in
    1) printf '%s\n' "$active_rc" ;;
    2) printf '%s\n' "$compatibility_rc" ;;
    *)
        print_usage "invalid selection: ${choice:-<empty>}"
        return 2
        ;;
    esac
}

cleanup_temp() {
    if [[ -n "$tmp_file" && -e "$tmp_file" ]]; then
        rm -f -- "$tmp_file"
    fi
}

resolve_target() {
    local file_path=$1

    if [[ -L "$file_path" ]]; then
        realpath -e -- "$file_path" || {
            print_usage "cannot update dangling symlink: $file_path"
            return 2
        }
        return 0
    fi

    realpath -m -- "$file_path"
}

quote_source_path() {
    local value=$1
    local init_arg=" --domains-only"

    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    value=${value//\$/\\\$}
    value=${value//\`/\\\`}
    if ((load_examples)); then
        init_arg=" --with-examples"
    fi
    printf 'source "%s"%s\n' "$value" "$init_arg"
}

print_managed_block() {
    local init_path=$1

    printf '%s\n' "$START_MARKER"
    printf '%s\n' '# managed by Shellbox (do not edit inside this block)'
    quote_source_path "$init_path"
    printf '%s\n' "$END_MARKER"
}

render_updated_file() {
    local source_file=$1
    local output_file=$2
    local init_path=$3
    local state=$4
    local line
    local in_block=0

    if [[ "$state" == absent ]]; then
        if [[ -f "$source_file" ]]; then
            cat -- "$source_file" >"$output_file"
        fi
        if [[ -s "$output_file" ]]; then
            printf '\n' >>"$output_file"
        fi
        print_managed_block "$init_path" >>"$output_file"
        return 0
    fi

    : >"$output_file"
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "$START_MARKER" ]]; then
            print_managed_block "$init_path" >>"$output_file"
            in_block=1
            continue
        fi
        if [[ "$line" == "$END_MARKER" ]]; then
            in_block=0
            continue
        fi
        if ((in_block == 0)); then
            printf '%s\n' "$line" >>"$output_file"
        fi
    done <"$source_file"
}

install_block() {
    local logical_path=$1
    local init_path=$2
    local state=$3
    local resolved_path
    local target_dir
    local rendered_state
    local mode="domains-only"

    if ((load_examples)); then
        mode="with-examples"
    fi

    resolved_path=$(resolve_target "$logical_path") || return $?
    target_dir=$(dirname "$resolved_path")
    mkdir -p -- "$target_dir"

    printf 'selected %s\n' "$logical_path"
    if [[ -L "$logical_path" ]]; then
        printf 'resolved symlink target %s\n' "$resolved_path"
    fi

    tmp_file=$(mktemp "$target_dir/.shellbox-setup.XXXXXX")
    if [[ -e "$resolved_path" ]]; then
        chmod --reference="$resolved_path" "$tmp_file"
    fi

    render_updated_file "$resolved_path" "$tmp_file" "$init_path" "$state"
    rendered_state=$(marker_state "$tmp_file")
    if [[ "$rendered_state" != complete ]]; then
        print_usage "failed to render a valid managed block for $logical_path"
        return 2
    fi

    if [[ -e "$resolved_path" ]] && cmp -s -- "$resolved_path" "$tmp_file"; then
        rm -f -- "$tmp_file"
        tmp_file=""
        printf 'already configured %s (%s mode)\n' "$logical_path" "$mode"
        return 0
    fi

    mv -- "$tmp_file" "$resolved_path"
    tmp_file=""
    printf 'updated %s to source %s (%s mode)\n' \
        "$logical_path" "$init_path" "$mode"
}

main() {
    local shell_name
    local rc_file
    local repo_root
    local init_path
    local domains_path
    local state
    local action
    local mode="domains-only"
    local resolved_path

    trap cleanup_temp EXIT HUP INT TERM
    parse_args "$@"

    if ((load_examples)); then
        mode="with-examples"
    fi

    if [[ -z "${HOME:-}" ]]; then
        print_usage "HOME is not set"
        exit 2
    fi

    if [[ -n "$rc_override" && -z "$shell_override" ]]; then
        shell_name=""
    else
        shell_name="$(detect_shell)"
    fi
    rc_file=$(select_rc_file "$shell_name") || exit $?
    repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    init_path="$repo_root/setup/init"
    domains_path="$repo_root/domains"

    if [[ ! -f "$init_path" ]]; then
        print_usage "init script not found: $init_path"
        exit 2
    fi

    state=$(marker_state "$rc_file")
    if [[ "$state" == malformed ]]; then
        print_usage "managed block markers are malformed in $rc_file"
        exit 2
    fi

    if ((dry_run)); then
        action=add
        [[ "$state" == complete ]] && action=update
        printf "would %s %s to source %s (%s mode)\n" \
            "$action" "$rc_file" "$init_path" "$mode"
        if [[ -L "$rc_file" ]]; then
            resolved_path=$(resolve_target "$rc_file") || exit $?
            printf 'resolved symlink target %s\n' "$resolved_path"
        fi
        return 0
    fi

    mkdir -p "$domains_path"
    install_block "$rc_file" "$init_path" "$state"
}

main "$@"
