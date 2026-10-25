#!/bin/sh
# Minimal regression checks for the portable i3 profile.
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

for script in "$repo_dir"/.config/i3/* "$repo_dir"/.config/i3blocks/* "$repo_dir"/install.sh; do
    [ -f "$script" ] || continue
    case "$(head -n 1 "$script" 2>/dev/null)" in '#!'*) sh -n "$script" ;; esac
done

for file in \
    .config/i3/config \
    .config/i3/bar-theme.conf \
    .config/i3/display-outputs.sh \
    .config/i3/quick-controls \
    .config/i3/shortcuts \
    .config/i3/storage-menu \
    .config/i3/wallpaper-picker \
    .config/i3/session-tools \
    .config/i3/display.local.conf.example \
    .config/i3/window-gaps.conf \
    .config/i3/update-workspace-outputs.sh \
    .config/i3blocks/config \
    .config/i3blocks/status \
    .config/i3blocks/theme \
    .config/i3blocks/wifi-menu; do
    test -f "$repo_dir/$file"
done

if rg -n '/home/[[:alnum:]_-]+|BAT0|HDMI-[0-9]|eDP-[0-9]|VEN_[0-9A-F]+' "$repo_dir/.config"; then
    printf '%s\n' 'smoke: machine-specific value found in portable configuration' >&2
    exit 1
fi

if command -v i3 >/dev/null 2>&1; then
    test_home="$(mktemp -d)"
    trap 'rm -rf "$test_home"' EXIT HUP INT TERM
    ln -s "$repo_dir/.config" "$test_home/.config"
    HOME="$test_home" XDG_RUNTIME_DIR="$test_home" i3 -C -c "$repo_dir/.config/i3/config"
fi

printf '%s\n' 'smoke: ok'
