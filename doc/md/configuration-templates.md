# Configuration templates

## Lua template

This configuration assume you want to use `mason.nvim` to install (and update) your language servers. Note that after you install a language server with mason.nvim there is a good chance the server won't be able to initialize correctly the first time. Try to "refresh" the file with the command `:edit`, and if that doesn't work restart Neovim.

```lua
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

-- Auto-install lazy.nvim if not present
if not vim.loop.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
  {'L3MON4D3/LuaSnip'},
})

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- see :help lsp-zero-guide:integrate-with-mason-nvim
-- to learn how to use mason.nvim with lsp-zero
require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
  }
})
```

## vimscript template

This configuration assumes you want to use `mason.nvim` to install (and update) your language servers. Note that after you install a language server with mason.nvim there is a good chance the server won't be able to initialize correctly the first time. Try to "refresh" the file with the command `:edit`, and if that doesn't work restart Neovim.

Make sure to download [vim-plug](https://github.com/junegunn/vim-plug) (the plugin manager) before you copy this code into your config (`init.vim`).

```vim
call plug#begin()
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'L3MON4D3/LuaSnip'
  Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v3.x'}
call plug#end()


lua <<EOF
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- see :help lsp-zero-guide:integrate-with-mason-nvim
-- to learn how to use mason.nvim with lsp-zero
require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
  }
})
EOF
```

