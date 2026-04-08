#!/usr/bin/env zsh

if ! command -v blueutil >/dev/null 2>&1; then
	exit 0
fi

PIDFILE="/tmp/sketchybar-bluetooth-monitor.pid"

if [ -f "$PIDFILE" ]; then
	PID="$(cat "$PIDFILE" 2>/dev/null)"
	if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
		kill "$PID" 2>/dev/null
	fi
fi

echo $$ > "$PIDFILE"

PIDS=()

cleanup() {
	rm -f "$PIDFILE"
	for pid in "${PIDS[@]}"; do
		kill "$pid" 2>/dev/null
	done
}

trap cleanup EXIT

HEADPHONE_REGEX='AirPods|Headphones|Bose'

PAIRED_MATCHES="$(blueutil --paired 2>/dev/null | grep -iE "name: \".*(${HEADPHONE_REGEX}).*\"")"
if [ -z "$PAIRED_MATCHES" ]; then
	exit 0
fi

printf "%s\n" "$PAIRED_MATCHES" | while IFS= read -r line; do
	ID="$(printf "%s\n" "$line" | sed -E 's/address: ([^,]+).*/\1/')"
	if [ -z "$ID" ]; then
		continue
	fi

	(
		while true; do
			CONNECTED="$(blueutil --is-connected "$ID" 2>/dev/null)"
			if [ "$CONNECTED" = "1" ]; then
				blueutil --wait-disconnect "$ID" >/dev/null 2>&1
			else
				blueutil --wait-connect "$ID" >/dev/null 2>&1
			fi
			sketchybar --trigger bluetooth_change
		done
	) &
	PIDS+=("$!")
done

sketchybar --trigger bluetooth_change

wait
