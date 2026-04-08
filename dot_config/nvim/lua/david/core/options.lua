vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt -- for conciseness

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- tabs & indentation
opt.tabstop = 4 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 4 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

-- line wrapping
opt.wrap = false -- disable line wrapping
opt.showbreak = "↪" -- show visual indicator for truncated lines

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- appearance
opt.mouse = ""
-- opt.mouse = "a"
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- make buffers with these languages tab with 2 spaces rather than one
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua", "javascript", "typescript", "javascriptreact", "typescriptreact", "html" },
	callback = function()
		vim.bo.tabstop = 2
		vim.bo.shiftwidth = 2
		vim.bo.softtabstop = 2
	end,
})

-- copy output of command
vim.api.nvim_create_user_command("Out", function(opts)
	local ok, result = pcall(vim.fn.execute, "silent " .. opts.args)
	local text = tostring(result or "")

	vim.fn.setreg("+", text)
	vim.fn.setreg("*", text)

	if not ok then
		vim.notify("Out failed; error copied to clipboard", vim.log.levels.ERROR)
		return
	end

	if text == "" then
		vim.notify("Command produced no capturable output", vim.log.levels.WARN)
		return
	end

	vim.notify("Copied output to clipboard", vim.log.levels.INFO)
end, {
	nargs = "+",
	complete = "command",
})

-- open svg in browser. <leader>nb
vim.api.nvim_create_user_command("OpenSvgInBrowser", function()
	if vim.bo.modified then
		vim.cmd.write()
	end

	local file = vim.fn.expand("%:p")
	if file == "" then
		vim.notify("No file associated", vim.log.levels.ERROR)
		return
	end

	-- force macOS open to use Zen
	local zen_app = "Zen Browser.app" -- if this doesn't work, try "Zen Browser"
	vim.fn.jobstart({ "open", "-a", zen_app, file }, { detach = true })
end, {})

-- copy absolute filepath to clipboard. <leader>fp
vim.api.nvim_create_user_command("FilePath", function(opts)
	local path

	if opts.args ~= "" then
		path = vim.fn.fnamemodify(opts.args, ":p")
	else
		path = vim.fn.expand("%:p")
	end

	vim.fn.setreg("+", path)
	print("Copied: " .. path)
end, {
	nargs = "?",
	complete = "file",
})
