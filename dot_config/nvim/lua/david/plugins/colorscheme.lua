return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "frappe",
				transparent_background = true,
				float = {
					transparent = true,
				},
				integrations = {
					telescope = {
						enabled = true,
					},
					which_key = true,
				},
				custom_highlights = function(colors)
					return {
						TelescopeNormal = { bg = "NONE" },
						TelescopeBorder = { bg = "NONE" },
						TelescopePromptNormal = { bg = "NONE" },
						TelescopePromptBorder = { bg = "NONE" },
						TelescopeResultsNormal = { bg = "NONE" },
						TelescopeResultsBorder = { bg = "NONE" },
						TelescopePreviewNormal = { bg = "NONE" },
						TelescopePreviewBorder = { bg = "NONE" },

						WhichKeyFloat = { bg = "NONE" },
						NormalFloat = { bg = "NONE" },
						FloatBorder = { bg = "NONE" },
					}
				end,
			})

			vim.cmd.colorscheme("catppuccin")
		end,
	},
}

