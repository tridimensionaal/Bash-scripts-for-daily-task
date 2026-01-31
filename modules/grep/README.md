# Grep module

Small `grep`-based helpers.

## Functions

### hgrep

Search your shell history file at `$HISTFILE` (as set in your current shell).

It strips zsh `EXTENDED_HISTORY` prefixes and skips bash timestamp lines, so you search only the commands.

```sh
hgrep @
hgrep -i 'github.com'
```
