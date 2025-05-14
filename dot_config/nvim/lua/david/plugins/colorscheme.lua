return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			require("catppuccin").setup({
				flavour = "frappe", -- Options: latte, frappe, macchiato, mocha
				transparent_background = true,
			})
			-- Apply the theme
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
