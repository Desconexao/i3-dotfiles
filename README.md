# i3 dotfiles

A keyboard-driven i3 desktop with a compact status bar, themed Rofi menus and
quick access to everyday controls. Includes configurations for i3, i3blocks,
Kitty, GTK and Zsh.

## Features

- Dark Rofi theme shared by the application launcher and desktop menus.
- Control center for network, audio, brightness, power, displays and wallpaper.
- Compact, neutral status bar with volume and microphone mute controls.
- Wired-first network indicator and a Wi-Fi selector with signal strength.
- Storage indicators with a clickable summary of mounted disks.
- Wallpaper picker with a local image copy restored on login.
- Automatic workspace placement across one or two displays.
- Configuration backups before installation.

## Installation

Install the [dependencies](#dependencies), then clone the repository:

```sh
git clone https://github.com/Desconexao/i3-dotfiles.git
cd i3-dotfiles
```

Review the configuration, especially `home/.zshrc`, then run:

```sh
./install.sh --check    # syntax and portability checks
./install.sh --dry-run  # show what would be installed
./install.sh --apply    # back up and copy the profile into ~/.config
```

`--apply` creates a unique timestamped backup at `~/.i3-dotfiles-backup-*`
before updating i3, i3blocks, Kitty, GTK and Zsh files. It copies directory
contents, so a local file not managed by this repository is retained.

Run the installer as your regular user, without `sudo`. It copies configuration
files; it does not install packages, fonts or an i3 session. The bundled Zsh
configuration replaces `~/.zshrc` and expects Oh My Zsh, the `agnosterzak` theme
and additional plugins. Adjust its personal tool paths before applying it.

Select the i3 session at the login screen after installation.

## Display behavior

- Displays are detected with `xrandr`: the primary display receives workspaces
  1–4; without a primary flag, the display with the largest mode is selected,
  using refresh rate to break ties. The first other connected display receives
  5–10. The second
  display uses its highest available resolution; set `SECONDARY_MODE` in a
  local `display.local.conf` only when a different mode is desired. On a
  single-display system, every workspace remains on that display.
- `Super+Shift+M` alternates between side-by-side and stacked displays.

## Keybindings

`Super` is the Windows/Command key. Some bindings use an ABNT-style keyboard
layout; adjust them in `.config/i3/config` for your keyboard.

| Shortcut | Action |
| --- | --- |
| `Super+Enter` | Open terminal |
| `Super+D` | Application launcher |
| `Super+B` | Open browser |
| `Super+F` | Open file manager |
| `Super+Ctrl+Space` | Control center |
| `Super+Shift+/` | Shortcut reference |
| `Super+1–0` | Switch workspace |
| `Super+Shift+1–0` | Move window to workspace |
| `Super+Shift+M` | Toggle display arrangement |
| `Super+Shift+X` | Lock screen |
| `Super+Shift+P` | Session and power menu |
| `Super+Shift+C` | Reload configuration |

## Desktop controls

Desktop menus share the palette, spacing and selection styles in
`.config/i3/menu.rasi`. This theme also applies to the application launcher.

- Choose **Wallpaper** in quick controls to select an image. A local copy is
  saved and restored on login, including when the original image is on a hard drive.
- Volume, brightness and power-profile keys show a brief notification when
  `notify-send` is available.
- Click the network block to choose a Wi-Fi network from a compact Rofi list
  showing signal strength, security and the current connection. Wired Ethernet
  is shown first whenever it is active.
- Click the volume or microphone icon to toggle mute. Scroll over volume to
  adjust it.
- Click a storage indicator to view free space across mounted disks. The
  optional DLinux indicator appears when a disk is mounted at `/mnt/DLinux`.

## Customization

| Need | File or setting |
| --- | --- |
| Bar font, size and colors | `.config/i3/bar-theme.conf` |
| Bar labels, icons and spacing | `.config/i3blocks/theme` |
| Status block spacing and order | `.config/i3blocks/config` |
| Desktop menu appearance | `.config/i3/menu.rasi` |
| Window title font | `.config/i3/config` (`font ...`) |
| Spacing between windows | `.config/i3/window-gaps.conf` |
| Wallpaper | Quick controls → Wallpaper; saved selection in `~/.config/i3/wallpaper` |
| Launchers and media keys | `.config/i3/session-tools` |
| Workspace display policy | `.config/i3/update-workspace-outputs.sh` |
| A machine-specific external resolution | `~/.config/i3/display.local.conf` |

The bar and window titles use `JetBrainsMono Nerd Font`; Kitty uses FiraCode
Nerd Font and Rofi uses Noto Sans. Install these fonts or update the respective
settings. Set `BAR_USE_NERD_ICONS=0` in `.config/i3blocks/theme` for text labels.

## Dependencies

Core: i3 with gap support, `i3blocks`, `xrandr`, `jq`, `flock` and a POSIX shell.
Validation also requires `ripgrep` (`rg`).

| Feature | Programs |
| --- | --- |
| Menus and image selection | `rofi`, `zenity` |
| Terminal | `kitty` or `i3-sensible-terminal` |
| Network controls | NetworkManager (`nmcli`, `nm-applet`, `nm-connection-editor`) |
| Audio | `wpctl`; `pavucontrol` for advanced settings |
| Brightness | `brightnessctl` |
| Power profiles | `powerprofilesctl` |
| Notifications | `notify-send` and a notification daemon |
| Wallpaper | `feh` |
| Screen locking | `i3lock`; optionally `xss-lock` and ImageMagick |
| Temperature | `sensors` from lm-sensors |
| Touchpad setup | `xinput` |
| Desktop autostart | `dex` |

`./install.sh --deps` lists dependency suggestions. Package names vary between
distributions; install the programs needed by the features you use.

## Compatibility

This configuration targets i3 on X11. Ubuntu 26.04 has not been tested, and
there is no distribution-specific dependency installer. Enhanced screen
locking includes Arch-specific detection and a font path that may need
adjusting on other distributions; plain `i3lock` is the fallback.

`./install.sh --check` checks shell syntax, selected portability rules and the
i3 configuration when i3 is installed. It does not validate Zsh settings or
confirm that every optional feature is available.
