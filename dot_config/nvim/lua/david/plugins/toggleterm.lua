return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		direction = "float",
		start_in_insert = true,
		close_on_exit = true,
		on_open = function(term)
			local opts = { buffer = term.bufnr, silent = true }
			local keymap = vim.keymap

			keymap.set("t", "qq", [[<C-\><C-n><cmd>close<CR>]], opts)
			keymap.set("n", "q", [[<cmd>close<CR>]], opts)
			keymap.set("t", "<C-\\>", [[<C-\><C-n><cmd>ToggleTerm<CR>]], opts)
		end,
	},
	config = function(_, opts)
		require("toggleterm").setup(opts)

		local Terminal = require("toggleterm.terminal").Terminal

		vim.keymap.set("n", "<leader>nt", function()
			local term = Terminal:new({
				direction = "float",
				close_on_exit = true,
				hidden = true,
			})
			term:toggle()
		end, { desc = "New floating terminal" })
	end,
}
