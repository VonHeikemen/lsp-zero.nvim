# Migrating from v1 branch

Here you will find how to re-enable most of the features that were removed from the `v1.x` branch. If you want to see a complete config example, go to [example config](#example-config).

## Configure diagnostic

In `v2.x` lsp-zero doesn't configure diagnostic, you just get the default Neovim behaviour. If you want to get the icons and the config, add this code after lsp-zero's [.setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup) function.

```lua
lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = ''
})

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = {
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
})
```

## Configure the lua language server

Now you will need to setup `lua_ls` using lspconfig, and then add the configuration using the function [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#nvim_lua_lsopts). Make your sure you do this before calling lsp-zero's [.setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup) function. 

```lua
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
```

## Configure autocomplete sources

In `v2.x` only the source to get LSP completions is configured. If you want to use the previous recommended sources install these plugins in your Neovim config:

* [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
* [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
* [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)
* [hrsh7th/cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua)
* [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
* [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
* [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) 

Then you can configure nvim-cmp after lsp-zero's [.setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup) function.

```lua
local cmp = require('cmp')
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'nvim_lua'},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  },
})
```

## Configure autocomplete mappings

Make sure you configure nvim-cmp after lsp-zero's [.setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup) function. Then you can add the mappings you want in your cmp setup. This config uses the old mappings from `v1.x`.

```lua
local cmp = require('cmp')
local cmp_action = require('lsp-zero.cmp').action()

cmp.setup({
  mapping = {
    -- confirm completion item
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- toggle completion menu
    ['<C-e>'] = cmp_action.toggle_completion(),

    -- tab complete
    ['<Tab>'] = cmp_action.tab_complete(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),

    -- navigate between snippet placeholder
    ['<C-d>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),

    -- scroll documention window
    ['<C-f>'] = cmp.mapping.scroll_docs(-5),
    ['<C-d>'] = cmp.mapping.scroll_docs(5),
  },
})
```

## Add borders to documention window in completion menu

Make sure you configure nvim-cmp after lsp-zero's [.setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup) function. Then you can add the config to the `window.documention` property in nvim-cmp.

```lua
local cmp = require('cmp')

cmp.setup({
  window = {
    documention = cmp.config.window.bordered(),
  }
})
```

## Preselect first completion item

Make sure you configure nvim-cmp after lsp-zero's [.setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup) function. Then you can add the following settings to nvim-cmp.

```lua
local cmp = require('cmp')
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

cmp.setup({
  preselect = 'item',
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
})
```

## Example config

The following config recreates most of the features that were removed in `v1.x` branch.

```lua
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
vim.opt.rtp:prepend(lazypath)

local ok, lazy = pcall(require, 'lazy')

if not ok then
  local msg = 'You need to install the plugin manager lazy.nvim\n'
    .. 'in this folder: ' .. lazypath

  print(msg)
  return
end

lazy.setup({
  {'VonHeikemen/lsp-zero.nvim', branch = 'v2.x'}

  -- LSP Support
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'neovim/nvim-lspconfig'},

  -- Autocompletion
  {'hrsh7th/nvim-cmp'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/cmp-buffer'},
  {'hrsh7th/cmp-path'},
  {'saadparwaiz1/cmp_luasnip'},
  {'hrsh7th/cmp-nvim-lua'},
  {'L3MON4D3/LuaSnip'},
  {'rafamadriz/friendly-snippets'},
})

local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()

lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = ''
})

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = {
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
})

local cmp = require('cmp')
local cmp_action = require('lsp-zero.cmp').action()

require('luasnip.loaders.from_vscode').lazy_load()

vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

cmp.setup({
  preselect = 'item',
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  window = {
    documention = cmp.config.window.bordered(),
  },
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'nvim_lua'},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  },
  mapping = {
    -- confirm completion item
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- toggle completion menu
    ['<C-e>'] = cmp_action.toggle_completion(),

    -- tab complete
    ['<Tab>'] = cmp_action.tab_complete(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),

    -- navigate between snippet placeholder
    ['<C-d>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),

    -- scroll documention window
    ['<C-f>'] = cmp.mapping.scroll_docs(-5),
    ['<C-d>'] = cmp.mapping.scroll_docs(5),
  },
})
```

