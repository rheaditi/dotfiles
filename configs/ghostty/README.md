# Ghostty / cmux Configuration

Terminal appearance config. **cmux** is built on libghostty and reads
`~/.config/ghostty/config` for themes, fonts, and colors, so this single file
drives both Ghostty and cmux. Symlinked by `scripts/setup.terminal.sh`.

## Files

- **`config`** — theme, font, window, cursor, and scrollback settings.

## Highlights

- **Theme** — adaptive: `dark:Ayu Mirage,light:Ayu Light` switches with macOS
  light/dark appearance. Force one with `theme = Ayu`.
- **Font** — Fira Code, size 14, with ligatures (`calt`/`liga`/`dlig`) explicit
  to match VS Code's `editor.fontLigatures`. Installed via the Brewfile
  (`font-fira-code`).
- **Window** — Ghostty's own tab bar is hidden (`window-show-tab-bar = never`)
  since cmux provides its own vertical tab sidebar.

## Reloading

- cmux: **Cmd+Shift+,**
- Ghostty: **Cmd+,**

## Notes

- cmux has its own config file (`configs/cmux/cmux.json`) for behavior unrelated
  to rendering; appearance lives here.
- cmux's highest-precedence appearance file is
  `~/Library/Application Support/com.cmuxterm.app/config.ghostty`. We keep
  `theme=` out of that file so this repo's config wins. Prefer editing the
  `theme =` line here rather than via the GUI (the GUI can rewrite its managed
  block).
