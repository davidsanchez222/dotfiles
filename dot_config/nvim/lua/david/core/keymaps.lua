-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- clear search highlighting by pressing enter in normal mode
keymap.set("n", "<CR>", ":nohlsearch<CR><CR>", { noremap = true, silent = true })

-- disable arrow keys
vim.keymap.set("", "<up>", "<nop>", { noremap = true })
vim.keymap.set("", "<down>", "<nop>", { noremap = true })
vim.keymap.set("", "<left>", "<nop>", { noremap = true })
vim.keymap.set("", "<right>", "<nop>", { noremap = true })
vim.keymap.set("i", "<up>", "<nop>", { noremap = true })
vim.keymap.set("i", "<down>", "<nop>", { noremap = true })
vim.keymap.set("i", "<left>", "<nop>", { noremap = true })
vim.keymap.set("i", "<right>", "<nop>", { noremap = true })

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- delete all and don't put in register
keymap.set("n", "<leader>da", 'ggVG"_d', { desc = "Delete all without copying into register" }) --  go to previous tab

-- yank all
keymap.set("n", "<leader>ya", "ggVGy", { desc = "Yank all" }) --  go to previous tab

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- noice dismiss
-- keymap.set("n", "<leader>nd", "<cmd>NoiceDismiss<CR>", { desc = "Dismiss Noice Message" })

keymap.set("n", "j", "jzz", { desc = "Stay centered vertically when scrolling down" })
keymap.set("n", "k", "kzz", { desc = "Stay centered vertically when scrolling up" })
-- By default, CTRL-U and CTRL-D scroll by half a screen (50% of the window height)
-- Scroll by 35% of the window height and keep the cursor centered
local scroll_percentage = 0.35
-- Scroll by a percentage of the window height and keep the cursor centered
vim.keymap.set("n", "<C-d>", function()
	local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
	vim.cmd("normal! " .. lines .. "jzz")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", function()
	local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
	vim.cmd("normal! " .. lines .. "kzz")
end, { noremap = true, silent = true })

-- Map <leader>u to the ToggleLines command
vim.keymap.set("n", "<leader>u", "<cmd>ToggleLines<CR>", { noremap = true, silent = true })
