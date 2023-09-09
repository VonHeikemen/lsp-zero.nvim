# Migrating from v1 branch

Here you will find how to re-enable most of the features that were removed from the `v1.x` branch. If you want to see a complete config example, go to [example config](#example-config).

## Configure diagnostics

In `v3.x` lsp-zero doesn't configure diagnostics anymore, you just get the default Neovim behaviour. If you want to get the icons and the config, add this code.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.set_sign_icons({
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
local lsp_zero = require('lsp-zero')

local lua_opts = lsp_zero.nvim_lua_ls()
require('lspconfig').lua_ls.setup(lua_opts)
```

## Enable automatic setup of language servers

This can be done using the module `mason-lspconfig`. In their `.setup()` function you will need to configure a property called `handlers`. You can use the function [.default_setup](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#default_setupserver) of lsp-zero as a "default handler" and this will be enough to get the behaviour you want.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
  }
})
```

To add a custom configuration to a server you need to add property to `handlers`, this property must be the name of the language server and you must assign a function. In this new function is where you will configure the language server.

```lua
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
    lua_ls = function()
      local lua_opts = lsp_zero.nvim_lua_ls()
      require('lspconfig').lua_ls.setup(lua_opts)
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

## Configure completion sources

In `v3.x` only the source to get LSP completions is configured. If you want to use the previous recommended sources install these plugins in your Neovim config:

* [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
* [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
* [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)
* [hrsh7th/cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua)
* [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
* [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
* [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) 

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

You can add the mappings you want in your cmp setup. This config uses the old mappings from `v1.x`.

```lua
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
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

    -- scroll documentation window
    ['<C-f>'] = cmp.mapping.scroll_docs(-5),
    ['<C-d>'] = cmp.mapping.scroll_docs(5),
  }),
})
```

## Add borders to documentation window in completion menu

Add nvim-cmp's preset to the `window.documentation` property.

```lua
local cmp = require('cmp')

cmp.setup({
  window = {
    documentation = cmp.config.window.bordered(),
  }
})
```

## Preselect first completion item

Add the following settings to nvim-cmp.

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

## Completion item label

In `v1.x` each completion item has a label that shows the source that created the item. This feature is now opt-in, you can use the function [.cmp_format()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#cmp_format) to get the settings needed for nvim-cmp.

```lua
local cmp = require('cmp')
local cmp_format = require('lsp-zero').cmp_format()

cmp.setup({
  formatting = cmp_format,
})
```

## Example config

The following config recreates most of the features that were removed from the `v1.x` branch.

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
  {'VonHeikemen/lsp-zero.nvim', branch = 'dev-v3'},

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

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {},
  handlers = {
    lsp_zero.default_setup,
    lua_ls = function()
      local lua_opts = lsp_zero.nvim_lua_ls()
      require('lspconfig').lua_ls.setup(lua_opts)
    end,
  }
})

lsp_zero.set_sign_icons({
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
local cmp_action = lsp_zero.cmp_action()
local cmp_format = lsp_zero.cmp_format()

require('luasnip.loaders.from_vscode').lazy_load()

vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

cmp.setup({
  formatting = cmp_format,
  preselect = 'item',
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  window = {
    documentation = cmp.config.window.bordered(),
  },
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'nvim_lua'},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  },
  mapping = cmp.mapping.preset.insert({
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

    -- scroll documentation window
    ['<C-f>'] = cmp.mapping.scroll_docs(5),
    ['<C-u>'] = cmp.mapping.scroll_docs(-5),
  }),
})
```

