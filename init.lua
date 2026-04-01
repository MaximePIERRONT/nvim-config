-- Neovim Configuration
-- Optimized structure with clear sections

-- ============================================================================
-- OPTIONS
-- ============================================================================

vim.o.number = true         -- Show absolute line numbers
vim.o.relativenumber = true -- Show relative line numbers for easier motion
vim.opt.exrc = true         -- Allow .nvim.lua local config files
vim.g.mapleader = ' '       -- Set leader key to space
vim.g.maplocalleader = ' '  -- Set local leader key to space

-- ============================================================================
-- PLUGINS
-- ============================================================================

vim.pack.add({
	-- File explorer
	{ src = 'https://github.com/stevearc/oil.nvim' },

	-- Fuzzy finder and dependencies
	{ src = 'https://github.com/nvim-lua/plenary.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },

	-- Mason (package manager for LSP, formatters, linters)
	{ src = 'https://github.com/williamboman/mason.nvim' },
	{ src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },

	-- Syntax highlighting and parsing
	{ src = 'https://github.com/nvim-treesitter/nvim-treesitter' },

	-- Testing framework
	{ src = 'https://github.com/nvim-neotest/neotest' },
	{ src = 'https://github.com/nvim-neotest/neotest-java' },
	{ src = 'https://github.com/nvim-neotest/nvim-nio' },
	{ src = 'https://github.com/mfussenegger/nvim-jdtls' },

	-- Git integration
	{ src = 'https://github.com/kdheepak/lazygit.nvim' },

	-- Theme
	{ src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },

	-- Autocompletion
	{ src = 'https://github.com/hrsh7th/nvim-cmp' },
	{ src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
	{ src = 'https://github.com/L3MON4D3/LuaSnip' },
	{ src = 'https://github.com/saadparwaiz1/cmp_luasnip' },
	{ src = 'https://github.com/rafamadriz/friendly-snippets' },

	-- Formatting
	{ src = 'https://github.com/stevearc/conform.nvim' },

	-- Keymap helper (shows available keymaps)
	{ src = 'https://github.com/folke/which-key.nvim' },

	-- Git signs in gutter
	{ src = 'https://github.com/lewis6991/gitsigns.nvim' },

	-- Collection of minimal modules (text objects, surround, autopairs)
	{ src = 'https://github.com/echasnovski/mini.nvim' },

	-- Highlight TODO, FIXME, NOTE comments
	{ src = 'https://github.com/folke/todo-comments.nvim' },
})

-- ============================================================================
-- LSP (Language Server Protocol) with Mason - Native API
-- ============================================================================

-- Initialize Mason (package manager for LSP, DAP, linters, formatters)
require('mason').setup()

-- Auto-install LSP servers, formatters and linters
require('mason-tool-installer').setup({
	ensure_installed = {
		-- LSP servers
		'lua-language-server',  -- Lua
		'typescript-language-server', -- TypeScript/JavaScript
		'vue-language-server',  -- Vue.js
		'jdtls',                -- Java
		-- Formatters
		'prettier',             -- Formatter for JS/TS/JSON/YAML
		'eslint_d',             -- Fast linter/formatter for JS/TS
		'stylua',               -- Formatter for Lua
	},
	auto_update = true,
})

-- Configure diagnostic display
vim.diagnostic.config({
	virtual_text = true,    -- Show diagnostics inline
	signs = true,           -- Show signs in the gutter
	underline = true,       -- Underline problematic code
	update_in_insert = false, -- Don't update while typing
})

-- ============================================================================
-- AUTOCOMPLETION
-- ============================================================================

-- Extend LSP capabilities for nvim-cmp
local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Configure LSP servers using native vim.lsp.config (Neovim 0.11+)
-- Lua
vim.lsp.config('lua_ls', {
	capabilities = cmp_capabilities,
	settings = {
		Lua = {
			diagnostics = {
				globals = { 'vim' },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file('', true),
				checkThirdParty = false,
			},
		},
	},
})

-- TypeScript
vim.lsp.config('ts_ls', {
	capabilities = cmp_capabilities,
})

-- Vue
vim.lsp.config('volar', {
	capabilities = cmp_capabilities,
})

-- Java
vim.lsp.config('jdtls', {
	capabilities = cmp_capabilities,
})

-- Enable all configured LSP servers
vim.lsp.enable({ 'lua_ls', 'ts_ls', 'volar', 'jdtls' })

-- Setup nvim-cmp for autocompletion
local cmp = require('cmp')
local luasnip = require('luasnip')

-- Load friendly-snippets
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},

	mapping = cmp.mapping.preset.insert({
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),

		-- Tab behavior: navigate or expand snippet
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { 'i', 's' }),

		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { 'i', 's' }),

		-- Enter confirms selection
		['<CR>'] = cmp.mapping.confirm({
			select = true,
			behavior = cmp.ConfirmBehavior.Replace
		}),
	}),

	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
		{ name = 'buffer' },
		{ name = 'path' },
	}),

	formatting = {
		format = function(entry, vim_item)
			-- Add icons for completion items
			local kind_icons = {
				Text = '',
				Method = '',
				Function = '',
				Constructor = '',
				Field = '',
				Variable = '',
				Class = '',
				Interface = '',
				Module = '',
				Property = '',
				Unit = '',
				Value = '',
				Enum = '',
				Keyword = '',
				Snippet = '',
				Color = '',
				File = '',
				Reference = '',
				Folder = '',
				EnumMember = '',
				Constant = '',
				Struct = '',
				Event = '',
				Operator = '',
				TypeParameter = '',
			}
			vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind] or '', vim_item.kind)
			return vim_item
		end,
	},

	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
})

-- ============================================================================
-- PLUGIN CONFIGURATION
-- ============================================================================

-- Oil: File explorer that feels like editing a buffer
require('oil').setup({
	view_options = {
		show_hidden = true, -- Show hidden files (dotfiles)
	},
})

-- Telescope: Fuzzy finder
local telescope = require('telescope')
telescope.setup({})
telescope.load_extension('fzf')

-- Treesitter: Syntax highlighting and code parsing
-- Wrapped in pcall to avoid errors on first startup before plugin is installed
local treesitter_ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if treesitter_ok then
	treesitter.setup({
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		indent = {
			enable = true,
		},
		-- Automatically install parsers for detected languages
		auto_install = true,
	})
end

-- Neotest: Testing framework
-- Wrapped in pcall to avoid errors on first startup before plugin is installed
local neotest_ok, neotest = pcall(require, 'neotest')
if neotest_ok then
	neotest.setup({
		log_level = vim.log.levels.DEBUG,
		adapters = {
			require('neotest-java')({
				incremental_build = true,
				force_runner = 'maven',
				root_markers = { 'pom.xml' },
			}),
		},
	})
end

-- Which-key: Shows available keymaps
-- Wrapped in pcall to avoid errors on first startup
local wk_ok, wk = pcall(require, 'which-key')
if wk_ok then
	wk.setup({
		-- Delay before showing the popup
		delay = 500,
		-- Icons for different types of keys
		icons = {
			mappings = true,
		},
		-- Window styling
		win = {
			border = 'rounded',
			padding = { 2, 2, 2, 2 },
		},
	})
end

-- Gitsigns: Git signs in gutter
-- Wrapped in pcall to avoid errors on first startup
local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')
if gitsigns_ok then
	gitsigns.setup({
		-- Signs in gutter
		signs = {
			add = { text = '+' },
			change = { text = '~' },
			delete = { text = '_' },
			topdelete = { text = '‾' },
			changedelete = { text = '~' },
		},
		-- Show blame on current line
		current_line_blame = false,
		-- Keymaps for git operations
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns

			-- Navigation
			vim.keymap.set('n', ']h', function()
				if vim.wo.diff then return ']h' end
				vim.schedule(function() gs.next_hunk() end)
				return '<Ignore>'
			end, { expr = true, buffer = bufnr, desc = 'Next [H]unk' })

			vim.keymap.set('n', '[h', function()
				if vim.wo.diff then return '[h' end
				vim.schedule(function() gs.prev_hunk() end)
				return '<Ignore>'
			end, { expr = true, buffer = bufnr, desc = 'Previous [H]unk' })

			-- Actions
			vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = '[H]unk [S]tage' })
			vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = '[H]unk [R]eset' })
			vim.keymap.set('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { buffer = bufnr, desc = '[H]unk [S]tage' })
			vim.keymap.set('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end, { buffer = bufnr, desc = '[H]unk [R]eset' })
			vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr, desc = '[H]unk [S]tage buffer' })
			vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { buffer = bufnr, desc = '[H]unk [R]eset buffer' })
			vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = '[H]unk [P]review' })
			vim.keymap.set('n', '<leader>hb', function() gs.blame_line { full = true } end, { buffer = bufnr, desc = '[H]unk [B]lame' })
			vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr, desc = '[H]unk [D]iff' })
		end,
	})
end

-- Mini.nvim: Collection of minimal modules
-- Wrapped in pcall to avoid errors on first startup
local mini_ok = pcall(require, 'mini.ai')
if mini_ok then
	-- Better text objects (a for around, i for inside)
	-- Examples: vaf (visual around function), vif (visual inside function)
	require('mini.ai').setup({
		n_lines = 500,
		custom_textobjects = {
			-- Function text object
			f = require('mini.ai').gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
			-- Class text object
			c = require('mini.ai').gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
		},
	})

	-- Surround operations
	-- sa" - Add surround (quotes)
	-- sd" - Delete surround
	-- sr"' - Replace surround
	require('mini.surround').setup({
		mappings = {
			add = 'sa',
			delete = 'sd',
			find = 'sf',
			find_left = 'sF',
			highlight = 'sh',
			replace = 'sr',
			update_n_lines = 'sn',
		},
	})

	-- Autopairs
	require('mini.pairs').setup({
		modes = { insert = true, command = true, terminal = false },
	})
end

-- Todo-comments: Highlight TODO, FIXME, NOTE, etc.
-- Wrapped in pcall to avoid errors on first startup
local todo_ok, todo = pcall(require, 'todo-comments')
if todo_ok then
	todo.setup({
		keywords = {
			FIX = { icon = ' ', color = 'error', alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' } },
			TODO = { icon = ' ', color = 'info' },
			HACK = { icon = ' ', color = 'warning' },
			WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
			PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
			NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
			TEST = { icon = '⏲ ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
		},
		colors = {
			error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
			warning = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' },
			info = { 'DiagnosticInfo', '#2563EB' },
			hint = { 'DiagnosticHint', '#10B981' },
			default = { 'Identifier', '#7C3AED' },
			test = { 'Identifier', '#FF00FF' },
		},
	})

	-- Keymap to search TODOs with Telescope
	vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope<cr>', { desc = '[S]earch [T]ODOs' })
end

-- ============================================================================
-- THEME
-- ============================================================================

vim.cmd.colorscheme('catppuccin-latte')

-- ============================================================================
-- KEYMAPS
-- ============================================================================

-- File navigation
vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open Oil file explorer' })

-- Telescope fuzzy finding - only set keymaps if plugin is loaded
local telescope_builtin_ok, telescope_builtin = pcall(require, 'telescope.builtin')
if telescope_builtin_ok then
	vim.keymap.set('n', '<leader>sf', telescope_builtin.find_files, { desc = '[S]earch [F]iles' })
	vim.keymap.set('n', '<leader>sg', telescope_builtin.live_grep, { desc = '[S]earch by [G]rep' })
	vim.keymap.set('n', '<leader>sr', telescope_builtin.oldfiles, { desc = '[S]earch [R]ecent files' })
end

-- Git
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>', { desc = '[L]azy[G]it' })

-- Testing (Neotest) - only set keymaps if plugin is loaded
if neotest_ok then
	vim.keymap.set('n', '<leader>tt', function()
		neotest.run.run()
	end, { desc = '[T]est nearest [T]est' })

	vim.keymap.set('n', '<leader>tf', function()
		neotest.run.run(vim.fn.expand('%'))
	end, { desc = '[T]est current [F]ile' })

	vim.keymap.set('n', '<leader>to', function()
		neotest.output_panel.toggle()
	end, { desc = '[T]est [O]utput panel' })

	vim.keymap.set('n', '<leader>mo', function()
		neotest.output.open({ enter = true, short = false })
	end, { desc = '[M]essage [O]utput (test)' })
end

-- Diagnostics
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous [D]iagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next [D]iagnostic' })

-- ============================================================================
-- LSP KEYMAPS (attach when LSP connects)
-- ============================================================================

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
	callback = function(event)
		local buf = event.buf
		local builtin = require('telescope.builtin')

		-- Navigation (Telescope for better UX)
		vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = buf, desc = '[G]oto [D]eclaration' })
		vim.keymap.set('n', 'gr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
		vim.keymap.set('n', 'gI', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
		vim.keymap.set('n', 'gt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })

		-- Symbols
		vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols, { buffer = buf, desc = '[D]ocument [S]ymbols' })
		vim.keymap.set('n', '<leader>ws', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = '[W]orkspace [S]ymbols' })

		-- Documentation & Info
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = buf, desc = 'Hover Documentation' })
		vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { buffer = buf, desc = 'Signature Help' })

		-- Actions
		vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = buf, desc = '[R]e[n]ame' })
		vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = buf, desc = '[C]ode [A]ction' })
		vim.keymap.set('n', '<leader>f', function()
			vim.lsp.buf.format({ async = true })
		end, { buffer = buf, desc = '[F]ormat' })
	end,
})

-- ============================================================================
-- FORMATTING
-- ============================================================================

require('conform').setup({
	-- Define formatters by filetype
	formatters_by_ft = {
		-- Java: use LSP (jdtls) as primary
		java = { 'lsp' },

		-- TypeScript/JavaScript: eslint --fix first, then prettier
		typescript = { 'eslint_d', 'prettier' },
		typescriptreact = { 'eslint_d', 'prettier' },
		javascript = { 'eslint_d', 'prettier' },
		javascriptreact = { 'eslint_d', 'prettier' },

		-- Vue: volar (LSP) handles formatting
		vue = { 'lsp' },

		-- Lua: stylua if available, fallback to LSP
		lua = { 'stylua', 'lsp' },

		-- JSON/YAML/Markdown: prettier
		json = { 'prettier' },
		yaml = { 'prettier' },
		markdown = { 'prettier' },
	},

	-- Format on save configuration
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},

	-- Notify on formatting errors
	notify_on_error = true,
})

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================
