#!/bin/sh
# Assign workspaces to detected displays without relying on connector names.
set -eu

has() { command -v "$1" >/dev/null 2>&1; }
has xrandr && has i3-msg && has jq || exit 0

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$script_dir/display-outputs.sh"

override_file="$HOME/.config/i3/display.local.conf"
[ ! -r "$override_file" ] || . "$override_file"

runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
layout_file="$runtime_dir/i3-display-layout"

layout_mode() {
    [ -r "$layout_file" ] && IFS= read -r mode < "$layout_file" || mode=horizontal
    case "$mode" in horizontal|vertical) printf '%s\n' "$mode" ;; *) printf '%s\n' horizontal ;; esac
}

best_mode_and_rate() {
    xrandr --query 2>/dev/null | awk -v wanted="$1" '
        $1 == wanted && $2 == "connected" { active = 1; next }
        active && /^[^[:space:]]/ { exit }
        active && /^[[:space:]]+[0-9]+x[0-9]+/ {
            split($1, size, "x"); pixels = size[1] * size[2]; mode_rate = 0
            for (i = 2; i <= NF; i++) { value = $i; gsub(/[+*]/, "", value); if (value + 0 > mode_rate) mode_rate = value + 0 }
            if (pixels > best_pixels || (pixels == best_pixels && mode_rate > best_rate)) { mode = $1; best_pixels = pixels; best_rate = mode_rate }
        }
        END { if (mode != "") print mode, best_rate }
    '
}

highest_mode() {
    xrandr --query 2>/dev/null | awk -v output="$1" '
        $1 == output && $2 == "connected" { active = 1; next }
        active && /^[^[:space:]]/ { exit }
        active && /^[[:space:]]+[0-9]+x[0-9]+/ {
            split($1, size, "x")
            pixels = size[1] * size[2]
            if (pixels > best) { best = pixels; mode = $1 }
        }
        END { print mode }
    '
}

apply_layout() {
    outputs="$(connected_outputs)"
    [ -n "$outputs" ] || return 0

    main="$(main_output)"
    secondary="$(printf '%s\n' "$outputs" | awk -v main="$main" '$0 != main {print; exit}')"

    set -- $(best_mode_and_rate "$main")
    if [ "$#" -eq 2 ]; then
        xrandr --output "$main" --mode "$1" --rate "$2" --primary 2>/dev/null || xrandr --output "$main" --auto --primary 2>/dev/null || true
    else
        xrandr --output "$main" --auto --primary 2>/dev/null || true
    fi

    if [ -n "$secondary" ]; then
        mode="${SECONDARY_MODE:-$(highest_mode "$secondary")}" 
        layout="$(layout_mode)"
        if [ "$layout" = vertical ]; then
            placement="--below"
        else
            placement="--right-of"
        fi
        if [ -n "$mode" ]; then
            xrandr --output "$secondary" --mode "$mode" "$placement" "$main" 2>/dev/null || xrandr --output "$secondary" --auto "$placement" "$main" 2>/dev/null || true
        else
            xrandr --output "$secondary" --auto "$placement" "$main" 2>/dev/null || true
        fi
        target="$secondary"
    else
        target="$main"
    fi

    # On a single display all workspaces stay on the detected primary output.
    focused="$(i3-msg -t get_workspaces 2>/dev/null | jq -r '.[] | select(.focused) | .name' 2>/dev/null || true)"
    for workspace in 1 2 3 4; do
        i3-msg -q "workspace number $workspace; move workspace to output $main" || true
    done
    for workspace in 5 6 7 8 9 10; do
        i3-msg -q "workspace number $workspace; move workspace to output $target" || true
    done
    [ -z "$focused" ] || i3-msg -q "workspace \"$focused\""
}

if [ "${1:-}" = --toggle ]; then
    case "$(layout_mode)" in horizontal) printf '%s\n' vertical > "$layout_file" ;; *) printf '%s\n' horizontal > "$layout_file" ;; esac
    apply_layout
elif [ "${1:-}" = --watch ]; then
    # i3 may start this again after reload; keep only one event subscriber.
    has flock || exit 0
    runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
    lock_file="$runtime_dir/i3-workspace-outputs.lock"
    exec 9>"$lock_file"
    flock -n 9 || exit 0
    apply_layout
    i3-msg -t subscribe -m '["output"]' | while IFS= read -r _event; do apply_layout; done
else
    apply_layout
fi
