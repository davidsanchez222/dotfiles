return {
	"christoomey/vim-tmux-navigator",
	cmd = {
		"TmuxNavigateLeft",
		"TmuxNavigateDown",
		"TmuxNavigateUp",
		"TmuxNavigateRight",
		"TmuxNavigatePrevious",
		"TmuxNavigatorProcessList",
	},
	keys = {
		{ "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
		{ "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
		{ "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
		{ "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
		-- { "<C-L>", "<cmd><C-U>TmuxNavigateRight<cr>" },
		-- { "<Right>", "<cmd><C-U><TmuxNavigateRight<cr>" },
		{ "<C-M-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
	},
}
