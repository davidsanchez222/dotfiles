local config = require("modules.config")
local windows = require("modules.windows")
local window = require("hs.window")

local M = {}

local function bindOne(spec, fn)
	if spec and spec.mods and spec.key then
		hs.hotkey.bind(spec.mods, spec.key, fn)
	end
end

local function isHammerspoon(w)
	local app = w and w:application()
	return app and app:bundleID() == hs.processInfo.bundleID
end

-- Only real app windows, so helper panels (e.g. BTT's) aren't focus targets.
-- If Hammerspoon itself is frontmost (BTT's Open URL activates it), start from
-- the topmost window of any other app.
local function currentAndCandidates()
	local candidates = {}
	for _, w in ipairs(window.orderedWindows()) do
		if w:isStandard() and not isHammerspoon(w) then
			table.insert(candidates, w)
		end
	end

	local w = window.focusedWindow()
	if not w or isHammerspoon(w) then
		w = candidates[1]
	end
	return w, candidates
end

local function focusWest()
	local w, candidates = currentAndCandidates()
	if w and not w:focusWindowWest(candidates, true) then
		w:focus()
	end
end

local function focusEast()
	local w, candidates = currentAndCandidates()
	if w and not w:focusWindowEast(candidates, true) then
		w:focus()
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

	bindOne(config.hotkeys.focusWindowWest, focusWest)
	bindOne(config.hotkeys.focusWindowEast, focusEast)

	-- For BTT's Hyper+H/L when docked: hammerspoon://focuswest, hammerspoon://focuseast
	hs.urlevent.bind("focuswest", function()
		hs.printf("[zen-ghostty] url focusWest")
		focusWest()
	end)
	hs.urlevent.bind("focuseast", function()
		hs.printf("[zen-ghostty] url focusEast")
		focusEast()
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
