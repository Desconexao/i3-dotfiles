#!/bin/sh

set -eu

if [ "${1:-}" != "--apply" ]; then
    printf '%s\n' "Usage: ./install.sh --apply"
    exit 1
fi

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
backup_dir="$HOME/.i3-dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

backup_and_copy() {
    source_path="$1"
    target_path="$2"

    if [ -e "$target_path" ]; then
        mkdir -p "$backup_dir/$(dirname "${target_path#$HOME/}")"
        cp -a "$target_path" "$backup_dir/${target_path#$HOME/}"
    fi

    mkdir -p "$(dirname "$target_path")"
    cp -a "$source_path" "$target_path"
}

backup_and_copy "$repo_dir/.config/i3" "$HOME/.config/i3"
backup_and_copy "$repo_dir/.config/i3blocks" "$HOME/.config/i3blocks"
backup_and_copy "$repo_dir/.config/kitty" "$HOME/.config/kitty"
backup_and_copy "$repo_dir/.config/gtk-3.0" "$HOME/.config/gtk-3.0"
backup_and_copy "$repo_dir/home/.zshrc" "$HOME/.zshrc"

printf '%s\n' "Installed. Existing files were backed up to: $backup_dir"
