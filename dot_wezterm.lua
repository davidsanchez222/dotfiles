local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.keys = {
	-- {
	--   key = "raw:36",
	--   mods = "SHIFT",
	--   action = wezterm.action.SendString("\033[\015;2u"),
	-- },
	{ key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\033[\015;2u") },
}

-- config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font = wezterm.font("Monaco")
config.font_size = 15
config.initial_rows = 35
config.initial_cols = 120
config.max_fps = 120
config.enable_kitty_graphics = true

config.enable_tab_bar = true

config.window_decorations = "RESIZE"
config.window_background_opacity = 1
config.macos_window_background_blur = 10
config.native_macos_fullscreen_mode = true

config.color_scheme = "Catppuccin Frappe"

return config
