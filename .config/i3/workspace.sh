#!/bin/sh
# Select the output for a workspace from the current Xrandr layout.
# 1-4 use the Xrandr primary output; 5-10 use another connected output.

set -eu

PRIMARY_WORKSPACES="1 2 3 4"

require_commands() {
    for command in xrandr i3-msg jq; do
        command -v "$command" >/dev/null 2>&1 || exit 1
    done
}

connected_outputs() {
    xrandr --query | awk '$2 == "connected" { print $1 }'
}

primary_output() {
    xrandr --query | awk '$2 == "connected" && / primary/ { print $1; exit }'
}

main_output() {
    main=$(primary_output)
    if [ -z "$main" ]; then
        main=$(connected_outputs | awk '/^(eDP|LVDS|DSI)/ { print; exit }')
    fi
    if [ -z "$main" ]; then
        main=$(connected_outputs | head -n 1)
    fi
    printf '%s\n' "$main"
}

target_output() {
    workspace=$1
    main=$(main_output)
    [ -n "$main" ] || exit 1

    case " $PRIMARY_WORKSPACES " in
        *" $workspace "*) printf '%s\n' "$main" ;;
        *)
            secondary=$(connected_outputs | awk -v main="$main" '$0 != main { print; exit }')
            printf '%s\n' "${secondary:-$main}"
            ;;
    esac
}

focused_workspace() {
    i3-msg -t get_workspaces | jq -r '.[] | select(.focused) | .name' | head -n 1
}

focus_workspace() {
    workspace=$1
    output=$(target_output "$workspace")
    i3-msg -q "workspace number $workspace"
    i3-msg -q "move workspace to output \"$output\""
    i3-msg -q "workspace number $workspace"
}

move_container_to_workspace() {
    workspace=$1
    current=$(focused_workspace)
    focus_workspace "$workspace"
    [ -z "$current" ] || i3-msg -q "workspace \"$current\""
    i3-msg -q "move container to workspace number $workspace"
}

main() {
    require_commands
    [ "$#" -eq 2 ] || exit 2
    case "$1" in
        focus) focus_workspace "$2" ;;
        move) move_container_to_workspace "$2" ;;
        *) exit 2 ;;
    esac
}

main "$@"
