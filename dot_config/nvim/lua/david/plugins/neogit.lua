return {
	"NeogitOrg/neogit",
	lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim", -- required

		-- Only one of these is needed.
		"sindrets/diffview.nvim", -- optional

		-- Only one of these is needed.
		"nvim-telescope/telescope.nvim", -- optional
	},
	cmd = "Neogit",

	keys = {
		{
			"<leader>gg",
			function()
				require("neogit").open({ kind = "replace" })
			end,
			desc = "Neogit UI",
		},
		{ "<leader>gd", "<cmd>Neogit diff<cr>", desc = "Neogit View Diffs" },
		{ "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
		{ "<leader>gp", "<cmd>Neogit pull<cr>", desc = "Neogit Pull" },
		{ "<leader>gP", "<cmd>Neogit push<cr>", desc = "Neogit Push" },
		{ "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },
		{ "<leader>gB", "<cmd>G blame<cr>", desc = "Git Blame" },
		{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
	},
}
