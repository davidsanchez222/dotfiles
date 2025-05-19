return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		servers = {
			-- lua_ls = true,
		},
	},
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function(_, opts)
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local keymap = vim.keymap

		local diagnostics_virtual_text_enabled = false
		function _G.toggle_virtual_text()
			diagnostics_virtual_text_enabled = not diagnostics_virtual_text_enabled
			vim.diagnostic.config({
				virtual_text = diagnostics_virtual_text_enabled,
			})
			print("Virtual text diagnostics: " .. (diagnostics_virtual_text_enabled and "ON" or "OFF"))
		end

		vim.keymap.set("n", "<leader>nd", toggle_virtual_text, { desc = "Toggle virtual text diagnostics" })

		vim.diagnostic.config({
			virtual_text = false,
			signs = true,
			underline = true,
			update_in_insert = false,
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

				opts.desc = "Toggle virtual text diagnostics"
				keymap.set("n", "<leader>nd", toggle_virtual_text, opts)
			end,
		})

		local capabilities = cmp_nvim_lsp.default_capabilities()

		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		mason_lspconfig.setup_handlers({
			function(server_name)
				if opts.servers and opts.servers[server_name] == false then
					return
				end
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,

			-- Uncomment to customize lua_ls behavior if you want to re-enable it later
			-- ["lua_ls"] = function()
			--   lspconfig["lua_ls"].setup({
			--     capabilities = capabilities,
			--     settings = {
			--       Lua = {
			--         diagnostics = {
			--           globals = { "vim" },
			--         },
			--         completion = {
			--           callSnippet = "Replace",
			--         },
			--       },
			--     },
			--   })
			-- end,
		})
	end,
}
