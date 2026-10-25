#!/bin/sh
# Shared Xrandr output selection helpers for the i3 display scripts.

connected_outputs() {
    xrandr --query 2>/dev/null | awk '$2 == "connected" {print $1}'
}

primary_output() {
    xrandr --query 2>/dev/null | awk '$2 == "connected" && / primary/ {print $1; exit}'
}

# Prefer the display with the largest mode; use refresh rate to break ties.
best_connected_output() {
    xrandr --query 2>/dev/null | awk '
        function finish() {
            if (output != "" && (pixels > selected_pixels || (pixels == selected_pixels && rate > selected_rate))) {
                selected = output; selected_pixels = pixels; selected_rate = rate
            }
        }
        $2 == "connected" { finish(); output = $1; pixels = 0; rate = 0; next }
        $2 == "disconnected" { finish(); output = ""; next }
        output != "" && /^[[:space:]]+[0-9]+x[0-9]+/ {
            split($1, size, "x"); mode_pixels = size[1] * size[2]; mode_rate = 0
            for (i = 2; i <= NF; i++) { value = $i; gsub(/[+*]/, "", value); if (value + 0 > mode_rate) mode_rate = value + 0 }
            if (mode_pixels > pixels || (mode_pixels == pixels && mode_rate > rate)) { pixels = mode_pixels; rate = mode_rate }
        }
        END { finish(); print selected }
    '
}

main_output() {
    main="$(primary_output)"
    if [ -z "$main" ]; then
        main="$(best_connected_output)"
    fi
    if [ -z "$main" ]; then
        main="$(connected_outputs | head -n 1)"
    fi
    printf '%s\n' "$main"
}
