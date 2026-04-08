return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				python = { "isort", "black" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
				undojoin = true,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
				undojoin = true,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
-- return {
-- 	"stevearc/conform.nvim",
-- 	event = { "BufReadPre", "BufNewFile" },
-- 	config = function()
-- 		local conform = require("conform")
--
-- 		conform.setup({
-- 			formatters_by_ft = {
-- 				javascript = { "prettier" },
-- 				typescript = { "prettier" },
-- 				javascriptreact = { "prettier" },
-- 				typescriptreact = { "prettier" },
-- 				svelte = { "prettier" },
-- 				css = { "prettier" },
-- 				html = { "prettier" },
-- 				json = { "prettier" },
-- 				yaml = { "prettier" },
-- 				markdown = { "prettier" },
-- 				graphql = { "prettier" },
-- 				liquid = { "prettier" },
-- 				python = { "isort", "black" },
-- 			},
-- 			format_on_save = function(bufnr)
-- 				if vim.bo[bufnr].filetype == "lua" then
-- 					return nil
-- 				end
-- 				return {
-- 					timeout_ms = 1000,
-- 					lsp_format = "fallback",
-- 				}
-- 			end,
-- 		})
--
-- 		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
-- 			conform.format({
-- 				async = false,
-- 				timeout_ms = 1000,
-- 				lsp_format = "fallback",
-- 			})
-- 		end, { desc = "Format file or range (in visual mode)" })
-- 	end,
-- }
