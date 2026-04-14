local M = {}

function M.getBuiltinAndExternal()
	local builtin, external

	for _, screen in ipairs(hs.screen.allScreens()) do
		local name = screen:name() or ""

		if name:match("Built%-in") or name:match("Color LCD") then
			builtin = screen
		elseif not external then
			external = screen
		end
	end

	return builtin, external
end

function M.moveLaptopUnder(position)
	local laptop, wide = M.getBuiltinAndExternal()

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

return M
