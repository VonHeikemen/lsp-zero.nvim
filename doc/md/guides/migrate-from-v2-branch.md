# Migrating from v2 branch

Here you will find how to re-enable most of the features that were removed from the `v2.x` branch. If you want to see a complete config example, go to [example config](#example-config).

## Automatic install of language servers

In order to get automatic install of language server you will have to use the module `mason-lspconfig` and list the servers in the `ensure_installed` option. Like this.

```lua
require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {'tsserver', 'rust_analyzer'},
})
```

## Automatic configuration of language servers

To configure the language servers installed with `mason.nvim` automatically you should use the module `mason-lspconfig`.

You'll need to use the option `handlers` in mason-lspconfig. You can use the function [.default_setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#default_setupserver) as a default handler.

```lua
local lsp_zero = require('lsp-zero')

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {
    lsp_zero.default_setup,
  }
})
```

To get more details on how to use mason.nvim with lsp-zero read this guide: [Integrate with mason.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md)

## Disable a language server

You'll also need to use the option `handlers` in mason-lspconfig in order to disable a language server. This is in place of the `skip_server_setup` that was present in the `v2.x` branch.

```lua
local lsp_zero = require('lsp-zero')

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {
    lsp_zero.default_setup,
    jdtls = lsp_zero.noop,
  }
})
```

## Setup lua_ls using mason-lspconfig

When using mason-lspconfig, if you want to configure a language server you need to add a handler with the name of the language server. In this handler you will assign a lua function, and inside this function you will configure the server.

```lua
local lsp_zero = require('lsp-zero')

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {
    lsp_zero.default_setup,
    lua_ls = function()
      local lua_opts = lsp_zero.nvim_lua_ls()
      require('lspconfig').lua_ls.setup(lua_opts)
    end,
  }
})
```

## Completion item label

In `v2.x` each completion item has a label that shows the source that created the item. This feature is now opt-in, you can use the function [.cmp_format()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#cmp_format) to get the settings needed for nvim-cmp.

```lua
local cmp = require('cmp')
local cmp_format = require('lsp-zero').cmp_format()

cmp.setup({
  formatting = cmp_format,
})
```

## Scroll the documentation of completion item

In version 3 of lsp-zero the basic options of nvim-cmp will be configured automatically. As a consequence of this change I can only set keybindings that emulate Neovim's default behavior.

To scroll the documentation window you will have to set the mappings manually.

```lua
local cmp = require('cmp')

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- scroll up and down the documentation window
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  }),
})
```

## Example Config

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
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},

  -- LSP Support
  {'neovim/nvim-lspconfig'},
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},

  -- Autocompletion
  {'hrsh7th/nvim-cmp'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'L3MON4D3/LuaSnip'},
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

local cmp = require('cmp')
local cmp_format = lsp_zero.cmp_format()

cmp.setup({
  formatting = cmp_format,
  mapping = cmp.mapping.preset.insert({
    -- scroll up and down the documentation window
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  }),
})
```

