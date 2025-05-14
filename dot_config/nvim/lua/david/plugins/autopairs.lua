return {
	"windwp/nvim-autopairs",
	event = { "insertenter" },
	dependencies = {
		"hrsh7th/nvim-cmp",
	},
	config = function()
		-- import nvim-autopairs
		local autopairs = require("nvim-autopairs")
		local rule = require("nvim-autopairs.rule")

		-- configure autopairs
		autopairs.setup({
			check_ts = true, -- enable treesitter
			ts_config = {
				lua = { "string" }, -- don't add pairs in lua string treesitter nodes
				javascript = { "template_string" }, -- don't add pairs in javscript template_string treesitter nodes
				java = false, -- don't check treesitter on java
			},
			enable_check_bracket_line = false,
			map_cr = true,
			map_bs = true,
			map_c_h = true,
			map_c_w = true,
			enable_moveright = true, -- <- this is what lets you tab out
			fast_wrap = {},
			-- enable_check_bracket_line = false,
		})

		-- autopairs.add_rules({
		--   rule("<", ">", { "html", "typescript", "javascript", "lua", "python", "java"})
		-- })
		-- import nvim-autopairs completion functionality
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")

		-- import nvim-cmp plugin (completions plugin)
		local cmp = require("cmp")

		-- make autopairs and completion work together
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end,
}
