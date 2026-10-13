-- local colorscheme = "catppuccin"
local colorscheme = "gruvbox"

return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
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
						-- ["@lsp.type.namespace.go"] = { fg = colors.lavender },
						-- ["@lsp.type.type.go"] = { fg = colors.yellow },
						-- ["@lsp.type.parameter.go"] = { fg = colors.maroon },
						-- ["@lsp.type.variable.go"] = { fg = colors.teal },
						-- ["@lsp.mod.readonly.go"] = { fg = colors.peach },
						-- ["@lsp.type.function.go"] = { fg = colors.blue },
						-- ["@lsp.type.method.go"] = { fg = colors.sapphire },

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

			if colorscheme == "catppuccin" then
				vim.cmd.colorscheme("catppuccin")
			end
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("gruvbox").setup({
				transparent_mode = true,
				overrides = {
					StatusLine = { bg = "NONE" },
					StatusLineNC = { bg = "NONE" },

					TelescopeNormal = { bg = "NONE" },
					TelescopeBorder = { bg = "NONE" },
					TelescopePromptNormal = { bg = "NONE" },
					TelescopePromptBorder = { bg = "NONE" },
					TelescopeResultsNormal = { bg = "NONE" },
					TelescopeResultsBorder = { bg = "NONE" },
					TelescopePreviewNormal = { bg = "NONE" },
					TelescopePreviewBorder = { bg = "NONE" },

					WhichKeyNormal = { bg = "NONE" },
					WhichKeyFloat = { bg = "NONE" },
					NormalFloat = { bg = "NONE" },
					FloatBorder = { bg = "NONE" },
				},
			})

			if colorscheme == "gruvbox" then
				vim.o.background = "dark"
				vim.cmd.colorscheme("gruvbox")
			end
		end,
	},
}
