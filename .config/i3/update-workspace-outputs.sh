#!/bin/sh
# Keep i3 workspaces usable with or without the HDMI-1 display.

set -eu

main_output="eDP-1"
secondary_output="HDMI-1"

# Avoid acting if this is run outside an X/i3 session.
command -v xrandr >/dev/null 2>&1 || exit 0
command -v i3-msg >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

apply_layout() {
    if xrandr --query 2>/dev/null | awk -v output="$secondary_output" '$1 == output && $2 == "connected" { found = 1 } END { exit !found }'; then
        xrandr --output "$secondary_output" --mode 1920x1080 --rate 60 --right-of "$main_output" 2>/dev/null || true
        target_output="$secondary_output"
    else
        # X can retain a disconnected HDMI output as a phantom screen. Turn it
        # off so i3 can return its workspaces to the notebook display.
        xrandr --output "$secondary_output" --off 2>/dev/null || true
        target_output="$main_output"
    fi

    sleep 1

    # Keep every numbered workspace on its intended display. Creating them
    # here ensures the mapping is also correct before first use.
    workspace_data="$(i3-msg -t get_workspaces 2>/dev/null || true)"
    [ -n "$workspace_data" ] || return 0

    move_workspace() {
        workspace="$1"
        output="$2"
        current_output="$(printf '%s\n' "$workspace_data" | jq -r --arg workspace "$workspace" '.[] | select(.name == $workspace) | .output' 2>/dev/null || true)"

        [ "$current_output" = "$output" ] && return 0
        i3-msg -q "workspace number \"$workspace\"; move workspace to output \"$output\"" || true
    }

    # Preserve the workspace that had focus while moving the others.
    focused_workspace="$(printf '%s\n' "$workspace_data" | jq -r '.[] | select(.focused) | .name' 2>/dev/null || true)"

    for workspace in 1 2 3 4; do
        move_workspace "$workspace" "$main_output"
    done

    for workspace in 5 6 7 8 9 10; do
        move_workspace "$workspace" "$target_output"
    done

    if [ -n "$focused_workspace" ]; then
        i3-msg -q "workspace \"$focused_workspace\"" || true
    fi
}

if [ "${1:-}" = "--watch" ]; then
    runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
    lock_file="$runtime_dir/i3-workspace-outputs.lock"
    command -v flock >/dev/null 2>&1 || exit 0
    exec 9>"$lock_file"
    flock -n 9 || exit 0

    apply_layout

    # React only to actual monitor changes. This avoids repeatedly moving
    # workspaces and disturbing the active display session.
    i3-msg -t subscribe '["output"]' | while IFS= read -r _event; do
        apply_layout
    done
else
    apply_layout
fi
