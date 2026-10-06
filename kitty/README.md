# Applying the config

## Location

The default location for the config file is `~/.config/kitty/kitty.conf`.

But by using the `KITTY_CONFIG_DIRECTORY` environment variable you can control where kitty looks for `kitty.conf`.

## Tip

It is also possible to specify an arbitrary location for the configuration when starting with `kitty --config <file_location>`.

# Install / update script

`install.sh` installs kitty if it is missing (Homebrew cask, or the official installer if Homebrew isn't available). If kitty is already installed, it checks for a newer version and asks before upgrading. Then it replaces the default app icon.

```
./install.sh                         # uses kitty.app.icns or kitty.app.png next to the script
./install.sh --icon ~/path/icon.icns  # or pass an icon explicitly
```

The icon is copied to `~/.config/kitty/kitty.app.{icns,png}`. kitty reapplies it on every launch, so the custom icon stays after upgrades.
