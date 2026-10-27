#!/bin/sh

set -eu

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
mode="${1:-}"

case "$mode" in
    --check) exec "$repo_dir/tests/smoke.sh" ;;
    --deps)
        printf '%s\n' 'Core: i3 i3blocks xrandr jq'
        printf '%s\n' 'Recommended: kitty NetworkManager zenity libnotify wpctl brightnessctl power-profiles-daemon lm_sensors xinput feh rofi i3lock'
        printf '%s\n' 'Optional: picom dex xss-lock pavucontrol ImageMagick i3lock-color-git and a Nerd Font'
        exit 0
        ;;
    --dry-run|--apply) ;;
    *)
        printf '%s\n' 'Usage: ./install.sh --check | --deps | --dry-run | --apply'
        exit 1
        ;;
esac

if [ "$mode" = --dry-run ]; then
    printf '%s\n' "Would install i3, i3blocks, Kitty, GTK and Zsh files from: $repo_dir"
    exit 0
fi

backup_base="$HOME/.i3-dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
backup_dir="$backup_base"
backup_number=1
while [ -e "$backup_dir" ]; do
    backup_dir="$backup_base-$backup_number"
    backup_number=$((backup_number + 1))
done

preserve_existing_wallpaper() {
    current_config="$HOME/.config/i3/config"
    wallpaper_file="$HOME/.config/i3/wallpaper"
    [ -e "$wallpaper_file" ] && return 0
    [ -r "$current_config" ] || return 0

    wallpaper_path="$(sed -n 's/.*feh --bg-fill //p' "$current_config" | head -n 1)"
    [ -n "$wallpaper_path" ] || return 0
    case "$wallpaper_path" in '~/'*) wallpaper_path="$HOME/${wallpaper_path#~/}" ;; esac
    [ -f "$wallpaper_path" ] || return 0
    printf '%s\n' "$wallpaper_path" > "$wallpaper_file"
}

backup_and_copy() {
    source_path="$1"
    target_path="$2"

    if [ -e "$target_path" ]; then
        mkdir -p "$backup_dir/$(dirname "${target_path#$HOME/}")"
        cp -a "$target_path" "$backup_dir/${target_path#$HOME/}"
    fi

    mkdir -p "$(dirname "$target_path")"
    if [ -d "$source_path" ]; then
        # Copy directory contents instead of creating ~/.config/i3/i3 when the
        # destination already exists.
        mkdir -p "$target_path"
        cp -a "$source_path/." "$target_path/"
    else
        cp -a "$source_path" "$target_path"
    fi
}

preserve_existing_wallpaper
mkdir -p "$backup_dir"
backup_and_copy "$repo_dir/.config/i3" "$HOME/.config/i3"
backup_and_copy "$repo_dir/.config/i3blocks" "$HOME/.config/i3blocks"
backup_and_copy "$repo_dir/.config/kitty" "$HOME/.config/kitty"
backup_and_copy "$repo_dir/.config/gtk-3.0" "$HOME/.config/gtk-3.0"
backup_and_copy "$repo_dir/home/.zshrc" "$HOME/.zshrc"

printf '%s\n' 'Installed: ~/.config/i3, ~/.config/i3blocks, ~/.config/kitty, ~/.config/gtk-3.0 and ~/.zshrc'
printf '%s\n' "Backup directory: $backup_dir"
