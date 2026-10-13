-- local lualine_colorscheme = "catppuccin"
local lualine_colorscheme = "gruvbox"

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local function catppuccin_theme()
			local flavour = "frappe"
			local C = require("catppuccin.palettes").get_palette(flavour)
			local O = require("catppuccin").options
			local transparent_bg = O.transparent_background and "NONE" or C.mantle

			return {
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
		end

		local function gruvbox_theme()
			local C = require("gruvbox").palette

			return {
				normal = {
					a = { fg = C.dark0, bg = C.bright_blue },
					b = { fg = C.light1, bg = C.dark1 },
					c = { fg = C.light1, bg = "NONE" },
				},
				insert = {
					a = { fg = C.dark0, bg = C.bright_aqua },
				},
				visual = {
					a = { fg = C.dark0, bg = C.bright_purple },
				},
				replace = {
					a = { fg = C.dark0, bg = C.bright_red },
				},
				command = {
					a = { fg = C.dark0, bg = C.bright_orange },
				},
				terminal = {
					a = { fg = C.dark0, bg = C.bright_green },
				},
				inactive = {
					a = { fg = C.light1, bg = "NONE" },
					b = { fg = C.gray, bg = "NONE" },
					c = { fg = C.dark4, bg = "NONE" },
				},
			}
		end

		local bubbles_theme = lualine_colorscheme == "gruvbox" and gruvbox_theme() or catppuccin_theme()

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
					-- {
					-- 	function()
					-- 		return vim.fn.expand("%:p"):gsub(vim.env.HOME, "~")
					-- 	end,
					-- },
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
