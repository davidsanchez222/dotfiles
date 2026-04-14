local config = require("modules.config")
local windows = require("modules.windows")

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
end

return M
