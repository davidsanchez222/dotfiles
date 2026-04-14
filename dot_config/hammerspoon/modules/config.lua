local M = {}

M.autoArrangeOnScreenChange = false

M.apps = {
	zen = "Zen",
	ghostty = "Ghostty",
}

M.raycast = {
	left = { mods = { "alt" }, key = "h" },
	right = { mods = { "alt" }, key = "l" },
	maximize = { mods = { "alt" }, key = "m" },
}

M.timing = {
	appLaunchPollInterval = 0.25,
	appLaunchMaxTries = 20,
	screenPollInterval = 0.20,
	screenPollMaxTries = 20,
	spaceMoveRetryDelay = 0.30,
	spaceMoveMaxTries = 6,
	frontmostRetryDelay = 0.12,
	afterMoveToScreen = 0.20,
	beforeRaycastKey = 0.10,
	secondWindowDelay = 0.45,
	afterMoveToSpace = 0.50,
	afterGotoSpace = 0.60,
	finalReturnDelay = 2.40,
	screenWatcherDelay = 1.00,
}

M.hotkeys = {
	enabled = false,
	moveUnderLeft = { mods = { "ctrl", "alt", "cmd" }, key = "1" },
	moveUnderMiddle = { mods = { "ctrl", "alt", "cmd" }, key = "2" },
	moveUnderRight = { mods = { "ctrl", "alt", "cmd" }, key = "3" },
	arrangeZenGhostty = { mods = { "ctrl", "alt", "cmd" }, key = "0" },
}

return M
