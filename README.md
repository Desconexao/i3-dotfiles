# i3 dotfiles

Personal i3 desktop configuration: i3, i3blocks, Kitty, GTK and Zsh.

## Included

- Workspace layout: 1–4 on the notebook display and 5–10 on HDMI.
- HDMI setup at 1920×1080 / 60 Hz when connected.
- i3bar blocks for brightness, volume, battery, power profile, disk, CPU, memory and calendar.
- Kitty startup and Zsh lazy loading configuration.
- GTK dark-theme preference.
- Lock screen and power-menu scripts.

## Install on another desktop

Review the files first, then run:

```sh
./install.sh --apply
```

The installer copies the files to `~/.config` and `~/.zshrc`, backing up any existing version to a timestamped directory in your home folder.

## Required programs

The configuration expects i3, i3blocks, Kitty, Rofi, Zenity, xrandr, brightnessctl, wpctl and pavucontrol.

The lock screen uses a locally installed `i3lock-color` at `~/.local/bin/i3lock-color`; if it is absent, the script falls back to the system `i3lock`.

## Notes

The HDMI output is assumed to be named `HDMI-1` and the internal display `eDP-1`. Update `.config/i3/update-workspace-outputs.sh` if your display names differ.
