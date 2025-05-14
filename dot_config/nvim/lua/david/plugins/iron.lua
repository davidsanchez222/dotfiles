return {
	"Vigemus/iron.nvim",
	config = function()
		local iron = require("iron.core")
		local view = require("iron.view")
		repl_open_cmd = "vertical botright 80 split"

		iron.setup({
			config = {
				visibility = require("iron.visibility").toggle,
				scratch_repl = true,
				repl_definition = {
					-- python = {
					-- command = { "ipython" },
					-- },
					lua = {
						command = { "lua" },
					},
				},
				repl_open_cmd = "botright 15split",
				-- Commenting out or removing highlight_last avoids the issue
				-- highlight_last = "IronLastSent",
			},
			keymaps = {
				send_motion = "<leader>cq",
				visual_send = "<S-CR>",
				send_file = "<leader>cf",
				send_line = "<S-CR>",
				send_until_cursor = "<leader>su",
			},
		})
	end,
}
