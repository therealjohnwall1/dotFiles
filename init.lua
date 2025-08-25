-- ~/.config/nvim/init.lua

-- -----------------------------------------------------------------------------------------------
-- Plugin Manager: lazy.nvim
-- -----------------------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- -----------------------------------------------------------------------------------------------
-- Basic Editor Settings
-- -----------------------------------------------------------------------------------------------
vim.g.mapleader = " " -- Set the <leader> key to spacebar
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.hlsearch = true       -- Highlight search results
vim.opt.ignorecase = true     -- Ignore case when searching
vim.opt.smartcase = true      -- ...unless the search term contains uppercase letters
vim.opt.tabstop = 2           -- Tabs are 2 spaces
vim.opt.shiftwidth = 2        -- Indents are 2 spaces
vim.opt.expandtab = true      -- Use spaces instead of tabs
vim.opt.termguicolors = true  -- Enable true color support
vim.opt.wrap = false          -- Do not wrap lines
vim.opt.mouse = "a"           -- Enable mouse support in all modes

-- -----------------------------------------------------------------------------------------------
-- Custom Functions for Pasting
-- -----------------------------------------------------------------------------------------------
-- Function to remove trailing whitespace and carriage returns (^M) from the buffer
local function Trim()
    local save = vim.fn.winsaveview()
    -- keeppatterns: Don't add the search pattern to history
    -- %s/.../.../: Substitute across the whole file
    -- \\s\\+$: Find whitespace at the end of a line
    -- \\|: OR
    -- \\r$: Find a carriage return at the end of a line
    -- //: Replace with nothing
    -- e: Suppress errors if no match is found
    vim.cmd("keeppatterns %s/\\s\\+$\\|\\r$//e")
    vim.fn.winrestview(save)
end

-- Function to paste AFTER the cursor and then trim the buffer
function Paste_after_and_trim()
    -- Perform the default paste action for 'p'
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('p', true, false, true), 'n', false)
    -- Schedule the trim function to run after the paste is complete
    vim.schedule(function()
        Trim()
    end)
end

-- Function to paste BEFORE the cursor and then trim the buffer
function Paste_before_and_trim()
    -- Perform the default paste action for 'P'
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('P', true, false, true), 'n', false)
    -- Schedule the trim function to run after the paste is complete
    vim.schedule(function()
        Trim()
    end)
end

-- Disable netrw, the default file explorer, to use nvim-tree instead
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- --- Clipboard Integration for WSL ---
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WSL-Clipboard",
    copy = { ["+"] = "clip.exe" },
    paste = { ["+"] = 'powershell.exe -c [Console]::InputEncoding = [System.Text.Encoding]::UTF8; Get-Clipboard | ForEach-Object { $_ -replace "`r`n", "`n" }' },
    cache_enabled = 1,
  }
end
vim.opt.clipboard = "unnamedplus" -- Use system clipboard for default yank/paste


-- -----------------------------------------------------------------------------------------------
-- Keymaps
-- -----------------------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help Tags" })
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle File Explorer" })

-- Override default paste to remove carriage returns (^M)
vim.keymap.set("n", "p", "<Cmd>lua Paste_after_and_trim()<CR>", { desc = "Paste and remove carriage returns" })
vim.keymap.set("n", "P", "<Cmd>lua Paste_before_and_trim()<CR>", { desc = "Paste (before) and remove carriage returns" })

vim.keymap.set({'n', 'v'}, '<Leader>l', ':tabnext<CR>', { silent = true, desc = "Go to next tab" })
vim.keymap.set({'n', 'v'}, '<Leader>h', ':tabprevious<CR>', { silent = true, desc = "Go to previous tab" })


-- -----------------------------------------------------------------------------------------------
-- Plugin Definitions
-- -----------------------------------------------------------------------------------------------
local plugins = {
  -- Colorscheme: Gruvbox
  -- ADD THIS SECTION
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000, -- Make sure to load this before all the other start plugins
    config = function()
      -- This is where you configure and apply the colorscheme
      local theme_mode = os.getenv("NVIM_THEME") or "dark"

      if theme_mode == "light" then
        vim.o.background = "light"
      else
        vim.o.background = "dark"
      end

      -- For more configuration options, see the plugin's documentation
      -- require("gruvbox").setup({
      --   -- your settings go here
      -- })

      -- Apply the colorscheme
      vim.cmd.colorscheme "gruvbox"
    end,
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "javascript", "typescript", "rust", "go" },
        sync_install = false,
        auto_install = true,
        highlight = { enable = true },
      })
    end,
  },

  -- Fuzzy Finding with Telescope
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
    }
  },

  -- Snippets
  { 'L3MON4D3/LuaSnip', version = "v2.*", build = "make install_jsregexp" },

  -- File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
    end,
  },

  -- LSP (Language Server Protocol)
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
}


-- -----------------------------------------------------------------------------------------------
-- Load Plugins
-- -----------------------------------------------------------------------------------------------
require("lazy").setup(plugins, {})


-- -----------------------------------------------------------------------------------------------
-- Plugin Configurations
-- -----------------------------------------------------------------------------------------------

-- --- Telescope ---
local telescope = require('telescope')
telescope.setup({
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})
telescope.load_extension('fzf')

-- --- nvim-cmp (Autocompletion) ---
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
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
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  })
})

-- --- LSP (Language Server Protocol) ---
local lspconfig = require('lspconfig')
local on_attach = function(client, bufnr)
  -- This function runs when an LSP server attaches to a buffer.
  -- It creates keymaps that are only active for that buffer.
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

require('mason').setup()
require('mason-lspconfig').setup()

local servers = { 'lua_ls', 'pyright', 'gopls', 'tsserver', 'rust_analyzer' }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
  }
end

