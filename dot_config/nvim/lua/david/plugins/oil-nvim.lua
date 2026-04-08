return {
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- CustomOilBar = function()
			-- 	local path = vim.fn.expand("%")
			-- 	path = path:gsub("oil://", "")
			--
			-- 	return "  " .. vim.fn.fnamemodify(path, ":.")
			-- end

			require("oil").setup({
				columns = { "icon" },

				float = {
					padding = 2,
					max_width = 100,
					max_height = 60,
					border = "rounded",
					win_options = {
						winblend = 0,
						-- winbar = "%{v:lua.CustomOilBar()}",
					},
				},

				keymaps = {
					["qq"] = function()
						require("oil").toggle_float()
					end,
				},

				view_options = {
					show_hidden = true,
					is_always_hidden = function(name, _)
						local folder_skip = {}
						return vim.tbl_contains(folder_skip, name)
					end,
				},
			})

			vim.keymap.set("n", "<leader>ee", function()
				require("oil").toggle_float()
			end, { desc = "Toggle Oil float" })
		end,
	},
}
