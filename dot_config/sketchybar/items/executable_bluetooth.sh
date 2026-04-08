#!/usr/bin/env bash

COLOR="$BLUE"

sketchybar --add event bluetooth_change

sketchybar \
	--add item bluetooth right \
	--set bluetooth \
	update_freq=0 \
	updates=on \
	icon="󰂯" \
	icon.color="$COLOR" \
	icon.padding_left=10 \
	label.color="$COLOR" \
	label.padding_right=10 \
	background.height=26 \
	background.corner_radius="$CORNER_RADIUS" \
	background.padding_right=5 \
	background.padding_left=4 \
	background.border_width="$BORDER_WIDTH" \
	background.border_color="$COLOR" \
	background.color="$BAR_COLOR" \
	background.drawing=on \
	script="$PLUGIN_DIR/bluetooth.sh" \
	--subscribe bluetooth bluetooth_change
