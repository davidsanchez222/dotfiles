return {
	dir = "/Users/david/code/typst-preview.nvim",
	lazy = false,
	opts = {},
	config = function(_, opts)
		require("typst-preview").setup(opts)
		local keymap = vim.keymap
		keymap.set("n", "<leader>tp", "<cmd>TypstPreview<cr>", { desc = "Open Typst preview" })
		keymap.set("n", "<leader>tq", "<cmd>TypstPreviewStop<cr>", { desc = "Stop Typst preview" })
		keymap.set("n", "<leader>tt", "<cmd>TypstPreviewToggle<cr>", { desc = "Toggle Typst preview" })
		keymap.set("n", "<leader>te", "<cmd>TypstPreviewExport<cr>", { desc = "Export Typst to PDF" })
	end,
}
-- return {
-- 	"chomosuke/typst-preview.nvim",
-- 	version = "1.*",
-- 	lazy = false,
-- 	opts = {},
-- 	config = function(_, opts)
-- 		require("typst-preview").setup(opts)
-- 	end,
-- }
