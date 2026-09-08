# Processes domain

Shell helpers for stopping an unresponsive program and its children.
Requires Bash and Linux `pgrep` (procps-ng, with `--ignore-ancestors` support).

## Firefox

```sh
firefox-kill            # send SIGTERM
firefox-kill --force    # send SIGKILL when Firefox stays frozen
```

The alias matches `firefox`, `firefox-bin`, and `firefox-esr`, plus their child
processes even when they have different names. It includes all your matching
instances across profiles. Forced termination can lose unsaved work.

## Other programs

```sh
kill-program chromium
kill-program --force chromium
kill-program --force 'firefox(-bin|-esr)?'
```

Supply one regular expression matched against the whole process name, not the
command line. Linux process names are limited to 15 characters. Quote patterns
containing shell special characters, as in the Firefox example above.

Only your effective user's processes are targeted. The command excludes itself,
its ancestors (including the calling shell). It recursively finds children with
`pgrep -P`, collects their PIDs, then signals children before parents. Children
created after collection and detached helpers with different names may be
missed. It sends the signal without waiting or automatically escalating.

## Enable

Run `./setup.sh --with-examples`, or copy only this domain:

```sh
cp -R example-domains/processes domains/processes
```

Then open a new shell.
