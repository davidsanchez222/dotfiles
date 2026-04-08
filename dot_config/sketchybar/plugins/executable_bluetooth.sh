#!/usr/bin/env bash

if ! command -v blueutil >/dev/null 2>&1; then
	sketchybar --set "$NAME" drawing=off
	exit 0
fi

CONNECTED="$(blueutil --connected 2>/dev/null)"
if [ -z "$CONNECTED" ]; then
	sketchybar --set "$NAME" drawing=off
	exit 0
fi

HEADPHONE_REGEX='AirPods|Headphones|Bose'
HEADPHONES_ICON="󰋋"

MATCH="$(printf "%s\n" "$CONNECTED" | grep -iE "name: \".*(${HEADPHONE_REGEX}).*\"" | head -n 1)"
if [ -z "$MATCH" ]; then
	sketchybar --set "$NAME" drawing=off
	exit 0
fi

DEVICE="$(printf "%s\n" "$MATCH" | sed -E 's/.*name: "([^"]+)".*/\1/')"

FRONT_APP_DRAWING="$(sketchybar --query front_app 2>/dev/null | jq -r '.geometry.drawing' 2>/dev/null)"
if [ "$FRONT_APP_DRAWING" = "on" ]; then
	ITEM_PADDING_LEFT=14
else
	ITEM_PADDING_LEFT=22
fi

# label="$DEVICE"
sketchybar --set "$NAME" drawing=on icon="󰂯" label="$HEADPHONES_ICON" padding_left=$ITEM_PADDING_LEFT
