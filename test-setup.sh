#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)
SETUP="$SCRIPT_DIR/setup.sh"
START_MARKER="# ---start_of_bash_scripts_setup---"
END_MARKER="# ---end_of_bash_scripts_setup---"
SUITE_DIR=$(mktemp -d)
trap 'rm -rf "$SUITE_DIR"' EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

capture() {
    set +e
    OUTPUT=$("$@" 2>&1)
    STATUS=$?
    set -e
}

assert_ok() {
    [[ "$STATUS" -eq 0 ]] || fail "$1 (status $STATUS): $OUTPUT"
}

assert_contains() {
    [[ "$1" == *"$2"* ]] || fail "$3: expected '$2' in: $1"
}

write_block() {
    mkdir -p "$(dirname "$1")"
    printf '%s\nsource "/tmp/example/setup/init"\n%s\n' \
        "$START_MARKER" "$END_MARKER" >"$1"
}

test_zsh_target_selection() {
    local home_rc="$SUITE_DIR/home-block/.zshrc"
    local active_rc="$SUITE_DIR/home-block/.config/zsh/.zshrc"
    write_block "$home_rc"

    capture env HOME="$(dirname "$home_rc")" SHELL=/bin/zsh \
        ZDOTDIR="$(dirname "$active_rc")" "$SETUP" --dry-run
    assert_ok "home compatibility block selection"
    assert_contains "$OUTPUT" "$home_rc" "home compatibility target"

    home_rc="$SUITE_DIR/active-block/.zshrc"
    active_rc="$SUITE_DIR/active-block/.config/zsh/.zshrc"
    write_block "$active_rc"
    capture env HOME="$(dirname "$home_rc")" SHELL=/bin/zsh \
        ZDOTDIR="$(dirname "$active_rc")" "$SETUP" --dry-run
    assert_ok "active ZDOTDIR block selection"
    assert_contains "$OUTPUT" "$active_rc" "active ZDOTDIR target"

    mkdir -p "$SUITE_DIR/ambiguous/.config/zsh"
    set +e
    OUTPUT=$(env HOME="$SUITE_DIR/ambiguous" SHELL=/bin/zsh \
        ZDOTDIR="$SUITE_DIR/ambiguous/.config/zsh" "$SETUP" --dry-run </dev/null 2>&1)
    STATUS=$?
    set -e
    [[ "$STATUS" -eq 2 ]] || fail "ambiguous Zsh target was not rejected"
    assert_contains "$OUTPUT" "--rc-file" "ambiguity recovery hint"
}

test_zdotdir_discovery() {
    local test_home="$SUITE_DIR/zshenv-home"
    local active_rc="$test_home/custom-zdotdir/.zshrc"
    mkdir -p "$test_home"
    printf 'export ZDOTDIR="%s"\n' "$(dirname "$active_rc")" >"$test_home/.zshenv"
    write_block "$active_rc"

    capture env -u ZDOTDIR HOME="$test_home" SHELL=/bin/zsh "$SETUP" --dry-run
    assert_ok "ZDOTDIR discovery from .zshenv"
    assert_contains "$OUTPUT" "$active_rc" "discovered ZDOTDIR target"
}

test_malformed_markers_are_safe() {
    local test_home="$SUITE_DIR/malformed"
    local rc_file="$test_home/custom.rc"
    local before
    mkdir -p "$test_home"
    printf '%s\n' "$START_MARKER" >"$rc_file"
    before=$(sha256sum "$rc_file")

    capture env HOME="$test_home" SHELL=/bin/bash "$SETUP" --rc-file "$rc_file"
    [[ "$STATUS" -eq 2 ]] || fail "incomplete marker was not rejected"
    [[ $(sha256sum "$rc_file") == "$before" ]] || fail "malformed rc file changed"
}

test_safe_idempotent_update() {
    local test_home="$SUITE_DIR/symlink-home"
    local target="$test_home/managed/zshrc"
    local link="$test_home/.zshrc"
    local first_copy="$test_home/first-copy"
    mkdir -p "$(dirname "$target")"
    printf '# local content\n' >"$target"
    chmod 640 "$target"
    ln -s "$target" "$link"

    capture env HOME="$test_home" SHELL=/bin/zsh "$SETUP" --rc-file "$link"
    assert_ok "symlink update"
    [[ -L "$link" ]] || fail "setup replaced the rc symlink"
    [[ $(stat -c '%a' "$target") == 640 ]] || fail "setup changed target mode"
    cp "$target" "$first_copy"

    capture env HOME="$test_home" SHELL=/bin/zsh "$SETUP" --rc-file "$link"
    assert_ok "idempotent rerun"
    cmp -s "$first_copy" "$target" || fail "second setup run changed rc content"
    assert_contains "$OUTPUT" "already configured" "idempotent setup message"
}

test_quoted_repository_path() {
    local test_home="$SUITE_DIR/quoted-home"
    local repo_copy="$SUITE_DIR/repo with spaces \$cash \`tick\`"
    local rc_file="$test_home/custom.rc"
    mkdir -p "$repo_copy/setup" "$test_home"
    cp "$SETUP" "$repo_copy/setup.sh"
    printf 'export QUOTED_SOURCE_LOADED=1\n' >"$repo_copy/setup/init"
    chmod +x "$repo_copy/setup.sh"

    capture env HOME="$test_home" SHELL=/bin/bash \
        "$repo_copy/setup.sh" --rc-file "$rc_file"
    assert_ok "quoted repository setup"
    bash -c 'source "$1"; [[ $QUOTED_SOURCE_LOADED == 1 ]]' _ "$rc_file" ||
        fail "Bash could not load the quoted setup path"
    zsh -c 'source "$1"; [[ $QUOTED_SOURCE_LOADED == 1 ]]' _ "$rc_file" ||
        fail "Zsh could not load the quoted setup path"
}

test_bash_dry_run() {
    local test_home="$SUITE_DIR/bash-home"
    mkdir -p "$test_home"
    capture env HOME="$test_home" SHELL=/bin/zsh "$SETUP" --shell bash --dry-run
    assert_ok "Bash dry run"
    assert_contains "$OUTPUT" "$test_home/.bashrc" "Bash target"
    [[ ! -e "$test_home/.bashrc" ]] || fail "dry run created .bashrc"
}

test_zsh_target_selection
test_zdotdir_discovery
test_malformed_markers_are_safe
test_safe_idempotent_update
test_quoted_repository_path
test_bash_dry_run
printf 'setup tests passed\n'
