local config = require("modules.config")
local spaces = require("hs.spaces")

local M = {}

local screenWatcher = nil

local function appName(which)
	return config.apps[which]
end

local function logf(fmt, ...)
	hs.printf("[zen-ghostty] " .. fmt, ...)
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

local function hasExternalDisplay()
	local _, external = getBuiltinAndExternal()
	return external ~= nil
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

local function moveWindowToSpace(win, spaceID, label)
	if not win or not spaceID then
		return false, "Missing window or space for " .. (label or "window")
	end

	spaces.moveWindowToSpace(win, spaceID, true)
	logf("moved %s to space %s", label or "window", tostring(spaceID))
	return true, "Moved " .. (label or "window") .. " to space"
end

local function windowIsInSpace(win, spaceID)
	if not win or not spaceID then
		return false
	end

	local ids = spaces.windowSpaces(win)
	if not ids then
		return false
	end

	for _, id in ipairs(ids) do
		if id == spaceID then
			return true
		end
	end

	return false
end

local function moveWindowToSpaceWithRetry(appNameValue, spaceID, label, attempt, callback)
	attempt = attempt or 1
	local maxTries = config.timing.spaceMoveMaxTries
	local win, app = findWindowForApp(appNameValue)

	if not win then
		logf("no window for %s during move attempt %d", appNameValue, attempt)
		if attempt < maxTries then
			hs.timer.doAfter(config.timing.spaceMoveRetryDelay, function()
				moveWindowToSpaceWithRetry(appNameValue, spaceID, label, attempt + 1, callback)
			end)
			return
		end

		if callback then
			callback(false, nil, app)
		end
		return
	end

	if app then
		app:activate(true)
	end
	win:raise():focus()
	spaces.moveWindowToSpace(win, spaceID, true)
	logf("move attempt %d for %s to space %s", attempt, label or appNameValue, tostring(spaceID))

	hs.timer.doAfter(config.timing.spaceMoveRetryDelay, function()
		local ok = windowIsInSpace(win, spaceID)
		logf("%s in space after attempt %d = %s", label or appNameValue, attempt, tostring(ok))
		if ok then
			if callback then
				callback(true, win, app)
			end
			return
		end

		if attempt < maxTries then
			moveWindowToSpaceWithRetry(appNameValue, spaceID, label, attempt + 1, callback)
			return
		end

		if callback then
			callback(false, win, app)
		end
	end)
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

local function waitForWindowInSpace(win, spaceID, label, triesLeft, callback)
	triesLeft = triesLeft or config.timing.screenPollMaxTries

	if not win or not spaceID then
		if callback then
			callback(false)
		end
		return
	end

	if windowIsInSpace(win, spaceID) then
		logf("%s is in target space", label or "window")
		if callback then
			callback(true)
		end
		return
	end

	if triesLeft <= 1 then
		logf("%s did not reach target space", label or "window")
		if callback then
			callback(false)
		end
		return
	end

	hs.timer.doAfter(config.timing.screenPollInterval, function()
		waitForWindowInSpace(win, spaceID, label, triesLeft - 1, callback)
	end)
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

local function arrangeOnExternal()
	local _, external = getBuiltinAndExternal()
	if not external then
		return false, "No external display found"
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
					end)
				end)
			end)
		end, nil, function()
			logf("ghostty window not found")
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

local function arrangeOnLaptopOnly()
	local builtin = hs.screen.primaryScreen()
	local userSpaces = orderedSpacesForScreen(builtin)

	if #userSpaces < 2 then
		return false, "Need at least 2 user spaces on laptop display"
	end

	local space1 = userSpaces[1]
	local space2 = userSpaces[2]

	logf("arranging on laptop spaces %s and %s", tostring(space1), tostring(space2))

	local function moveAndFocusGhostty()
		local function finishGhosttyFocus()
			logf("goto space2=%s", tostring(space2))
			spaces.gotoSpace(space2)

			hs.timer.doAfter(config.timing.afterGotoSpace, function()
				launchAndGetWindow(appName("ghostty"), function(ghosttyWin2, ghosttyApp2)
					focusWindowThen(ghosttyWin2, ghosttyApp2, appName("ghostty"), "Ghostty", config.timing.beforeRaycastKey, function()
						sendRaycast(config.raycast.maximize)
						logf("sent Option+M to Ghostty")
						hs.timer.doAfter(config.timing.finalReturnDelay, function()
						spaces.gotoSpace(space1)
						hs.alert.show("Zen in Space 1, Ghostty in Space 2")
					end)
					end)
				end)
			end)
		end

		moveWindowToSpaceWithRetry(appName("ghostty"), space2, "Ghostty", 1, function(ok)
			if ok then
				finishGhosttyFocus()
				return
			end

			logf("ghostty move failed, retrying after goto space2")
			spaces.gotoSpace(space2)
			hs.timer.doAfter(config.timing.afterGotoSpace, function()
				moveWindowToSpaceWithRetry(appName("ghostty"), space2, "Ghostty", 1, function(ok2)
					if ok2 then
						finishGhosttyFocus()
						return
					end

					logf("ghostty move failed after fallback")
					spaces.gotoSpace(space1)
				end)
			end)
		end)
	end

	local function moveAndFocusZen()
		launchAndGetWindow(appName("zen"), function(zenWin, zenApp)
			local _, msg = moveWindowToSpace(zenWin, space1, "Zen")
			if msg then
				logf("%s", msg)
			end

			hs.timer.doAfter(config.timing.afterMoveToSpace, function()
				local inSpace = windowIsInSpace(zenWin, space1)
				logf("zen in space1=%s", tostring(inSpace))
				logf("goto space1=%s", tostring(space1))
				spaces.gotoSpace(space1)

				hs.timer.doAfter(config.timing.afterGotoSpace, function()
					launchAndGetWindow(appName("zen"), function(zenWin2, zenApp2)
						focusWindowThen(zenWin2, zenApp2, appName("zen"), "Zen", config.timing.beforeRaycastKey, function()
							sendRaycast(config.raycast.maximize)
							logf("sent Option+M to Zen")
							hs.timer.doAfter(config.timing.secondWindowDelay, moveAndFocusGhostty)
						end)
					end)
				end)
			end)
		end)
	end

	moveAndFocusZen()

	return true, "Arranging Zen/Ghostty on laptop spaces"
end

function M.arrangeZenGhostty()
	if hasExternalDisplay() then
		return arrangeOnExternal()
	else
		return arrangeOnLaptopOnly()
	end
end

function M.startScreenWatcher()
	if screenWatcher then
		return
	end

	screenWatcher = hs.screen.watcher.new(function()
		hs.timer.doAfter(config.timing.screenWatcherDelay, function()
			M.arrangeZenGhostty()
		end)
	end)

	screenWatcher:start()
end

function M.stopScreenWatcher()
	if screenWatcher then
		screenWatcher:stop()
		screenWatcher = nil
	end
end

return M
