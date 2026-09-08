# Portable i3 dotfiles

An i3 profile designed to work across laptops and desktops without embedding a
user name, monitor connector, battery name, touchpad identifier or wallpaper
path.

## Install

Review the profile, then run one of:

```sh
./install.sh --check    # syntax and portability checks
./install.sh --dry-run  # show what would be installed
./install.sh --apply    # back up and copy the profile into ~/.config
```

`--apply` creates a timestamped backup at `~/.i3-dotfiles-backup-*` before
updating i3, i3blocks, Kitty, GTK and Zsh files. It copies directory contents,
so a local file not managed by this repository is retained.

## Portable behavior

- Displays are detected with `xrandr`: the primary or internal panel receives
  workspaces 1–4; the first other connected display receives 5–10. The second
  display uses its highest available resolution; set `SECONDARY_MODE` in a
  local `display.local.conf` only when a different mode is desired. On a
  single-display system, every workspace remains on that display.
- Battery status discovers the first `BAT*` device under `/sys/class/power_supply`.
- Touchpad settings are applied to every detected touchpad, when `xinput` is
  installed.
- Terminal, browser and file-manager shortcuts choose an available program.
- Optional features (audio controls, brightness, power profiles, Wi-Fi menu,
  wallpaper and lock-screen enhancements) simply stay unavailable when their
  supporting command does not exist.

## Customize a machine

| Need | File or setting |
| --- | --- |
| Bar font, size and colors | `.config/i3/bar-theme.conf` |
| Bar labels, icons and spacing | `.config/i3blocks/theme` |
| Window title font | `.config/i3/config` (`font ...`) |
| Spacing between windows | `.config/i3/window-gaps.conf` |
| Wallpaper | Create `~/.config/i3/wallpaper` containing one absolute image path |
| Launchers and media keys | `.config/i3/session-tools` |
| Workspace display policy | `.config/i3/update-workspace-outputs.sh` |
| A machine-specific external resolution | `~/.config/i3/display.local.conf` |

The included theme uses `JetBrainsMono Nerd Font`. Install any Nerd Font on a
new machine, then change the single `set $bar_font` line if its family name is
different.

## Dependencies

Core: `i3`, `i3blocks`, `xrandr` and a POSIX shell.

Useful optional programs: `NetworkManager` (`nmcli`, `nm-applet`), `zenity`,
`wpctl`, `brightnessctl`, `powerprofilesctl`, `lm-sensors`, `xinput`, `feh`,
`rofi`, `kitty`, `jq`, `i3lock` and a Nerd Font.
