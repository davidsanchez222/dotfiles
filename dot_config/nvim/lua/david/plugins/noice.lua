return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		enabled = true,
		opts = {
			cmdline = {
				format = {
					filter = false, -- disables special handling for :!cmd
				},
			},
			routes = {
				{
					view = "notify",
					filter = {
						event = "msg_show",
						kind = { "shell_out", "shell_err" },
					},
				},
			},
			presets = {
				bottom_search = false,
				command_palette = true,
				lsp_doc_border = true,
				long_message_to_split = true,
				inc_rename = false,
			},
			messages = {
				enabled = true, -- enables the Noice messages UI
				view = "notify", -- default view for messages
				view_error = "notify", -- view for errors
				view_warn = "notify", -- view for warnings
				view_history = "messages", -- view for :messages
				view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
			},
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
				message = {
					enabled = true,
					view = "mini",
				},
			},
			views = {
				-- This sets the position for the search popup that shows up with / or with :
				cmdline_popup = {
					position = {
						row = "40%",
						col = "50%",
					},
				},
				mini = {
					timeout = 2000, -- timeout in milliseconds
					align = "center",
					position = {
						-- Centers messages top to bottom
						row = "95%",
						-- Aligns messages to the far right
						col = "100%",
					},
				},
			},
		},
	},
}
