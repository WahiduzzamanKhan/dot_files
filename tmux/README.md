# Applying the config

## Requirements

Once Tmux is installed, install TPM (Tmux Plugin Manager)

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Location

For Tmux to recognize this config, the file needs to be in one of these locations:

1. `~/.tmux.config`
2. `~/.config/tmux.conf`
3. `$XDG_CONFIG_HOME/tmux/tmux.conf`

Notice that for location 2 and 3, there is no `.` at the begining of the file name.

## Tip

It is also possible to specify an arbitrary location for the configuration when starting with `tmux -f <file_location>`. This works great for specifying alternative configurations that you may need only occasionally.
