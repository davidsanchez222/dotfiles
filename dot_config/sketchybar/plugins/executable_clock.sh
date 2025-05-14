#!/usr/bin/env bash

# LABEL=$(date '+%H:%M:%S')
# LABEL=$(date '+%I:%M:%S %p')
LABEL=$(date '+%I:%M %p')
sketchybar --set "$NAME" label="$LABEL"

