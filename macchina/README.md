# Applying the config

## Requirements

Make sure that the theme file (`wahid_custom_theme.toml`) is correctly placed and recognized by macchina. You can use the command `macchina --list-themes` to verify that macchina recognizes your theme.

In order for macchina to be able to find your themes, you need to place them in:

- `~/.config/macchina/themes/` on Linux and the BSDs. (or `$XDG_CONFIG_HOME/macchina/themes` if set)
- `$HOME/.config/macchina/themes/` on macOS.
- `%AppData%/macchina/themes/` on Windows.

## Location

In order for macchina to be able to read the configuration file, you need to place `macchina.toml` in:

- `~/.config/macchina/` on Linux and the BSDs. (or `$XDG_CONFIG_HOME/macchina/` if set)
- `$HOME/.config/macchina/` on macOS.
- `%AppData%/macchina/` on Windows.

## Tip

If macchina is not utilizing your configuration file, despite you placing it in the correct location, you should tell macchina where to find it by passing the file's path with with `macchina --config <file_location>`.
