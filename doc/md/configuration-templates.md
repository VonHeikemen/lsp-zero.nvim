# Configuration templates

Note: after you install a language server with `mason.nvim` there is a good chance the server won't be able to initialize correctly. Try to "refresh" the file with the command `:edit`, and if that doesn't work restart neovim.

## Lua template

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
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {                                      -- Optional
        'williamboman/mason.nvim',
        build = function()
          pcall(vim.cmd, 'MasonUpdate')
        end,
      },
      {'williamboman/mason-lspconfig.nvim'}, -- Optional

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    }
  }
})

local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()
```

## vimscript template

Make sure to download [vim-plug](https://github.com/junegunn/vim-plug) (the plugin manager) before you copy this code into your config (`init.vim`).

```vim
call plug#begin()
  " LSP Support
  Plug 'neovim/nvim-lspconfig'                           " Required
  Plug 'williamboman/mason.nvim', {'do': ':MasonUpdate'} " Optional
  Plug 'williamboman/mason-lspconfig.nvim'               " Optional

  " Autocompletion
  Plug 'hrsh7th/nvim-cmp'         " Required
  Plug 'hrsh7th/cmp-nvim-lsp'     " Required
  Plug 'L3MON4D3/LuaSnip'         " Required

  Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v2.x'}
call plug#end()


lua <<EOF
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- " (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()
EOF
```

