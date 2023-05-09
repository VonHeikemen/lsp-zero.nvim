# Integrate with null-ls

## Standalone null-ls instance

null-ls isn't a real language server, if you want "integrate it" with lsp-zero all you need to do is call their setup function after lsp-zero's config.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    -- Replace these with the tools you have installed
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.formatting.stylua,
  }
})
```

### Format buffer using only null-ls

You can assign a keyboard shortcut using the [.format_mapping()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#format_mappingkey-opts) function. This will allow you to specify a list of filetypes where you want to format using null-ls. 

Here is an example showing a setup focused on lua and javascript. We assign the keymap `gq` to format.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.format_mapping('gq', {
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
    ['null-ls'] = {'javascript', 'typescript', 'lua'},
  }
})

lsp.setup()

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    --- Replace these with the tools you have installed
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettier,
  }
})
```

### Format on save

This can be almost the same as the previous example, except here we replace the function [.format_mapping()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#format_mappingkey-opts) with [.format_on_save()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#format_on_save-opts).

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.format_on_save({
  format_opts = {
    timeout_ms = 10000,
  },
  servers = {
    ['null-ls'] = {'javascript', 'typescript', 'lua'},
  }
})

lsp.setup()

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    --- Replace these with the tools you have installed
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettier,
  }
})
```

## Adding mason-null-ls.nvim

[mason-null-ls.nvim](https://github.com/jay-babu/mason-null-ls.nvim) can help you install tools compatible with null-ls.

### Automatic Install

Ensure the tools you have listed in the `sources` option are installed automatically.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    -- Replace these with the tools you want to install
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.formatting.stylua,
  }
})

-- See mason-null-ls.nvim's documentation for more details:
-- https://github.com/jay-babu/mason-null-ls.nvim#setup
require('mason-null-ls').setup({
  ensure_installed = nil,
  automatic_installation = true,
})
```

### Automatic setup

Make null-ls aware of the tools you installed using mason.nvim, and configure them automatically.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    -- Here you can add tools not supported by mason.nvim
  }
})

-- See mason-null-ls.nvim's documentation for more details:
-- https://github.com/jay-babu/mason-null-ls.nvim#setup
require('mason-null-ls').setup({
  ensure_installed = nil,
  automatic_installation = false, -- You can still set this to `true`
  handlers = {
      -- Here you can add functions to register sources.
      -- See https://github.com/jay-babu/mason-null-ls.nvim#handlers-usage
      --
      -- If left empty, mason-null-ls will  use a "default handler"
      -- to register all sources
  }
})
```

