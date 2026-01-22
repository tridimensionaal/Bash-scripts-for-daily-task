# Bash scripts for daily tasks


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

A collection of small bash helpers (scripts, functions, and aliases) organized by topic to speed up common workflows.

The project is called "bash scripts for daily tasks" (a legacy name from when it only had scripts). it now includes scripts, functions, and aliases, making it a more complete set of bash helpers organized by topic to speed up common workflows. These helpers are written in bash but also work in zsh.



## Project structure

### modules/

Each module groups related helpers by domain (e.g., `files/`, `python/`). modules can include:

- `scripts/`: Executable bash scripts. These are standalone programs (run as commands).
- `functions/`: Bash files meant to be sourced. They define functions you can call from your shell.
- `aliases/`: A plain file with `alias ...` entries, sourced into your shell.

**Bash script vs function vs alias**
- **script**: Invokes a new shell/process; good for reusable commands and tools.
- **function**: Runs in the current shell context; can share shell state and be used in pipelines.
- **alias**: A short text substitution; best for simple shorthands.

For more details about the current modules see [modules/README.md](./modules/README.md).

### setup/

Contains the initialization script `setup/init`, which:
- detects the repo root and sets `PROJECT_DIR`,
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

This updates your `~/.bashrc` or `~/.zshrc` to source `setup/init`. Open a new shell (or `source` your rc file) to apply the changes.
