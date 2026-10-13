local config = require("modules.config")
local spaces = require("hs.spaces")

local M = {}

local screenWatcher = nil
local karabinerWatcher = nil

local function appName(which)
	return config.apps[which]
end

local logFile = os.getenv("HOME") .. "/.config/hammerspoon/zen-ghostty.log"

local function logf(fmt, ...)
	local line = string.format("[zen-ghostty] " .. fmt, ...)
	hs.printf("%s", line)
	local f = io.open(logFile, "a")
	if f then
		f:write(os.date("%H:%M:%S "), line, "\n")
		f:close()
	end
end

M.logf = logf

-- Mirror Lua errors from callbacks/timers into the log file too
local origShowError = hs.showError
hs.showError = function(err)
	logf("LUA ERROR: %s", tostring(err))
	return origShowError(err)
end

local function sendRaycast(binding)
	hs.eventtap.keyStroke(binding.mods, binding.key, 200000)
end

local function getBuiltinAndExternal()
	local builtin, external

	for _, screen in ipairs(hs.screen.allScreens()) do
		local name = screen:name() or ""

		if name:match("Built%-in") or name:match("Color LCD") then
			builtin = screen
		else
			if not external then
				external = screen
			end
		end
	end

	return builtin, external
end

local function getBuiltinScreen()
	local builtin = getBuiltinAndExternal()
	return builtin or hs.screen.primaryScreen()
end

local function getDockMonitor()
	for _, screen in ipairs(hs.screen.allScreens()) do
		if (screen:name() or ""):find(config.dock.monitorName, 1, true) then
			return screen
		end
	end
	return nil
end

function M.isDocked()
	return getDockMonitor() ~= nil
end

local function bttAction(actionType, callback)
	local json = string.format('{"BTTPredefinedActionType":%d}', actionType)
	local script = string.format('tell application "BetterTouchTool" to trigger_action %q', json)
	hs.task.new("/usr/bin/osascript", function(code)
		logf("BTT action %d exit=%s", actionType, tostring(code))
		if callback then
			callback()
		end
	end, { "-e", script }):start()
end

local function setBttDocked(docked)
	local value = docked and "1" or "0"
	local script = string.format(
		'tell application "BetterTouchTool" to set_persistent_string_variable "%s" to "%s"',
		config.btt.dockedVariable,
		value
	)
	-- Async: a blocking AppleScript call can deadlock with BTT opening hammerspoon:// URLs
	hs.task.new("/usr/bin/osascript", function(code)
		logf("set BTT %s=%s exit=%s", config.btt.dockedVariable, value, tostring(code))
	end, { "-e", script }):start()
end

-- Karabiner rewrites Hyper+H/L to Cmd+Shift+H/L while this is 1
local function setKarabinerDocked(docked)
	local vars = string.format('{"%s":%d}', config.karabiner.dockedVariable, docked and 1 or 0)
	hs.task.new(config.karabiner.cli, function(code)
		logf("set Karabiner %s exit=%s", vars, tostring(code))
	end, { "--set-variables", vars }):start()
end

local function setDockedFlags(docked)
	setKarabinerDocked(docked)
	setBttDocked(docked)
end

local function findWindowForApp(appNameValue)
	local app = hs.appfinder.appFromName(appNameValue)
	if app then
		local fallbackWin
		for _, win in ipairs(app:allWindows() or {}) do
			if win:isStandard() then
				return win, app
			end
			fallbackWin = fallbackWin or win
		end
		if fallbackWin then
			return fallbackWin, app
		end
	end

	local fallbackWin, fallbackApp
	for _, win in ipairs(hs.window.allWindows()) do
		local winApp = win:application()
		if winApp and winApp:name() == appNameValue then
			if win:isStandard() then
				return win, winApp
			end
			fallbackWin = fallbackWin or win
			fallbackApp = fallbackApp or winApp
		end
	end

	return fallbackWin, fallbackApp
end

local function countWindowsForApp(appNameValue)
	local count = 0
	for _, win in ipairs(hs.window.allWindows()) do
		local app = win:application()
		if app and app:name() == appNameValue then
			count = count + 1
		end
	end
	return count
end

local function launchAndGetWindow(appNameValue, callback, triesLeft, failCallback)
	triesLeft = triesLeft or config.timing.appLaunchMaxTries

	hs.application.launchOrFocus(appNameValue)

	hs.timer.doAfter(config.timing.appLaunchPollInterval, function()
		local win, app = findWindowForApp(appNameValue)
		local count = countWindowsForApp(appNameValue)

		if win then
			logf("found window for %s (count=%s)", appNameValue, tostring(count))
			callback(win, app)
			return
		end

		if triesLeft > 1 then
			launchAndGetWindow(appNameValue, callback, triesLeft - 1, failCallback)
		else
			logf("no window for %s (count=%s)", appNameValue, tostring(count))
			hs.alert.show("No window for " .. appNameValue)
			if failCallback then
				failCallback()
			end
		end
	end)
end

local function moveWindowToScreen(win, screen, label)
	if not win or not screen then
		return false, "Missing window or screen for " .. (label or "window")
	end

	win:moveToScreen(screen, false, true)
	logf("moved %s to screen %s", label or "window", screen:name() or "unknown")
	return true, "Moved " .. (label or "window") .. " to screen"
end

local function focusWindowThen(win, app, appNameValue, label, afterDelay, fn)
	local nameForCheck = appNameValue or (app and app:name())

	if app then
		app:activate(true)
	else
		logf("no app instance for %s", label or "window")
	end

	if win then
		win:raise():focus()
		logf("focused %s", label or "window")
	else
		logf("no window to focus for %s", label or "window")
	end

	hs.timer.doAfter(afterDelay or config.timing.beforeRaycastKey, function()
		local front = hs.application.frontmostApplication()
		if nameForCheck and front and front:name() ~= nameForCheck then
			logf("frontmost is %s, retrying focus for %s", front:name(), nameForCheck)
			if app then
				app:activate(true)
			end
			if win then
				win:raise():focus()
			end
			if fn then
				hs.timer.doAfter(config.timing.frontmostRetryDelay, fn)
			end
			return
		end

		if fn then
			fn()
		end
	end)
end

local function waitForWindowOnScreen(win, targetScreen, label, triesLeft, callback)
	triesLeft = triesLeft or config.timing.screenPollMaxTries

	if not win or not targetScreen then
		if callback then
			callback(false)
		end
		return
	end

	local currentScreen = win:screen()
	if currentScreen and currentScreen:id() == targetScreen:id() then
		logf("%s is on target screen", label or "window")
		if callback then
			callback(true)
		end
		return
	end

	if triesLeft <= 1 then
		logf("%s did not reach target screen", label or "window")
		if callback then
			callback(false)
		end
		return
	end

	hs.timer.doAfter(config.timing.screenPollInterval, function()
		waitForWindowOnScreen(win, targetScreen, label, triesLeft - 1, callback)
	end)
end


local function userSpacesForScreen(screen)
	local ids = spaces.spacesForScreen(screen) or {}
	local out = {}

	for _, spaceID in ipairs(ids) do
		if spaces.spaceType(spaceID) == "user" then
			table.insert(out, spaceID)
		end
	end

	return out
end

local function orderedSpacesForScreen(screen)
	local ids = userSpacesForScreen(screen)
	if #ids < 2 then
		return ids
	end

	logf("space order from spacesForScreen: %s", table.concat(ids, ","))
	return ids
end

function M.moveLaptopUnder(position)
	local laptop, wide = getBuiltinAndExternal()

	if not laptop or not wide then
		return false, "Need laptop display + one external display"
	end

	local okPrimary = laptop:setPrimary()
	if not okPrimary then
		return false, "Could not set laptop as primary"
	end

	local lf = laptop:fullFrame()
	local wf = wide:fullFrame()

	local targetX
	if position == "left" then
		targetX = 0
	elseif position == "middle" then
		targetX = math.floor((lf.w - wf.w) / 2)
	elseif position == "right" then
		targetX = lf.w - wf.w
	else
		return false, "Argument must be left, middle, or right"
	end

	local targetY = -wf.h
	local okMove = wide:setOrigin(targetX, targetY)

	if not okMove then
		return false, "Could not move external display"
	end

	return true, "Laptop is primary; external is above; alignment = " .. position
end

local function arrangeOnExternal(onDone)
	local external = getDockMonitor()
	if not external then
		return false, "Dock monitor not found"
	end

	local function done()
		if onDone then
			hs.timer.doAfter(config.timing.secondWindowDelay, onDone)
		end
	end

	logf("arranging on external display")

	local function startGhostty()
		launchAndGetWindow(appName("ghostty"), function(ghosttyWin, ghosttyApp)
			local _, msg = moveWindowToScreen(ghosttyWin, external, "Ghostty")
			if msg then
				logf("%s", msg)
			end

			hs.timer.doAfter(config.timing.afterMoveToScreen, function()
				waitForWindowOnScreen(ghosttyWin, external, "Ghostty", nil, function()
					focusWindowThen(ghosttyWin, ghosttyApp, appName("ghostty"), "Ghostty", config.timing.beforeRaycastKey, function()
						sendRaycast(config.raycast.right)
						logf("sent Option+L to Ghostty")
						done()
					end)
				end)
			end)
		end, nil, function()
			logf("ghostty window not found")
			done()
		end)
	end

	launchAndGetWindow(appName("zen"), function(zenWin, zenApp)
		local _, msg = moveWindowToScreen(zenWin, external, "Zen")
		if msg then
			logf("%s", msg)
		end

		hs.timer.doAfter(config.timing.afterMoveToScreen, function()
			waitForWindowOnScreen(zenWin, external, "Zen", nil, function()
				focusWindowThen(zenWin, zenApp, appName("zen"), "Zen", config.timing.beforeRaycastKey, function()
					sendRaycast(config.raycast.left)
					logf("sent Option+H to Zen")
					hs.timer.doAfter(config.timing.secondWindowDelay, startGhostty)
				end)
			end)
		end)
	end, nil, function()
		logf("zen window not found")
		hs.timer.doAfter(config.timing.secondWindowDelay, startGhostty)
	end)

	hs.alert.show("Zen left, Ghostty right on ultrawide")
	return true, "Zen left, Ghostty right on ultrawide"
end

local function arrangeOnLaptopOnly(onDone)
	local builtin = getBuiltinScreen()
	local userSpaces = orderedSpacesForScreen(builtin)

	local function done()
		if onDone then
			onDone()
		end
	end

	logf("laptop-only: screen=%s userSpaces=%s active=%s", builtin and builtin:name() or "nil",
		table.concat(userSpaces, ","), tostring(spaces.activeSpaceOnScreen(builtin)))
	for _, name in ipairs({ appName("zen"), appName("ghostty") }) do
		local w = findWindowForApp(name)
		logf("  %s window=%s screen=%s", name, tostring(w and w:id()),
			w and w:screen() and w:screen():name() or "nil")
	end

	if #userSpaces < 2 then
		logf("laptop-only: fewer than 2 user spaces, aborting")
		done()
		return false, "Need at least 2 user spaces on laptop display"
	end

	local space1 = userSpaces[1]
	local space2 = userSpaces[2]

	logf("arranging on laptop spaces %s and %s", tostring(space1), tostring(space2))

	-- hs.spaces.moveWindowToSpace silently fails on macOS 14.5+, so BTT moves the
	-- focused window one Desktop right (it follows the window there)
	local function returnToSpace1()
		bttAction(config.btt.actions.spaceLeft, function()
			hs.timer.doAfter(config.timing.afterBttAction, function()
				local zenWin, zenApp = findWindowForApp(appName("zen"))
				focusWindowThen(zenWin, zenApp, appName("zen"), "Zen", config.timing.beforeRaycastKey, function()
					hs.alert.show("Zen in Desktop 1, Ghostty in Desktop 2")
					done()
				end)
			end)
		end)
	end

	local function maximizeGhosttyOnSpace2()
		launchAndGetWindow(appName("ghostty"), function(ghosttyWin, ghosttyApp)
			logf("ghostty focused space=%s", tostring(spaces.focusedSpace()))
			focusWindowThen(ghosttyWin, ghosttyApp, appName("ghostty"), "Ghostty", config.timing.beforeRaycastKey, function()
				sendRaycast(config.raycast.maximize)
				logf("sent Option+M to Ghostty")
				hs.timer.doAfter(config.timing.secondWindowDelay, returnToSpace1)
			end)
		end, nil, done)
	end

	local function moveAndFocusGhostty()
		launchAndGetWindow(appName("ghostty"), function(ghosttyWin, ghosttyApp)
			focusWindowThen(ghosttyWin, ghosttyApp, appName("ghostty"), "Ghostty", config.timing.beforeRaycastKey, function()
				-- Focusing switches to the window's Desktop, so this tells us where it is
				local current = spaces.focusedSpace()
				logf("ghostty is on space %s", tostring(current))
				if current == space2 then
					maximizeGhosttyOnSpace2()
					return
				end

				logf("BTT: move Ghostty one Desktop right")
				bttAction(config.btt.actions.moveWindowRight, function()
					hs.timer.doAfter(config.timing.afterBttAction, maximizeGhosttyOnSpace2)
				end)
			end)
		end, nil, done)
	end

	local function moveAndFocusZen()
		launchAndGetWindow(appName("zen"), function(zenWin, zenApp)
			focusWindowThen(zenWin, zenApp, appName("zen"), "Zen", config.timing.beforeRaycastKey, function()
				logf("zen is on space %s", tostring(spaces.focusedSpace()))
				sendRaycast(config.raycast.maximize)
				logf("sent Option+M to Zen")
				hs.timer.doAfter(config.timing.secondWindowDelay, moveAndFocusGhostty)
			end)
		end, nil, done)
	end

	-- Maximize every other window on Desktop 1 first, so Zen ends up on top
	local function maximizeOthers(queue)
		local win = table.remove(queue, 1)
		if not win then
			moveAndFocusZen()
			return
		end

		local app = win:application()
		focusWindowThen(win, app, app and app:name(), app and app:name(), config.timing.beforeRaycastKey, function()
			sendRaycast(config.raycast.maximize)
			logf("sent Option+M to %s", app and app:name() or "?")
			hs.timer.doAfter(config.timing.otherWindowDelay, function()
				maximizeOthers(queue)
			end)
		end)
	end

	local skip = { [appName("zen")] = true, [appName("ghostty")] = true, Hammerspoon = true }
	for _, name in ipairs(config.keepSizeApps) do
		skip[name] = true
	end

	local others = {}
	for _, win in ipairs(hs.window.orderedWindows()) do
		local app = win:application()
		local screen = win:screen()
		if win:isStandard() and app and not skip[app:name()] and screen and screen:id() == builtin:id() then
			table.insert(others, win)
		end
	end
	logf("other windows to maximize: %d", #others)

	maximizeOthers(others)

	return true, "Arranging Zen/Ghostty on laptop spaces"
end

function M.arrangeZenGhostty(onDone)
	if M.isDocked() then
		return arrangeOnExternal(onDone)
	else
		return arrangeOnLaptopOnly(onDone)
	end
end

local function removeExtraLaptopSpaces(callback)
	local builtin = getBuiltinScreen()
	local userSpaces = userSpacesForScreen(builtin)
	local function done()
		if callback then
			callback()
		end
	end

	if #userSpaces < 2 then
		done()
		return
	end

	local keep = userSpaces[1]

	-- Windows on removed Desktops land on Desktop 1, where the external arrangement picks them up
	local function removeRest()
		for i = 2, #userSpaces do
			local ok, err = spaces.removeSpace(userSpaces[i], true)
			logf("remove laptop space %s ok=%s %s", tostring(userSpaces[i]), tostring(ok), tostring(err or ""))
		end
		hs.timer.doAfter(config.timing.afterGotoSpace, done)
	end

	if spaces.activeSpaceOnScreen(builtin) ~= keep then
		-- BTT's instant switch avoids the Mission Control animation of gotoSpace
		bttAction(config.btt.actions.spaceLeft, function()
			hs.timer.doAfter(config.timing.afterBttAction, removeRest)
		end)
	else
		removeRest()
	end
end

local function ensureLaptopSpaces(count, callback)
	local builtin = getBuiltinScreen()
	local have = #userSpacesForScreen(builtin)

	for _ = have + 1, count do
		local ok, err = spaces.addSpaceToScreen(builtin, true)
		logf("add laptop space ok=%s %s", tostring(ok), tostring(err or ""))
	end

	logf("laptop spaces now: %s", table.concat(userSpacesForScreen(builtin), ","))
	hs.timer.doAfter(config.timing.afterGotoSpace, callback)
end

local lastDocked = nil
local busy = false
local busyTimeout = nil

local finishTransition

local function applyDockState()
	local docked = M.isDocked()
	if docked == lastDocked then
		return
	end

	if busy then
		logf("dock state changed while busy; will re-check")
		return
	end

	lastDocked = docked
	busy = true
	logf("dock transition: docked=%s", tostring(docked))
	setDockedFlags(docked)

	-- Safety net in case an arrangement step never calls back
	busyTimeout = hs.timer.doAfter(20, finishTransition)

	if docked then
		removeExtraLaptopSpaces(function()
			arrangeOnExternal(finishTransition)
		end)
	else
		ensureLaptopSpaces(2, function()
			arrangeOnLaptopOnly(finishTransition)
		end)
	end
end

finishTransition = function()
	if busyTimeout then
		busyTimeout:stop()
		busyTimeout = nil
	end
	if not busy then
		return
	end
	busy = false
	hs.timer.doAfter(config.timing.screenWatcherDelay, applyDockState)
end

function M.startScreenWatcher()
	if screenWatcher then
		return
	end

	-- Seed state without rearranging on reload, but keep BTT in sync
	lastDocked = M.isDocked()
	setDockedFlags(lastDocked)

	-- Karabiner drops its variables when its config reloads, so re-send ours
	karabinerWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.config/karabiner", function(paths)
		for _, path in ipairs(paths) do
			if path:match("karabiner%.json$") then
				hs.timer.doAfter(1, function()
					setKarabinerDocked(lastDocked)
				end)
				return
			end
		end
	end):start()

	screenWatcher = hs.screen.watcher.new(function()
		local names = {}
		for _, sc in ipairs(hs.screen.allScreens()) do
			table.insert(names, sc:name() or "?")
		end
		logf("screen watcher fired: %s (lastDocked=%s busy=%s)", table.concat(names, ", "), tostring(lastDocked), tostring(busy))
		hs.timer.doAfter(config.timing.screenWatcherDelay, applyDockState)
	end)

	screenWatcher:start()
end

function M.stopScreenWatcher()
	if screenWatcher then
		screenWatcher:stop()
		screenWatcher = nil
	end
	if karabinerWatcher then
		karabinerWatcher:stop()
		karabinerWatcher = nil
	end
end

return M
