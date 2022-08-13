-- -------------------------
-- OPTIONS
-- -------------------------
local g = vim.g
local o = vim.o

o.termguicolors = true          -- more colors
o.timeoutlen = 500              -- time to wait for mapped sequence to complete
o.updatetime = 200              -- faster completion		
o.scrolloff = 15                 -- Number of screen lines to keep above and below the cursor
o.number = true                 -- Line numbers
o.numberwidth = 4               -- Line numbers padding
o.relativenumber = true         -- Relative line number
o.signcolumn = 'yes'            -- Always show the sign column (where debug markers/breakpoints go)
o.cursorline = true             -- Highlight current line
o.expandtab = true              -- convert tabs to spaces
o.shiftwidth = 2                -- the number of spaces inserted for each indentation
o.tabstop = 2                   -- insert 2 spaces for a tab
o.autoindent = true             -- auto indent shit
o.clipboard = 'unnamedplus'     -- Makes neovim and host OS clipboard play nicely with each other
o.ignorecase = true             -- Case insensitive searching
o.smartcase = true              -- Override ignorecase if serach contains capital letter
o.backup = false                -- Creates a backup file
o.writebackup = false           -- Creates a backup file before writing and then deletes after successful write
o.undofile = true               -- persistent undo
o.swapfile = false              -- creates a swapfile
o.hlsearch = true               -- highlight all matches on previous search pattern
o.conceallevel = 0              -- so that `` is visible in markdown files
o.cmdheight = 2                 -- more space in the neovim command line for displaying messages
o.splitbelow = true             -- force all horizontal splits to go below current window
o.splitright = true             -- force all vertical splits to go to the right of current window

vim.cmd "set whichwrap+=<,>,[,],h,l"
vim.cmd [[set iskeyword+=-]]    -- Add '-' to keywords which allows something like dw to delete asdf-afsgf

-- Color schema
vim.cmd "colorscheme PaperColor"


-- -------------------------
-- PLUGINS
-- -------------------------
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Base lib for a other plugins (some lua functions essentially)
  use 'nvim-lua/plenary.nvim'

  -- color schemes
  use {
    'morhetz/gruvbox',
    'folke/tokyonight.nvim',
    'NLKNguyen/papercolor-theme'
  }

  -- completions
  use {
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'L3MON4D3/LuaSnip',
    'onsails/lspkind.nvim',
  }

  -- lsp
  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    --  "jose-elias-alvarez/null-ls.nvim"
  }

end)


-- -------------------------
-- KEYBINDINGS
-- -------------------------
local function map(m, k, v)
    vim.keymap.set(m, k, v, { silent = true })
end

-- Map <leader> to space
g.mapleader = ' '
g.maplocalleader = ' '

-- Fix * (Keep the cursor position, don't move to next match)
map('n', '*', '*N')

-- Fix n and N. Keeping cursor in center
map('n', 'n', 'nzz')
map('n', 'N', 'Nzz')

-- Mimic shell movements
map('i', '<C-E>', '<ESC>A')
map('i', '<C-A>', '<ESC>I')

-- Quickly save the current buffer or all buffers
map('n', '<leader>w', ':update<CR>')
map('n', '<leader>W', ':wall<CR>')

-- Quit neovim
map('n', '<C-Q>', ':q<CR>')

-- Move to the next/previous buffer
map('n', '<leader>[', ':bp<CR>')
map('n', '<leader>]', ':bn<CR>')

-- Move to last buffer
map('n', "''", ':b#<CR>')

-- Copying the vscode behaviour of making tab splits
map('n', '<C-\\>', ':vsplit<CR>')
map('n', '<A-\\>', ':split<CR>')

-- Move line up and down in NORMAL and VISUAL modes
map('n', '<C-j>', ':move .+1<CR>')
map('n', '<C-k>', ':move .-2<CR>')
map('x', '<C-j>', ":move '>+1<CR>gv=gv")
map('x', '<C-k>', ":move '<-2<CR>gv=gv")

-- e.g. dA = delete buffer ALL, yA = copy whole buffer ALL
map('o', 'A', ':<C-U>normal! mzggVG<CR>`z')
map('x', 'A', ':<C-U>normal! ggVG<CR>')


-- -------------------------
-- AUTO COMMANDS
-- -------------------------

-- Custom filetypes
vim.filetype.add({
    extension = {
        eslintrc = 'json',
        prettierrc = 'json',
        conf = 'conf',
        mdx = 'markdown',
        mjml = 'html',
    },
    pattern = {
        ['.*%.env.*'] = 'sh',
        ['ignore$'] = 'conf',
    },
    filename = {
        ['yup.lock'] = 'yaml',
    },
})

-- Highlight the region on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank({ higroup = 'Visual' })
    end,
})


-- -------------------------
-- Completions (nvim-cmp)
-- -------------------------- 
local cmp_status, cmp = pcall(require, "cmp")
if (not cmp_status or not cmp) then return end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if (not snip_status_ok or not luasnip) then return end

local lspkind_status_ok, lspkind = pcall(require, "lspkind")
if (not lspkind_status_ok or not lspkind) then return end


cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  formatting = {
    format = lspkind.cmp_format({
      maxwidth = 50,
      mode = 'symbol_text'
    })
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  }),
  window = {
    documentation = {
      border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    },
  },
})

-- -------------------------
-- LSP (mason + nvim-lspconfig + cmp-nvim-lsp)
-- -------------------------- 
require("mason").setup()
require("mason-lspconfig").setup()

local lsp_conf_status, lsp_conf = pcall(require, "lspconfig")
if (not lsp_conf_status or not lsp_conf) then return end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local opts = { noremap = true, silent = true }

  -- Jumps to the declaration of the symbol
	buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)

  -- Jumps to the definition of the symbol
	buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)

  -- Displays hover information about the symbol
	buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

  -- Lists all the implementations for the symbol
	buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)

  -- Displays signature information about the symbol
	buf_set_keymap("n", "<C-i>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)

  -- Lists all the references to the symbol
	buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)

	-- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)

  -- Move to the next/previous diagnostic in the current buffer
	buf_set_keymap("n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
	buf_set_keymap("n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)

  -- Show diagnostics in a floating window
	buf_set_keymap("n", "gl", '<cmd>lua vim.diagnostic.open_float({ border = "rounded" })<CR>', opts)

  -- dd buffer diagnostics to the location list
	buf_set_keymap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

	vim.cmd([[ command! Format execute 'lua vim.lsp.buf.format{async=true}' ]])
end

-- Set up completion using nvim_cmp with LSP source
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if (not cmp_nvim_lsp_status) then return end

local capabilities = cmp_nvim_lsp.update_capabilities(
  vim.lsp.protocol.make_client_capabilities()
)

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

-- Lua
lsp_conf.sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  flags = lsp_flags,
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false
      },
    },
  },
}

-- TypeScript
lsp_conf.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  cmd = { "typescript-language-server", "--stdio" },
}

-- CSS
lsp_conf.cssls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- HTML
lsp_conf.html.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}



-- Diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.diagnostic.config({
  virtual_text = false,
  update_in_insert = true,
  underline = true,
  float = {
    source = "always", -- Or "if_many"
  },
})
