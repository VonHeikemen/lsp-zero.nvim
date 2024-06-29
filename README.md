# LSP Zero

Collection of functions that will help you use Neovim's LSP client. The aim is to provide abstractions on top of Neovim's LSP client that are easy to use.

<details>

<summary>Expand: Showcase </summary>

```lua
-- An example setup showing a bunch of functions, just because I can, no one actually uses all of this.
--
-- Some people still say lsp-zero is a "super plugin" that needs 11 other plugins to work.
-- That's not true. The only dependency you need is the language server you want to use.
-- That said, you can use lsp-zero combined with other plugins (that's what people do)

vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 800

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
  lsp_zero.highlight_symbol(client, bufnr)
  lsp_zero.buffer_autoformat()
end)

lsp_zero.omnifunc.setup({
  trigger = '<C-Space>',
  tabcomplete = true,
  use_fallback = true,
  update_on_delete = true,
  -- You need Neovim v0.10 to use vim.snippet.expand
  expand_snippet = vim.snippet.expand,
})

-- For this to work you need to install this:
-- https://github.com/LuaLS/lua-language-server
lsp_zero.new_client({
  cmd = {'lua-language-server'},
  filetypes = {'lua'},
  on_init = function(client)
    lsp_zero.nvim_lua_settings(client)
  end,
  root_dir = function(bufnr)
    -- You need Neovim v0.10 to use vim.fs.root
    -- Note: include a .git folder in the root of your Neovim config
    return vim.fs.root(bufnr, {'.git', '.luarc.json', '.luarc.jsonc'})
  end,
})

-- For this to work you need to install this:
-- https://www.npmjs.com/package/intelephense
lsp_zero.new_client({
  cmd = {'intelephense', '--stdio'},
  filetypes = {'php'},
  root_dir = function(bufnr)
    -- You need Neovim v0.10 to use vim.fs.root
    return vim.fs.root(bufnr, {'composer.json'})
  end,
})
```

</details>

## Documentation

This branch is still under development. The available documentation is here:

* [help page](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v4.x/doc/lsp-zero.txt)
* [Tutorial](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v4.x/doc/md/tutorial.md)
* [LSP Configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v4.x/doc/md/lsp.md)
* [Autocomplete](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v4.x/doc/md/autocomplete.md)

## Getting started

### Requirements

Before doing anything, make sure you...

  * Have Neovim v0.10 installed
  * Know how to install Neovim plugins
  * Know where to add the configuration code for lua plugins
  * Know what is LSP, and what is a language server

### Installation

In this "getting started" section I will show you how to use these plugins:

  * [VonHeikemen/lsp-zero.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/tree/v4.x)
  * [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
  * [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
  * [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)

Install them using your favorite method.

<details>

<summary>Expand: lazy.nvim </summary>

For a more advance config that lazy loads everything take a look at the example on this link: [Lazy loading with lazy.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v4.x/doc/md/lazy-loading-with-lazy-nvim.md).

```lua
{'VonHeikemen/lsp-zero.nvim', branch = 'v4.x'},
{'neovim/nvim-lspconfig'},
{'hrsh7th/cmp-nvim-lsp'},
{'hrsh7th/nvim-cmp'},
```

</details>

<details>

<summary>Expand: paq.nvim </summary>

```lua
{'VonHeikemen/lsp-zero.nvim', branch = 'v4.x'},
{'neovim/nvim-lspconfig'},
{'hrsh7th/nvim-cmp'},
{'hrsh7th/cmp-nvim-lsp'},
```

</details>

<details>

<summary>Expand: vim-plug </summary>

```vim
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v4.x'}
```

When using vimscript you can wrap lua code in `lua <<EOF ... EOF`.

```lua
lua <<EOF
print('this an example code')
print('written in lua')
EOF
```

</details>

<details>

<summary>Expand: rocks.nvim </summary>

`v4.x` is not in luarocks yet so you'll need to install an extension so `rocks.nvim` can download plugins from github.

```
Rocks install rocks-git.nvim
```

Install version 4 of lsp-zero.

```
Rocks install VonHeikemen/lsp-zero.nvim rev=v4.x
```

Install nvim-cmp.

```
Rocks install hrsh7th/nvim-cmp rev=main
```

Install cmp-nvim-lsp.

```
Rocks install hrsh7th/cmp-nvim-lsp rev=main
```

</details>

### Extend nvim-lspconfig

lsp-zero can handle the configuration steps people don't want to do. That is, modifying `nvim-lspconfig` default settings and create keymaps.

```lua
vim.opt.signcolumn = 'yes'

local lsp_zero = require('lsp_zero')

local lsp_attach = function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end

lsp_zero.extend_lspconfig({
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})
```

### Use nvim-lspconfig

Once you have a language server installed you add the setup function in your Neovim config. Follow this syntax.

```lua
require('lspconfig').example_server.setup({})

-- You would add this setup function after calling lsp_zero.extend_lspconfig()
```

Where `example_server` is the name of the language server you have installed in your system. For example, this is the setup for function for the lua language server.

```lua
require('lspconfig').lua_ls.setup({})
```

You can find a list of language servers in [nvim-lspconfig's documentation](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

### Minimal autocompletion config

To setup autocompletion you use `nvim-cmp`.

```lua
local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({}),
})
```

### Complete code

<details>

<summary>Expand: code snippet </summary>

```lua
---
-- LSP configuration
---
vim.opt.signcolumn = 'yes'

local lsp_zero = require('lsp_zero')

local lsp_attach = function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end

lsp_zero.extend_lspconfig({
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- These are just examples. Replace them with the language
-- servers you have installed in your system
require('lspconfig').lua_ls.setup({})
require('lspconfig').rust_analyzer.setup({})
require('lspconfig').intelephense.setup({})

---
-- Autocompletion setup
---
local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({}),
})
```

</details>

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)

