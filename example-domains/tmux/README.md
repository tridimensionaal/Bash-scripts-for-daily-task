# Tmux domain

Helpers for starting tmux workflows.

## Scripts

### tmux-main

Create or connect to a session named `main`. On first creation it starts
`htop` in window `0`, creates a shell in window `1` using the current
directory, and selects the shell window.

```sh
tmux-main
```

Outside tmux, running it again reuses the existing `main` session without
creating duplicate windows. If another differently named tmux session exists,
it still creates or attaches to `main`.

When run from inside any tmux session, it exits without creating or switching
sessions.

Requires `tmux` and `htop`.
