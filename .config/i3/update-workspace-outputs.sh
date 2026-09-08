#!/bin/sh
# Assign workspaces to detected displays without relying on connector names.
set -eu

has() { command -v "$1" >/dev/null 2>&1; }
has xrandr && has i3-msg && has jq || exit 0

override_file="$HOME/.config/i3/display.local.conf"
[ ! -r "$override_file" ] || . "$override_file"

connected_outputs() {
    xrandr --query 2>/dev/null | awk '$2 == "connected" {print $1}'
}

main_output() {
    xrandr --query 2>/dev/null | awk '$2 == "connected" && / primary/ {print $1; exit}'
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
    if [ -z "$main" ]; then
        main="$(printf '%s\n' "$outputs" | awk '/^(eDP|LVDS|DSI)/ {print; exit}')"
    fi
    [ -n "$main" ] || main="$(printf '%s\n' "$outputs" | head -n 1)"
    secondary="$(printf '%s\n' "$outputs" | awk -v main="$main" '$0 != main {print; exit}')"

    if [ -n "$secondary" ]; then
        mode="${SECONDARY_MODE:-$(highest_mode "$secondary")}"
        if [ -n "$mode" ]; then
            xrandr --output "$secondary" --mode "$mode" --right-of "$main" 2>/dev/null || xrandr --output "$secondary" --auto --right-of "$main" 2>/dev/null || true
        else
            xrandr --output "$secondary" --auto --right-of "$main" 2>/dev/null || true
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

if [ "${1:-}" = --watch ]; then
    # i3 may start this again after reload; keep only one event subscriber.
    has flock || exit 0
    runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
    lock_file="$runtime_dir/i3-workspace-outputs.lock"
    exec 9>"$lock_file"
    flock -n 9 || exit 0
    apply_layout
    i3-msg -t subscribe '["output"]' | while IFS= read -r _event; do apply_layout; done
else
    apply_layout
fi
