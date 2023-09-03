# Integrate with null-ls

## Standalone null-ls instance

null-ls isn't a real language server, you don't have to do anything to integrate it with lsp-zero. Just use it.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones installed in your system
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    -- Replace these with the tools you have installed
    -- make sure the source name is supported by null-ls
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.formatting.stylua,
  }
})
```

### Format buffer using only null-ls

You can assign a keyboard shortcut using the [.format_mapping()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/compat-07/doc/md/api-reference.md#format_mappingkey-opts) function. This will allow you to specify a list of filetypes where you want to format using null-ls. 

Here is an example showing a setup focused on lua and javascript. We assign the keymap `gq` to format.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.format_mapping('gq', {
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
    ['rust_analyzer'] = {'rust'},
    ['null-ls'] = {'javascript', 'typescript', 'lua'},
  }
})

-- Replace the language servers listed here
-- with the ones installed in your system
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    -- Replace these with the tools you have installed
    -- make sure the source name is supported by null-ls
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettier,
  }
})
```

### Format on save

This can be almost the same as the previous example, except here we replace the function [.format_mapping()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/compat-07/doc/md/api-reference.md#format_mappingkey-opts) with [.format_on_save()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/compat-07/doc/md/api-reference.md#format_on_save-opts).

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.format_on_save({
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
    ['rust_analyzer'] = {'rust'},
    ['null-ls'] = {'javascript', 'typescript', 'lua'},
  }
})

-- Replace the language servers listed here
-- with the ones installed in your system
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    -- Replace these with the tools you have installed
    -- make sure the source name is supported by null-ls
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
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
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones installed in your system
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    -- Replace these with the tools you want to install
    -- make sure the source name is supported by null-ls
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
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
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones installed in your system
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})

local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    -- Here you can add tools not supported by mason.nvim
    -- make sure the source name is supported by null-ls
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
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

