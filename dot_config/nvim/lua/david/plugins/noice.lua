return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		enabled = true,
		-- config = function(_, opts)
		-- 	require("noice").setup(opts)
		--
		-- 	local macro_buf
		-- 	local macro_win
		-- 	local group = vim.api.nvim_create_augroup("david_macro_recording_notify", { clear = true })
		--
		-- 	local function close_macro_popup()
		-- 		if macro_win and vim.api.nvim_win_is_valid(macro_win) then
		-- 			vim.api.nvim_win_close(macro_win, true)
		-- 		end
		-- 		if macro_buf and vim.api.nvim_buf_is_valid(macro_buf) then
		-- 			vim.api.nvim_buf_delete(macro_buf, { force = true })
		-- 		end
		-- 		macro_win = nil
		-- 		macro_buf = nil
		-- 	end
		--
		-- 	local function open_macro_popup(register)
		-- 		close_macro_popup()
		--
		-- 		local text = "recording @" .. register
		-- 		local width = math.max(vim.api.nvim_strwidth(text) + 4, 20)
		-- 		local col = math.max(vim.o.columns - width - 2, 0)
		--
		-- 		macro_buf = vim.api.nvim_create_buf(false, true)
		-- 		vim.bo[macro_buf].bufhidden = "wipe"
		-- 		vim.bo[macro_buf].filetype = "noice"
		-- 		vim.api.nvim_buf_set_lines(macro_buf, 0, -1, false, { text })
		--
		-- 		macro_win = vim.api.nvim_open_win(macro_buf, false, {
		-- 			relative = "editor",
		-- 			row = 1,
		-- 			col = col,
		-- 			width = width,
		-- 			height = 1,
		-- 			style = "minimal",
		-- 			border = "rounded",
		-- 			focusable = false,
		-- 			noautocmd = true,
		-- 			zindex = 200,
		-- 		})
		--
		-- 		vim.wo[macro_win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
		-- 	end
		--
		-- 	vim.api.nvim_create_autocmd("RecordingEnter", {
		-- 		group = group,
		-- 		callback = function()
		-- 			local register = vim.fn.reg_recording()
		-- 			if register == "" then
		-- 				return
		-- 			end
		--
		-- 			open_macro_popup(register)
		-- 		end,
		-- 	})
		--
		-- 	vim.api.nvim_create_autocmd("RecordingLeave", {
		-- 		group = group,
		-- 		callback = function()
		-- 			close_macro_popup()
		-- 		end,
		-- 	})
		--
		-- 	vim.api.nvim_create_autocmd("VimResized", {
		-- 		group = group,
		-- 		callback = function()
		-- 			local register = vim.fn.reg_recording()
		-- 			if register ~= "" then
		-- 				open_macro_popup(register)
		-- 			end
		-- 		end,
		-- 	})
		-- end,
		config = function(_, opts)
			require("noice").setup(opts)
		end,
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
