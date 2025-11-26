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
-- opt.showbreak = "↪" -- show visual indicator for truncated lines

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- appearance
opt.mouse = ""
-- turn on termguicolors for nightfly colorscheme to work
-- (have to use iterm2 or any other true color terminal)
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

-- toggle for line numbers
vim.api.nvim_create_user_command("ToggleLines", function()
	if vim.wo.number then
		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.opt.fillchars:append({ eob = " " }) -- hide ~
	else
		vim.wo.number = true
		vim.wo.relativenumber = true
		vim.opt.fillchars:append({ eob = "~" }) -- show ~ again if desired
	end
end, {})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua", "javascript", "typescript", "javascriptreact", "typescriptreact", "html" },
	callback = function()
		vim.bo.tabstop = 2
		vim.bo.shiftwidth = 2
		vim.bo.softtabstop = 2
	end,
})

-- open svg in browser
vim.api.nvim_create_user_command("OpenSvgInBrowser", function()
	if vim.bo.modified then
		vim.cmd.write()
	end

	local file = vim.fn.expand("%:p")
	if file == "" then
		vim.notify("No file associated", vim.log.levels.ERROR)
		return
	end

	-- Force macOS open to use Zen
	local zen_app = "Zen Browser.app" -- if this doesn't work, try "Zen Browser"
	vim.fn.jobstart({ "open", "-a", zen_app, file }, { detach = true })
end, {})
