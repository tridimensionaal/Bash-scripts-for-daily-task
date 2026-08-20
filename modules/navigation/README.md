# Navigation module

Helpers for moving around the filesystem.

## Functions

### pj

Change to `~/projects`, or to a named directory inside it.

```sh
pj
pj rainfrog
```

When Zsh completion is initialized, project names complete relative to
`~/projects`:

```sh
pj rai<Tab>
```
