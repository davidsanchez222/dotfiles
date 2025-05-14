return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local flavour = "frappe"
		local C = require("catppuccin.palettes").get_palette(flavour)
		local O = require("catppuccin").options
		local transparent_bg = O.transparent_background and "NONE" or C.mantle

		local bubbles_theme = {
			normal = {
				a = { fg = C.base, bg = C.blue },
				b = { fg = C.text, bg = C.surface0 },
				c = { fg = C.text, bg = transparent_bg },
			},
			insert = {
				a = { fg = C.base, bg = C.teal },
			},
			visual = {
				a = { fg = C.base, bg = C.mauve },
			},
			replace = {
				a = { fg = C.base, bg = C.red },
			},
			command = {
				a = { fg = C.base, bg = C.peach },
			},
			terminal = {
				a = { fg = C.base, bg = C.green },
			},
			inactive = {
				a = { fg = C.text, bg = transparent_bg },
				b = { fg = C.overlay1, bg = transparent_bg },
				c = { fg = C.overlay0, bg = transparent_bg },
			},
		}

		require("lualine").setup({
			options = {
				theme = bubbles_theme,
				component_separators = "",
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = {
					{
						"mode",
						separator = { left = "" },
						right_padding = 2,
						fmt = function(str)
							return string.lower(str)
						end,
					},
				},
				lualine_b = {
					"filename",
					{
						function()
							return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
						end,
						icon = "", -- optional folder icon
					},
					"branch",
				},
				-- lualine_b = { "filename", "branch" },
				lualine_c = {
					"%=", -- center
				},
				lualine_x = {},
				lualine_y = { "filetype", "progress" },
				lualine_z = {
					{ "location", separator = { right = "" }, left_padding = 2 },
				},
			},
			inactive_sections = {
				lualine_a = { "filename" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = { "location" },
			},
			tabline = {},
			extensions = {},
		})
	end,
}
