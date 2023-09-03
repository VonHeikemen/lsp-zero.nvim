# Quick Recipes

## Setup with nvim-navic

Here what you need to do is call [nvim-navic](https://github.com/SmiteshP/nvim-navic)'s `.attach` function inside lsp-zero's [.on_attach()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#on_attachcallback). 

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})

  if client.server_capabilities.documentSymbolProvider then
    require('nvim-navic').attach(client, bufnr)
  end
end)

-- Replace the language servers listed here
-- with the ones installed in your system
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

## Enable folds with nvim-ufo

Configure [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo) to use LSP client as a provider.

In this case you need to advertise the "folding capabilities" to the language servers.

```lua
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

require('ufo').setup()

-- Using ufo provider need remap `zR` and `zM`.
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.set_server_config({
  capabilities = {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }
    }
  }
})

-- Replace the language servers listed here
-- with the ones installed in your system
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

## Enable inlay hints with inlay-hints.nvim

First make sure you setup [inlay-hints.nvim](https://github.com/simrat39/inlay-hints.nvim). Then, visit the documentation of the language server you want to configure, figure out what options you need to enable. Finally, use `lspconfig` to enable those options and execute the `.on_attach` function of `inlay-hints.nvim`.

Here an example using the lua language server.

```lua
local ih = require('inlay-hints')
ih.setup()

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('lspconfig').lua_ls.setup({
  on_attach = function(client, bufnr)
    ih.on_attach(client, bufnr)
  end,
  settings = {
    Lua = {
      hint = {
        enable = true,
      },
    },
  },
})

-- Replace the language servers listed here
-- with the ones installed in your system
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

## Setup with rust-tools

Use [rust-tools](https://github.com/simrat39/rust-tools.nvim) to configure [rust-analyzer](https://github.com/rust-analyzer/rust-analyzer).  

`rust-tools` will use `lspconfig` to initialize the rust language server, so you need to setup rust-tools after lsp-zero.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

local rust_tools = require('rust-tools')

rust_tools.setup({
  server = {
    on_attach = function(client, bufnr)
      vim.keymap.set('n', '<leader>ca', rust_tools.hover_actions.hover_actions, {buffer = bufnr})
    end
  }
})
```

Note: if you use `mason-lspconfig.nvim` to install the language server, add a custom handler to the setup function.

```lua
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
    rust_analyzer = function()
      ---
      -- here you will setup rust-tools
      ---
    end,
  }
})
```

## Setup with flutter-tools

With [flutter-tools](https://github.com/akinsho/flutter-tools.nvim) the only thing that make sense to do is share the "capabilities" option. So, let flutter-tools initialize the language server, and have lsp-zero just configure the capabilities option.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('flutter-tools').setup({
  lsp = {
    capabilities = lsp_zero.get_capabilities()
  }
})
```

## Setup with nvim-metals

The following is based on the [example configuration](https://github.com/scalameta/nvim-metals/discussions/39) found in [nvim-metals](https://github.com/scalameta/nvim-metals) discussion section.

If I understand correctly, `nvim-metals` is the one that needs to configure the [metals lsp](https://scalameta.org/metals/). The only thing that you need to do share is the "capabilities" option with the `metals` config.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

---
-- Create the configuration for metals
---
local metals_config = require('metals').bare_config()
metals_config.capabilities = lsp_zero.get_capabilities()

---
-- Autocmd that will actually be in charging of starting metals
---
local metals_augroup = vim.api.nvim_create_augroup('nvim-metals', {clear = true})
vim.api.nvim_create_autocmd('FileType', {
  group = metals_augroup,
  pattern = {'scala', 'sbt', 'java'},
  callback = function()
    require('metals').initialize_or_attach(metals_config)
  end
})
```

## Setup with haskell-tools

The only option that makes sense to share between [haskell-tools](https://github.com/mrcjkb/haskell-tools.nvim) and lsp-zero is the "capabilities" option. So, let haskell-tools initialize the language server, and have lsp-zero just configure the capabilities option. Note these instructions are for haskell-tools version 2 (from the branch 2.x.x).

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

---
-- Setup haskell LSP
---

vim.g.haskell_tools = {
  hls = {
    capabilities = lsp_zero.get_capabilities()
  }
}

-- Autocmd that will actually be in charging of starting hls
local hls_augroup = vim.api.nvim_create_augroup('haskell-lsp', {clear = true})
vim.api.nvim_create_autocmd('FileType', {
  group = hls_augroup,
  pattern = {'haskell'},
  callback = function()
    ---
    -- Suggested keymaps from the quick setup section:
    -- https://github.com/mrcjkb/haskell-tools.nvim#quick-setup
    ---

    local ht = require('haskell-tools')
    local bufnr = vim.api.nvim_get_current_buf()
    local def_opts = { noremap = true, silent = true, buffer = bufnr, }
    -- haskell-language-server relies heavily on codeLenses,
    -- so auto-refresh (see advanced configuration) is enabled by default
    vim.keymap.set('n', '<space>ca', vim.lsp.codelens.run, opts)
    -- Hoogle search for the type signature of the definition under the cursor
    vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, opts)
    -- Evaluate all code snippets
    vim.keymap.set('n', '<space>ea', ht.lsp.buf_eval_all, opts)
    -- Toggle a GHCi repl for the current package
    vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
    -- Toggle a GHCi repl for the current buffer
    vim.keymap.set('n', '<leader>rf', function()
      ht.repl.toggle(vim.api.nvim_buf_get_name(0))
    end, def_opts)
    vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)
  end
})
```

