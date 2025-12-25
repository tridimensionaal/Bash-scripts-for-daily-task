# Bash scripts for daily tasks

Small, focused bash scripts for common daily workflows.

## Layout
- `scripts/` is the source of truth for all scripts
- `tools/` contains helper utilities (not meant to be on PATH)

## Setup
Create symlinks to `~/bin` so the scripts are on your PATH:

```sh
./tools/link-bin.sh
```

Make sure `~/bin` is in your PATH (usually via `~/.bashrc` or `~/.zshrc`).

## Scripts

### mv-lst-file
Move the most recently modified file from an input directory to an output directory.

```sh
mv-lst-file --input-dir ~/Downloads --output-dir .
```

### mv-lst-d
wrapper for a common preset: move the most recently modified file from `~/Downloads` to the current directory. Usually, the most recently modified file means the latest downloaded.

```sh
mv-lst-d
```

equivalent to:

```sh
mv-lst-file --input-dir ~/Pictures/Screenshots --output-dir .
```


### mv-lst-pic
wrapper for a common preset: move the latest screenshot (from the directory `~/Pictures/Screenshots/` into the current directory with the name `image.png`

```sh
mv-lst-picture
```

equivalent to:

```sh
mv-lst-file --input-dir ~/Pictures/Screenshots --output-dir ./image.png
```
