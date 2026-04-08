local launch_cwd = vim.fn.getcwd()

local function set_terminal_title()
	local filepath = vim.fn.expand("%:p")
	local title

	if filepath == "" then
		title = "nvim"
	else
		local prefix = vim.pesc(launch_cwd)
		local relative = filepath:gsub("^" .. prefix, "")

		if relative == filepath then
			relative = vim.fn.fnamemodify(filepath, ":~")
		elseif relative == "" then
			relative = "/"
		end

		title = "nvim " .. relative:gsub("^/", "")
	end

	local title_string = string.format("\027]0;%s\007", title)
	io.stdout:write(title_string)
	io.stdout:flush()
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "DirChanged", "SessionLoadPost" }, {
	callback = function()
		vim.schedule(set_terminal_title)
	end,
})

local function reset_terminal_title()
	local cwd = launch_cwd
	local home = vim.fn.expand("~")
	local display = cwd:gsub("^" .. vim.pesc(home), "~")

	local title_string = string.format("\027]0;%s\007", display)
	io.stdout:write(title_string)
	io.stdout:flush()
end

vim.api.nvim_create_autocmd("VimLeave", {
	callback = reset_terminal_title,
})
