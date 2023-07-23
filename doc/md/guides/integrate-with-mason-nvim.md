# Integrate with mason.nvim

We can use [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) to help us manage the installation of language servers. And then we can use lsp-zero to help with the automatic configuration.

Here is a basic example.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.extend_cmp()

require('mason').setup({})
require('mason-lspconfig').setup({
  -- Replace the language servers listed here 
  -- with the ones you want to install
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {lsp.default_setup},
})
```

This config will tell `mason-lspconfig` to install tsserver and rust_analyzer automatically if they are missing. And lsp-zero will handle the configuration of those servers.

Note that after you install a language server you will need to restart Neovim so the language can be configured properly.

## Configure a language server

If we need to add a custom configuration for a server, you'll need to add a property to `handlers`. This new property must have the same name as the language server you want to configure, and you need to assign a function to it.

Lets use `tsserver` as an example.

```lua
require('mason-lspconfig').setup({
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {
    lsp.default_setup,
    tsserver = function()
      require('lspconfig').tsserver.setup({
        settings = {
          completions = {
            completeFunctionCalls = true
          }
        }
      })
    end,
  },
})
```

Here we use the module `lspconfig` to setup the language server and we add our custom config in the first argument of `.tsserver.setup()`.

## Exclude a language server from the automatic setup

If we want to ignore a language server we can use the function [.noop()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/compat-07/doc/md/api-reference.md#noop), which is a function that doesn't do anything.

```lua
require('mason-lspconfig').setup({
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {
    lsp.default_setup,
    tsserver = lsp.noop,
  },
})
```

When the time comes for `mason-lspconfig` to setup `tsserver` it will execute an empty function.

