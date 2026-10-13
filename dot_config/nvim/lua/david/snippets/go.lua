local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
	s(
		"fs",
		fmt('fmt.Printf("{}%s", {})', {
			i(1),
			i(2),
		})
	),
}
