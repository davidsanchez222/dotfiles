return {
	"Pocco81/auto-save.nvim",
	config = function()
		local auto_session = require("auto-save")

		auto_session.setup({
			execution_message = {
				message = function() -- message to print on save
					return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
				end,
				dim = 0.18, -- dim the color of `message`
				cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
			},
		})

		local keymap = vim.keymap
		keymap.set("n", "<leader>ns", ":ASToggle<CR>", {})
	end,
}
