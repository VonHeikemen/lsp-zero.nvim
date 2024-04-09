# Integrate with mason.nvim

We can use [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) to help us manage the installation of language servers. And then we can use [lspconfig](https://github.com/neovim/nvim-lspconfig) to setup the servers only when they are installed.

Here is a basic example.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  -- Replace the language servers listed here 
  -- with the ones you want to install
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})
```

This config will tell `mason-lspconfig` to install tsserver and rust_analyzer automatically if they are missing. And lsp-zero will handle the configuration of those servers.

The servers listed in the `ensure_installed` option must be on [this list](https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers).

Note that after you install a language server you will need to restart Neovim so the language can be configured properly.

## Configure a language server

If we need to add a custom configuration for a server, you'll need to add a property to `handlers`. This new property must have the same name as the language server you want to configure, and you need to assign a function to it.

Lets use an imaginary language server called `example_server` as an example.

```lua
--- in your own config you should replace 
--- `example_server` with the name of a language server

require('mason-lspconfig').setup({
  handlers = {
    -- this first function is the "default handler"
    -- it applies to every language server without a "custom handler"
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,

    -- this is the "custom handler" for `example_server`
    example_server = function()
      require('lspconfig').example_server.setup({
        ---
        -- in here you can add your own
        -- custom configuration
        ---
      })
    end,
  },
})
```

Here we use the module `lspconfig` to setup the language server and we add our custom config in the first argument of `.example_server.setup()`.

## Exclude a language server from the automatic setup

If we want to ignore a language server we can use the function [.noop()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#noop) as a handler. This will make `mason-lspconfig` ignore the setup for the language server.

```lua
--- in your own config you should replace 
--- `example_server` with the name of a language server

require('mason-lspconfig').setup({
  handlers = {
    -- this first function is the "default handler"
    -- it applies to every language server without a "custom handler"
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,

    -- this is the "custom handler" for `example_server`
    -- noop is an empty function that doesn't do anything
    example_server = lsp_zero.noop,
  },
})
```

So `example_server = lsp_zero.noop` is the same thing as this.

```lua
example_server = function() end
```

When the time comes for `mason-lspconfig` to setup `example_server` it will execute an empty function.

## The default_setup shortcut

In lsp-zero there is a function called [.default_setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#default_setupserver), this purpose of this function is to act as a default handler in `mason-lspconfig`'s options. Like this.

```lua
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
  },
})
```

This way you can setup your language server without needing to call `lspconfig` yourself.

### Why is this not in the other documentation examples?

This used to be the recommended way of to configure lsp-zero. The problem with [.default_setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#default_setupserver) is not about the code behind it, is about people. When new users ask for help on discord or reddit they don't get support from the community. [.default_setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#default_setupserver) hides the fact that [lspconfig](https://github.com/neovim/nvim-lspconfig) is being called, so new users don't know how to ask the right questions, and other Neovim users often will advice against using lsp-zero. The documentation now shows an explicit setup with [lspconfig](https://github.com/neovim/nvim-lspconfig), my hope is that increases the chances of new users getting the support they need.

You can still use [.default_setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#default_setupserver) if you want, but you have to know how to ask the right question when you ask for help online.

### Behind the scenes

If you want to know, this is what happens behind the scenes when you call [.default_setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#default_setupserver).

```lua
-- just in case: there is no need to copy/paste this example in your own config
-- this snippet exists only for educational purpose.

require('mason-lspconfig').setup({
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {
    function(name)
      local lsp = require('lspconfig')[name]
      if lsp.manager then
        -- if lsp.manager is defined it means the
        -- language server was configured some place else
        return
      end

      -- at this point lsp-zero has already applied
      -- the "capabilities" options to lspconfig's defaults. 
      -- so there is no need to add them here manually.

      lsp.setup({})
    end,
  },
})
```

