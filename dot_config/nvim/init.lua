local ui = require("vim._core.ui2")
ui.enable({
	enable = false,
	msg = {
		target = "classic", -- options: cmd(classic), msg(similar to noice)
		pager = { height = 1 },
		msg = { height = 0.5, timeout = 4500 },
		dialog = { height = 0.5 },
		cmd = { height = 0.5 },
	},
})
-- ui.cmd.cmdline_show = custom_cmdline_show

require("david.core")
require("david.lazy")
