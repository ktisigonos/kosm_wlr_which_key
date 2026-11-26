# kosm_wlr_which_key

wlr-which-key for kosm: the colors, font and frame of its menu.

The app sets each set option by name in `~/.config/wlr-which-key/config.yaml` through the
`yaml` adapter (`kosm_yaml`) and changes nothing else, so the menu and the other settings stay
yours. Every set option's key must be in the file already; a missing one fails the apply,
naming it. wlr-which-key reads its config each time it opens, so no reload is needed.

`from(theme)` sets the background from the theme's background role at its `background_alpha`,
the text from the foreground role and the frame from the accent. The font and the frame's
sizes are left alone.

`kosm doctor` checks that wlr-which-key is installed, as the `wlr-which-key` command.

## Fields

| Field | Default |
|---|---|
| `file` | `~/.config/wlr-which-key/config.yaml` |
| `format` | `#rrggbbaa` colors |
| `font` | null: left as it is; a Pango description, families then size: `"Iosevka, Noto Sans 14"` |
| `background`, `color`, `border` | null: left as it is |
| `border_width`, `corner_r` | null: left as it is; pixels |
