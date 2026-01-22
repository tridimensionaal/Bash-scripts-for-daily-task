# Files module

File and clipboard related helpers.

## Scripts

### clip-to-image
Save the clipboard image to `image.<format>` in the current directory

Requires a clipboard tool: `wl-paste` on Wayland or `xclip` on X11

```sh
clip-to-image
```

**TODO**: test on X11

---

### mv-lst-file
Move the most recently modified file from an input directory to an output
location

```sh
mv-lst-file --input-dir ~/Downloads --output-dir .
```

---

### touch-f
Create a new file with a starter template based on its extension. If the filename has no extension, it creates a bash script and makes it executable

```sh
touch-f script
touch-f script.py
touch-f app.js
touch-f tool.sh
```

## Functions

No functions in this module yet.

## Aliases

- `mv-lst-d` — Move the latest file from `~/Downloads` to the current directory (via `mv-lst-file`)
- `mv-lst-pic` — Move the latest screenshot from `~/Pictures/Screenshots` to `./image.png` (via `mv-lst-file`)
