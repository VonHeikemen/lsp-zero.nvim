# Quick Recipes

## Setup with nvim-navic

Here what you need to do is call [nvim-navic](https://github.com/SmiteshP/nvim-navic)'s `.attach` function inside lsp-zero's [.on_attach()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#on_attachcallback). 

```lua
local lsp = require('lsp-zero').preset({})

lsp.extend_cmp()

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})

  if client.server_capabilities.documentSymbolProvider then
    require('nvim-navic').attach(client, bufnr)
  end
end)

-- Replace the language servers listed here
-- with the ones installed in your system
lsp.setup_servers({'tsserver', 'rust_analyzer'})
```

## Enable folds with nvim-ufo

Configure [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo) to use LSP client as a provider.

In this case you need to advertise the "folding capabilities" to the language servers.

```lua
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`.
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

require('ufo').setup()

local lsp = require('lsp-zero').preset({})

lsp.extend_cmp()

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.set_server_config({
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
lsp.setup_servers({'tsserver', 'rust_analyzer'})
```

## Enable inlay hints with inlay-hints.nvim

First make sure you setup [inlay-hints.nvim](https://github.com/simrat39/inlay-hints.nvim). Then, visit the documentation of the language server you want to configure, figure out what options you need to enable. Finally, use `lspconfig` to enable those options and execute the `.on_attach` function of `inlay-hints.nvim`.

Here an example using the lua language server.

```lua
local ih = require('inlay-hints')
ih.setup()

local lsp = require('lsp-zero').preset({})

lsp.extend_cmp()

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
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
lsp.setup_servers({'tsserver', 'rust_analyzer'})
```

## Setup with rust-tools

Using [rust-tools](https://github.com/simrat39/rust-tools.nvim) to configure [rust-analyzer](https://github.com/rust-analyzer/rust-analyzer).  

Here you need to setup `rust-tools` after lsp-zero.

```lua
local lsp = require('lsp-zero').preset({})

lsp.extend_cmp()

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones installed in your system
lsp.setup_servers({'tsserver'})

local rust_tools = require('rust-tools')

rust_tools.setup({
  server = {
    on_attach = function(client, bufnr)
      vim.keymap.set('n', '<leader>ca', rust_tools.hover_actions.hover_actions, {buffer = bufnr})
    end
  }
})
```

## Setup with typescript.nvim

Using [typescript.nvim](https://github.com/jose-elias-alvarez/typescript.nvim) to configure [tsserver](https://github.com/typescript-language-server/typescript-language-server).

Here you need to setup `typescript.nvim` after lsp-zero.

```lua
local lsp = require('lsp-zero').preset({})

lsp.extend_cmp()

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones installed in your system
lsp.setup_servers({'rust_analyzer'})

require('typescript').setup({
  server = {
    on_attach = function(client, bufnr)
      -- You can find more commands in the documentation:
      -- https://github.com/jose-elias-alvarez/typescript.nvim#commands

      vim.keymap.set('n', '<leader>ci', '<cmd>TypescriptAddMissingImports<cr>', {buffer = bufnr})
    end
  }
})
```

## Setup with flutter-tools

The language server for dartls can't be installed with mason.nvim, because is already bundled in the dart sdk. [flutter-tools](https://github.com/akinsho/flutter-tools.nvim) doesn't depend on lspconfig (according to the documentation), so the only thing that make sense to do is add the "capabilities" options to `flutter-tools`.

```lua
local lsp = require('lsp-zero').preset({})

lsp.extend_cmp()

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones installed in your system
lsp.setup_servers({'tsserver', 'rust_analyzer'})

require('flutter-tools').setup({
  lsp = {
    capabilities = lsp.get_capabilities()
  }
})
```

## Setup with nvim-metals

The following is based on the [example configuration](https://github.com/scalameta/nvim-metals/discussions/39) found in [nvim-metals](https://github.com/scalameta/nvim-metals) discussion section.

If I understand correctly, `nvim-metals` is the one that needs to configure the [metals lsp](https://scalameta.org/metals/). So if you installed the LSP server with mason.nvim you need to tell lsp-zero to ignore it. Then add the "capabilities" option to the `metals` config.

```lua
local lsp = require('lsp-zero').preset({})

lsp.extend_cmp()

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones installed in your system
lsp.setup_servers({'tsserver', 'rust_analyzer'})

---
-- Create the configuration for metals
---
local metals_config = require('metals').bare_config()
metals_config.capabilities = require('lsp-zero').get_capabilities()

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

Here you need to disable the automatic configuration for `hls` and then setup [haskell-tools](https://github.com/mrcjkb/haskell-tools.nvim) after lsp-zero.

The only option that makes sense to share from lsp-zero is the "capabilities" options.

```lua
local lsp = require('lsp-zero').preset({})

lsp.extend_cmp()

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones installed in your system
lsp.setup_servers({'tsserver', 'rust_analyzer'})

---
-- Setup haskell LSP
---
local haskell_tools = require('haskell-tools')

local hls_config = {
  hls = {
    capabilities = require('lsp-zero').get_capabilities(),
    on_attach = function(client, bufnr)
      local opts = {buffer = bufnr}

      -- haskell-language-server relies heavily on codeLenses,
      -- so auto-refresh (see advanced configuration) is enabled by default
      vim.keymap.set('n', '<leader>ca', vim.lsp.codelens.run, opts)
      vim.keymap.set('n', '<leader>hs', haskell_tools.hoogle.hoogle_signature, opts)
      vim.keymap.set('n', '<leader>ea', haskell_tools.lsp.buf_eval_all, opts)
    end
  }
}

-- Autocmd that will actually be in charging of starting hls
local hls_augroup = vim.api.nvim_create_augroup('haskell-lsp', {clear = true})
vim.api.nvim_create_autocmd('FileType', {
  group = hls_augroup,
  pattern = {'haskell'},
  callback = function()
    haskell_tools.start_or_attach(hls_config)

    ---
    -- Suggested keymaps that do not depend on haskell-language-server:
    ---

    -- Toggle a GHCi repl for the current package
    vim.keymap.set('n', '<leader>rr', haskell_tools.repl.toggle, opts)

    -- Toggle a GHCi repl for the current buffer
    vim.keymap.set('n', '<leader>rf', function()
      haskell_tools.repl.toggle(vim.api.nvim_buf_get_name(0))
    end, def_opts)

    vim.keymap.set('n', '<leader>rq', haskell_tools.repl.quit, opts)
  end
})
```

### Setup with clangd_extensions.nvim

[clangd_extensions.nvim](https://github.com/p00f/clangd_extensions.nvim) can be used to configure `clangd`, so all you have to do is use it after lsp-zero.

```lua
local lsp = require('lsp-zero').preset({})

lsp.extend_cmp()

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones installed in your system
lsp.setup_servers({'tsserver', 'rust_analyzer'})

require('clangd_extensions').setup()
```

