# Shellbox

A Zsh-first collection of scripts, functions, and aliases for everyday tasks.


## Index
- [Project description](#project-description)
- [Project structure](#project-structure)
  - [modules/](#modules)
    - [scripts/](#scripts)
    - [functions/](#functions)
    - [aliases/](#aliases)
  - [Setup/](#setup)
- [How to setup](#how-to-setup)

---

## Project description

Shellbox is a personal toolkit of small shell helpers organized by topic. Zsh
is the primary interactive environment, so functions and aliases are designed
with Zsh use in mind. Existing helpers remain compatible with Bash where that
does not add meaningful complexity.

Standalone commands currently use Bash as their interpreter. They run normally
from Zsh and do not depend on the user's interactive shell.



## Project structure

### modules/

Each module groups related helpers by domain (e.g., `files/`, `python/`). modules can include:

- `scripts/`: Executable standalone programs, currently written in Bash.
- `functions/`: Shell files meant to be sourced. They define functions you can call from Zsh.
- `aliases/`: A plain file with `alias ...` entries, sourced into your shell.

**Script vs function vs alias**
- **script**: Invokes a new shell/process; good for reusable commands and tools.
- **function**: Runs in the current shell context; can share shell state and be used in pipelines.
- **alias**: A short text substitution; best for simple shorthands.

For more details about the current modules see [modules/README.md](./modules/README.md).

### setup/

Contains the initialization script `setup/init`, which:
- detects the repo root and sets `SHELLBOX_DIR`,
- ensures `bin/` exists and is on `PATH`,
- symlinks module scripts into `bin/`,
- sources module functions and aliases.

This file is meant to be sourced by your shell. The `setup.sh` script wires that into your shell startup file.

---

## How to setup

Run the setup script once:

```sh
./setup.sh
```

The script detects your current shell and updates its startup file to source
`setup/init`. It keeps using an existing managed block, so rerunning it is safe.

For Zsh, the active target is `${ZDOTDIR:-$HOME}/.zshrc`. When Zsh uses a
non-default `ZDOTDIR` and neither possible file has a managed block, setup asks
whether to update the active file or the compatibility file at `~/.zshrc`.

Useful overrides:

```sh
./setup.sh --dry-run
./setup.sh --shell zsh
./setup.sh --rc-file "$HOME/.zshrc"
```

`--rc-file` is useful when a tracked XDG Zsh configuration sources a machine-local `~/.zshrc`: the integration stays out of the dotfiles repository. In scripts or other non-interactive environments, use `--rc-file` whenever the two Zsh targets are ambiguous.

Bash remains supported for the existing cross-shell helpers. Select it
explicitly with `./setup.sh --shell bash`; its default target is `~/.bashrc`.

Open a new shell, or source the selected startup file, to apply the changes.
