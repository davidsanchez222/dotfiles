#!/usr/bin/env sh

# Color scheme toggle:
# catppuccin-for-light | catppuccin-for-dark | gruvbox-for-light | gruvbox-for-dark
# COLORSCHEME="${COLORSCHEME:-catppuccin-for-light}"
# COLORSCHEME="${COLORSCHEME:-catppuccin-for-dark}"
# COLORSCHEME="${COLORSCHEME:-gruvbox-for-light}"
COLORSCHEME="${COLORSCHEME:-gruvbox-for-dark}"

# Widget pill background: transparent | dark-translucent
# PILL_BACKGROUND="${PILL_BACKGROUND:-transparent}"
PILL_BACKGROUND="${PILL_BACKGROUND:-dark-translucent}"

case "$COLORSCHEME" in
catppuccin-for-light|catpuccin-for-light)
	BLACK=0xffeff1f5     # Latte base
	WHITE=0xff4c4f69     # Latte text
	MAGENTA=0xff8839ef   # Mauve
	BLUE=0xff1e66f5      # Blue
	CYAN=0xff179299      # Teal
	GREEN=0xff40a02b     # Green
	YELLOW=0xffdf8e1d    # Yellow
	ORANGE=0xfffe640b    # Peach
	RED=0xffd20f39       # Red
	DEEPRED=0xffa30a2a   # Deep red
	COMMENT=0xff6c6f85   # Subtext0
	BAR_COLOR=0x00000000
	POPUP_BACKGROUND_COLOR=0xAAeff1f5
	;;
catppuccin-for-dark|catpuccin-for-dark)
	BLACK=0xff303446     # Frappe base
	WHITE=0xffc6d0f5     # Frappe text
	MAGENTA=0xffca9ee6   # Mauve
	BLUE=0xff8caaee      # Blue
	CYAN=0xff99d1db      # Sky
	GREEN=0xffa6d189     # Green
	YELLOW=0xffe5c890    # Yellow
	ORANGE=0xffef9f76    # Peach
	RED=0xffe78284       # Red
	DEEPRED=0xffea3323   # Deep red
	COMMENT=0xff737994   # Subtext0
	BAR_COLOR=0x00000000
	POPUP_BACKGROUND_COLOR=0xAA303446
	;;
gruvbox-for-light)
	BLACK=0xfff2e5bc     # Light background
	WHITE=0xff3c3836     # Dark foreground
	MAGENTA=0xff8f3f71   # Purple
	BLUE=0xff076678      # Blue
	CYAN=0xff427b58      # Aqua
	GREEN=0xff79740e     # Green
	YELLOW=0xffb57614    # Yellow
	ORANGE=0xffaf3a03    # Orange
	RED=0xff9d0006       # Red
	DEEPRED=0xffcc241d   # Deep red
	COMMENT=0xff7c6f64   # Grey
	BAR_COLOR=0x00000000
	POPUP_BACKGROUND_COLOR=0xAAf2e5bc
	;;
gruvbox-for-dark|*)
	BLACK=0xff282828     # Background
	WHITE=0xffd4be98     # Foreground
	MAGENTA=0xffd3869b   # Purple
	BLUE=0xff7daea3      # Blue
	CYAN=0xff89b482      # Aqua
	GREEN=0xffa9b665     # Green
	YELLOW=0xffd8a657    # Yellow
	ORANGE=0xffe78a4e    # Orange
	RED=0xffea6962       # Red
	DEEPRED=0xffc14a4a   # Deep red
	COMMENT=0xff928374   # Grey
	BAR_COLOR=0x00000000
	POPUP_BACKGROUND_COLOR=0xAA282828
	;;
esac

case "$PILL_BACKGROUND" in
dark-translucent)
	ITEM_BACKGROUND_COLOR=0xDD1d2021
	;;
transparent|*)
	ITEM_BACKGROUND_COLOR=$BAR_COLOR
	;;
esac

# Transparent bar background
# BAR_COLOR=0xff1a1b26

TRANSPARENT=0x00000000

# General bar colors
ICON_COLOR=$WHITE    # Color of all icons
LABEL_COLOR=$WHITE   # Color of all labels

# Popups
POPUP_BORDER_WIDTH=2
POPUP_CORNER_RADIUS=11
POPUP_BORDER_COLOR=$COMMENT

# Font and padding
FONT="Hack Nerd Font"
PADDINGS=3

# Bar styling
CORNER_RADIUS=15
BORDER_WIDTH=2
SHADOW=on

# Paths
ITEM_DIR="$HOME/.config/sketchybar/items"
PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
