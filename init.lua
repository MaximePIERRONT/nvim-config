vim.o.number = true
vim.o.relativenumber = true

vim.pack.add {
	"https://github.com/stevearc/oil.nvim",
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = "https://github.com/catppuccin/nvim",                         name = "catppuccin" },
	{ src = 'https://github.com/nvim-lua/plenary.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },
	{ src = 'https://github.com/kdheepak/lazygit.nvim' }
}

vim.lsp.enable({
	'lua_ls',
	'ts_ls',
	'volar',
	'jdtls',
})

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
})

require("oil").setup({
	view_options = {
		show_hidden = true, },
})

vim.cmd.colorscheme("catppuccin-latte")

vim.keymap.set('n', '-', '<cmd>Oil<cr>')

vim.api.nvim_create_autocmd('BufWritePre', {
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})


local telescope = require('telescope')
local builtin = require('telescope.builtin')

telescope.setup({})
telescope.load_extension('fzf')

vim.keymap.set('n', 'sf', builtin.find_files)
vim.keymap.set('n', 'sg', builtin.live_grep)
vim.keymap.set('n', 'sr', builtin.oldfiles)
vim.keymap.set('n', 'lg', '<cmd>LazyGit<cr>')
