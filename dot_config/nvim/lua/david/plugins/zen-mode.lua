return {
	"folke/zen-mode.nvim",
	keys = {
		{ "<leader>nz", "<cmd>ZenMode<CR>", desc = "Toggle Zen Mode" },
	},
	opts = {
		plugins = {
			options = {
				enabled = true,
				laststatus = 3,
				relativenumber = false,
				number = false,
			},
		},
	},
}
