# Terminal config — cmux + Ghostty

[cmux](https://cmux.com) is built on **libghostty** and reads the **Ghostty
config** for themes, fonts, and colors. So terminal appearance lives in
`configs/ghostty/config`, while cmux's own app settings (shortcuts, sidebar,
notifications, automation, browser) live in `configs/cmux/cmux.json`.

## What gets symlinked

| Repo source | Destination | Purpose |
|---|---|---|
| `configs/ghostty/config` | `~/.config/ghostty/config` | theme, font, colors, padding, keybinds |
| `configs/cmux/cmux.json` | `~/.config/cmux/cmux.json` | cmux app settings |

Installed by `scripts/setup.terminal.sh` (wired into `setup.sh`).

## Setting the theme

The theme is a `theme =` line in `configs/ghostty/config`. cmux ships Ayu
variants (`Ayu`, `Ayu Light`, `Ayu Mirage`). This repo uses an adaptive setup
that follows the macOS light/dark appearance:

```
theme = dark:Ayu Mirage,light:Ayu Light
```

To force a single theme instead:

```
theme = Ayu
```

Browse bundled themes at
`/Applications/cmux.app/Contents/Resources/ghostty/themes/` (theme names are
case-sensitive). After editing, reload with **Cmd+Shift+,** in cmux.

## Caveats

- **Config file color definitions take precedence over theme file values.**
- cmux may **rewrite** managed blocks in the Ghostty config when you change the
  appearance (Light/Dark/System) via Settings. Prefer editing the `theme =`
  line directly here to avoid surprises.
- Because cmux writes back to these files, the symlink is **bidirectional** —
  changes you make in the app flow back into the repo (no drift).
