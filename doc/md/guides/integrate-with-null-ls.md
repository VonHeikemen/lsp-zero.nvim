# Intergrate with null-ls

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

## Format buffer using only null-ls

The solution I propose here is to use the `on_attach` function to create a command called `NullFormat`. This new command will have all the arguments necessary to send a formatting request specifically to null-ls. You could then create a keymap bound to the `NullFormat` command.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()

local null_ls = require('null-ls')

null_ls.setup({
  on_attach = function(client, bufnr)
    local format_cmd = function(input)
      vim.lsp.buf.format({
        id = client.id,
        timeout_ms = 5000,
        async = input.bang,
      })
    end

    local bufcmd = vim.api.nvim_buf_create_user_command
    bufcmd(bufnr, 'NullFormat', format_cmd, {
      bang = true,
      range = true,
      desc = 'Format using null-ls'
    })

    vim.keymap.set('n', 'gq', '<cmd>NullFormat!<cr>', {buffer = bufnr})
  end,
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
  automatic_setup = false,
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
    -- You can add tools not supported by mason.nvim
  }
})

-- See mason-null-ls.nvim's documentation for more details:
-- https://github.com/jay-babu/mason-null-ls.nvim#setup
require('mason-null-ls').setup({
  ensure_installed = nil,
  automatic_installation = false, -- You can still set this to `true`
  automatic_setup = true,
})

-- Required when `automatic_setup` is true
require('mason-null-ls').setup_handlers()
```

