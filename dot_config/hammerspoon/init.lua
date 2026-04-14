require("hs.ipc")

local config = require("modules.config")
local windows = require("modules.windows")
local hotkeys = require("modules.hotkeys")

-- Make functions available to `hs -c "..."` from the shell
function moveLaptopUnder(position)
	return windows.moveLaptopUnder(position)
end

function arrangeZenGhostty()
	return windows.arrangeZenGhostty()
end

-- Optional auto-arrange when displays change
if config.autoArrangeOnScreenChange then
	windows.startScreenWatcher()
end

-- Optional hotkeys
hotkeys.bind()
