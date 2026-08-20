# Git module

Short helpers for common Git commands.

## Functions

### gd

Show a diff using Git's normal pager behavior, or print it directly when
`--no-pager` is the first argument. Other diff arguments are passed through.

```sh
gd
gd --staged
gd --no-pager
gd --no-pager --staged
```

## Aliases

- `gs` — Show the working tree status.
- `gp` — Push the current branch, or pass a remote and branch explicitly.
- `gpl` — Pull only when Git can fast-forward without creating a merge commit.
- `gdiscard` — Discard unstaged changes in one or more tracked files.

```sh
gs
gp
gp origin main
gpl
gpl origin main
gdiscard README.md
```
