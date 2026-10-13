#!/usr/bin/env bash

source "$HOME/.config/sketchybar/variables.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

LABEL_COLOR="$GREEN"

if [ "$PERCENTAGE" = "" ]; then
	exit 0
fi

case ${PERCENTAGE} in
9[0-9] | 100)
	ICON=""
	;;
[6-8][0-9])
	ICON=""
	;;
[3-5][0-9])
	ICON=""
	;;
[1-2][0-9])
	ICON=""
	;;
*) ICON="" ;;
esac

if [ "$CHARGING" != "" ]; then
	ICON=""
fi

if [ "$PERCENTAGE" -lt 11 ]; then
	LABEL_COLOR="$DEEPRED"
elif [ "$PERCENTAGE" -lt 21 ] && [ "$PERCENTAGE" -gt 10 ]; then
	LABEL_COLOR="$YELLOW"
fi

sketchybar --set "$NAME" \
	icon="$ICON" \
	icon.color="$LABEL_COLOR" \
	label="${PERCENTAGE}% " \
	label.color="$LABEL_COLOR" \
	background.border_color="$LABEL_COLOR"
