local config = require("modules.config")
local windows = require("modules.windows")
local window = require("hs.window")

local M = {}

local function bindOne(spec, fn)
	if spec and spec.mods and spec.key then
		hs.hotkey.bind(spec.mods, spec.key, fn)
	end
end

function M.bind()
	if not config.hotkeys.enabled then
		return
	end

	bindOne(config.hotkeys.moveUnderLeft, function()
		local _, msg = windows.moveLaptopUnder("left")
		if msg then
			hs.alert.show(msg)
		end
	end)

	bindOne(config.hotkeys.moveUnderMiddle, function()
		local _, msg = windows.moveLaptopUnder("middle")
		if msg then
			hs.alert.show(msg)
		end
	end)

	bindOne(config.hotkeys.moveUnderRight, function()
		local _, msg = windows.moveLaptopUnder("right")
		if msg then
			hs.alert.show(msg)
		end
	end)

	bindOne(config.hotkeys.arrangeZenGhostty, function()
		local _, msg = windows.arrangeZenGhostty()
		if msg then
			hs.alert.show(msg)
		end
	end)

	bindOne(config.hotkeys.focusWindowWest, function()
		local w = window.focusedWindow()
		if w then
			w:focusWindowWest()
		end
	end)

	bindOne(config.hotkeys.focusWindowEast, function()
		local w = window.focusedWindow()
		if w then
			w:focusWindowEast()
		end
	end)

	bindOne(config.hotkeys.focusWindowNorth, function()
		local w = window.focusedWindow()
		if w then
			w:focusWindowNorth()
		end
	end)

	bindOne(config.hotkeys.focusWindowSouth, function()
		local w = window.focusedWindow()
		if w then
			w:focusWindowSouth()
		end
	end)
end

return M
