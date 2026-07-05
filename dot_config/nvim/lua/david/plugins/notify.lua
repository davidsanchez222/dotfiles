return {
	"rcarriga/nvim-notify",
	config = function()
		require("notify").setup({
			background_colour = "#000000",
			timeout = 500,
		})
		vim.notify = require("notify")
	end,
}
