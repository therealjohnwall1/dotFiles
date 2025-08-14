-- ~/.config/nvim/init.lua

-- -----------------------------------------------------------------------------------------------
-- Plugin Manager: lazy.nvim
-- -----------------------------------------------------------------------------------------------
-- This section automatically installs lazy.nvim if it's not already present.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- -----------------------------------------------------------------------------------------------
-- Basic Editor Settings
-- -----------------------------------------------------------------------------------------------
vim.g.mapleader = " " -- Set the <leader> key to spacebar
vim.opt.number = true              -- Show line numbers
vim.opt.relativenumber = true      -- Show relative line numbers
vim.opt.hlsearch = true            -- Highlight search results
vim.opt.ignorecase = true          -- Ignore case when searching
vim.opt.smartcase = true           -- ...unless the search term contains uppercase letters
vim.opt.tabstop = 2                -- Tabs are 2 spaces
vim.opt.shiftwidth = 2             -- Indents are 2 spaces
vim.opt.expandtab = true           -- Use spaces instead of tabs
vim.opt.termguicolors = true       -- Enable true color support
vim.opt.wrap = false               -- Do not wrap lines
vim.opt.mouse = "a"                -- Enable mouse support in all modes

-- Disable netrw, the default file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- --- Clipboard Integration for WSL ---
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WSL-Clipboard",
    copy = { ["+"] = "clip.exe" },
    paste = { ["+"] = 'powershell.exe -c [Console]::InputEncoding = [System.Text.Encoding]::UTF8; Get-Clipboard' },
    cache_enabled = 1,
  }
end
vim.opt.clipboard = "unnamedplus" -- Use system clipboard for default yank/paste


-- -----------------------------------------------------------------------------------------------
-- Keymaps
-- -----------------------------------------------------------------------------------------------
-- Note: <leader> is the spacebar
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help Tags" })
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle File Explorer" })


-- -----------------------------------------------------------------------------------------------
-- Plugin Definitions
-- -----------------------------------------------------------------------------------------------
local plugins = {
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
    dependencies = { "nvim-lua/plenary.nvim" },
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
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Recommended for file icons
    config = function()
      require("nvim-tree").setup({})
    end,
  },
}


-- -----------------------------------------------------------------------------------------------
-- Load Plugins
-- -----------------------------------------------------------------------------------------------
require("lazy").setup(plugins, {})


-- -----------------------------------------------------------------------------------------------
-- Plugin Config
-- -----------------------------------------------------------------------------------------------
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
