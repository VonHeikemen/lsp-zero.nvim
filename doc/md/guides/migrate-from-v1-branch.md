# Migrating from v1 branch

Here you will find how to re-enable most of the features that were removed from the `v1.x` branch. If you want to see a complete config example, go to [example config](#example-config).

## Configure diagnostics

lsp-zero doesn't configure diagnostics anymore, you just get the default Neovim behaviour. If you want to get the icons and the config, add this code.

```lua
local lsp = require('lsp-zero')

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

You will need to setup `lua_ls` using lspconfig, and then add the configuration using the function [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#nvim_lua_lsopts).

```lua
local lsp = require('lsp-zero')

require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
```

## Enable automatic setup of language servers

This can be done using the module `mason-lspconfig`. In their `.setup()` function you will need to configure a property called `handlers`. You can use the function [.default_setup](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#default_setupserver) of lsp-zero as a "default handler" and this will be enough to get the behaviour you want.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {lsp.default_setup}
})
```

To add a custom configuration to a server you need to add property to `handlers`, this property must be the name of the language server and you must assign a function. In this new function is where you will configure the language server.

```lua
require('mason-lspconfig').setup({
  handlers = {
    lsp.default_setup,
    lua_ls = function()
      require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
    end,
  }
})
```

## Automatic install of language servers

This can be done using the module `mason-lspconfig`. Use the `ensure_installed` property of their `.setup()` function. There you can list all the language servers you want to install.

```lua
require('mason-lspconfig').setup({
  ensure_installed = {'tsserver', 'rust_analyzer'},
})
```

## Enable the autocomplete plugin

In order to get the basic working configuration for nvim-cmp you must call the function [.extend_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#extend_cmpopts).

```lua
require('lsp-zero').extend_cmp()
```

## Configure completion sources

Now only the source to get LSP completions is configured. If you want to use the previous recommended sources install these plugins in your Neovim config:

* [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
* [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
* [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)
* [hrsh7th/cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua)
* [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
* [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
* [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) 

Then you can configure nvim-cmp after lsp-zero's [.extend_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#extend_cmpopts) function.

```lua
require('lsp-zero').extend_cmp()

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

Make sure you configure nvim-cmp after lsp-zero's [.extend_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#extend_cmpopts) function. Then you can add the mappings you want in your cmp setup. This config uses the old mappings from `v1.x`.

```lua
require('lsp-zero').extend_cmp()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

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

Make sure you configure nvim-cmp after lsp-zero's [.extend_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#extend_cmpopts) function. Then you can add the config to the `window.documention` property in nvim-cmp.

```lua
require('lsp-zero').extend_cmp()

local cmp = require('cmp')

cmp.setup({
  window = {
    documention = cmp.config.window.bordered(),
  }
})
```

## Preselect first completion item

Make sure you configure nvim-cmp after lsp-zero's [.extend_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#extend_cmpopts) function. Then you can add the following settings to nvim-cmp.

```lua
require('lsp-zero').extend_cmp()

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

The following config recreates most of the features that were removed from the `v1.x` branch.

```lua
local ok, packer = pcall(require, 'packer')

if not ok then
  print('You need to install the plugin manager packer.nvim')
  return
end

packer.startup(function(use)
  use {'wbthomason/packer.nvim'}

  use {'VonHeikemen/lsp-zero.nvim', branch = 'compat-07'}

  -- LSP Support
  use {'williamboman/mason.nvim'}
  use {'williamboman/mason-lspconfig.nvim'}
  use {'neovim/nvim-lspconfig'}

  -- Autocompletion
  use {'hrsh7th/nvim-cmp'}
  use {'hrsh7th/cmp-nvim-lsp'}
  use {'hrsh7th/cmp-buffer'}
  use {'hrsh7th/cmp-path'}
  use {'saadparwaiz1/cmp_luasnip'}
  use {'hrsh7th/cmp-nvim-lua'}
  use {'L3MON4D3/LuaSnip'}
  use {'rafamadriz/friendly-snippets'}
end)

local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {},
  handlers = {
    lsp.default_setup,
    lua_ls = function()
      require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
    end,
  }
})

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

require('lsp-zero').extend_cmp()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

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
    ['<C-f>'] = cmp.mapping.scroll_docs(5),
    ['<C-u>'] = cmp.mapping.scroll_docs(-5),
  },
})
```

