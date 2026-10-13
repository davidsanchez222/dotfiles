local M = {}

M.autoArrangeOnScreenChange = true

M.dock = {
	monitorName = "AW3426DWM",
}

M.btt = {
	dockedVariable = "hs_docked",
	actions = {
		moveWindowRight = 152, -- Move Window One Space or Desktop Right
		spaceLeft = 527, -- Move Left a Space (Without Animation)
	},
}

M.karabiner = {
	cli = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli",
	dockedVariable = "hs_docked",
}

M.apps = {
	zen = "Zen",
	ghostty = "Ghostty",
}

-- Undocked: other windows on Desktop 1 get maximized behind Zen, except these
M.keepSizeApps = { "Finder" }

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
	afterGotoSpace = 0.60,
	afterBttAction = 0.60,
	otherWindowDelay = 0.35,
	screenWatcherDelay = 1.00,
}

M.hotkeys = {
	enabled = true,
	moveUnderLeft = { mods = { "ctrl", "alt", "cmd" }, key = "1" },
	moveUnderMiddle = { mods = { "ctrl", "alt", "cmd" }, key = "2" },
	moveUnderRight = { mods = { "ctrl", "alt", "cmd" }, key = "3" },
	arrangeZenGhostty = { mods = { "ctrl", "alt", "cmd" }, key = "0" },
	focusWindowWest = { mods = { "cmd", "shift" }, key = "h" },
	focusWindowEast = { mods = { "cmd", "shift" }, key = "l" },
	focusWindowNorth = { mods = { "cmd", "shift" }, key = "k" },
	focusWindowSouth = { mods = { "cmd", "shift" }, key = "j" },
}

return M
