# LSP Zero

Collection of functions that will help you use Neovim's LSP client. The aim is to provide abstractions on top of Neovim's LSP client that are easy to use.

<details>

<summary>Expand: Showcase </summary>

```lua
-- WARNING: This is not a snippet you want to copy/paste blindly

-- This snippet is just a fun example I can show to people.
-- A showcase of all the functions they don't know about.

vim.opt.updatetime = 800

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
  lsp_zero.highlight_symbol(client, bufnr)
  lsp_zero.buffer_autoformat()
end)

lsp_zero.ui({
  float_border = 'rounded',
  sign_text = {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = '»',
  },
})

lsp_zero.omnifunc.setup({
  trigger = '<C-Space>',
  tabcomplete = true,
  use_fallback = true,
  update_on_delete = true,
  -- You need Neovim v0.10 to use vim.snippet.expand
  expand_snippet = vim.snippet.expand
})

-- For this to work you need to install this:
-- https://www.npmjs.com/package/intelephense
lsp_zero.new_client({
  cmd = {'intelephense', '--stdio'},
  filetypes = {'php'},
  root_dir = function(bufnr)
    -- You need Neovim v0.10 to use vim.fs.root
    -- If vim.fs.root is not available, use this:
    -- lsp_zero.dir.find_first({buffer = true, 'composer.json'})

    return vim.fs.root(bufnr, {'composer.json'})
  end,
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
```

</details>

## Documentation

This branch is still under development. The available documentation is here:

* [Tutorial for beginners](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v4.x/doc/md/tutorial.md)
* [LSP Configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v4.x/doc/md/lsp.md)
* [Autocomplete](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v4.x/doc/md/autocomplete.md)
* [Help Page](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v4.x/doc/lsp-zero.txt)

## Getting started

### Requirements

Before doing anything, make sure you...

  * Have Neovim v0.10 installed
    * Neovim v0.9 also works
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

```lua
{'VonHeikemen/lsp-zero.nvim', branch = 'v4.x'},
{'neovim/nvim-lspconfig'},
{'hrsh7th/cmp-nvim-lsp'},
{'hrsh7th/nvim-cmp'},
```

For a more advance config that lazy loads everything take a look at the example on this link: [Lazy loading with lazy.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v4.x/doc/md/guides/lazy-loading-with-lazy-nvim.md).

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

<summary>Expand: mini.deps </summary>

```lua
MiniDeps.add({source = 'VonHeikemen/lsp-zero.nvim', checkout = 'v4.x'})
MiniDeps.add({source = 'neovim/nvim-lspconfig'})
MiniDeps.add({
  source = 'hrsh7th/nvim-cmp',
  depends = {
    'hrsh7th/cmp-nvim-lsp',
  },
})
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

<details>

<summary>Expand: Git clone </summary>

To install a plugin without a plugin manager you just have to download them in the right location.

* Create folder where plugins should be downloaded

  The exact path depends on your operating system and environment variables. To get a valid location you can execute this command in your terminal.

  ```sh
  nvim --headless -c "echo stdpath('config') . '/pack/github/start/'" -c "echo ''" -c "quit"
  ```

  Create that folder and navigate to it. Use whatever method you know best.

  Use the command `git clone` inside that folder.

* Install lsp-zero

  ```sh
  git clone --branch=v4.x https://github.com/VonHeikemen/lsp-zero.nvim.git
  ```

* Install nvim-lspconfig

  ```sh
  git clone https://github.com/neovim/nvim-lspconfig.git
  ```

* Install nvim-cmp

  ```sh
  git clone https://github.com/hrsh7th/nvim-cmp.git
  ```

* Install cmp-nvim-lsp

  ```sh
  git clone https://github.com/hrsh7th/cmp-nvim-lsp.git
  ```

</details>

### Extend nvim-lspconfig

lsp-zero can handle configurations steps for you: Set additional `capabilities` in nvim-lspconfig, creating an autocommand on the `LspAttach` event and reserve space in the gutter for diagnostic signs.

```lua
local lsp_zero = require('lsp-zero')

-- lsp_attach is where you enable features that only work
-- if there is a language server active in the file
local lsp_attach = function(client, bufnr)
  local opts = {buffer = bufnr}

  vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
  vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
  vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
  vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
  vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})
```

### Use nvim-lspconfig

Remember that you need to install a language server so nvim-lspconfig can work properly. You can find a list of language servers in [nvim-lspconfig's documentation](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

Once you have a language server installed you add the setup function in your Neovim config. Follow this syntax.

```lua
require('lspconfig').example_server.setup({})

-- You would add this setup function after calling lsp_zero.extend_lspconfig()
```

Where `example_server` is the name of the language server you have installed in your system. For example, this is the setup for function for the lua language server.

```lua
require('lspconfig').lua_ls.setup({})
```

<details>

<summary>Expand: Neovim and lua_ls </summary>

The language server for lua does not have "support" Neovim's lua API out the box. You won't get code completion for Neovim's built-in functions and you may see some annoying warnings.

To get some basic support for Neovim, create a file called `.luarc.json` in your Neovim config folder (next to your `init.lua` file). Then add this content.

```json
{
  "runtime.version": "LuaJIT",
  "runtime.path": [
    "lua/?.lua",
    "lua/?/init.lua"
  ],
  "diagnostics.globals": ["vim"],
  "workspace.checkThirdParty": false,
  "workspace.library": [
    "$VIMRUNTIME",
    "${3rd}/luv/library"
  ]
}
```

</details>

### Minimal autocompletion config

`nvim-cmp` is the plugin that you would use to get code autocompletion. By default nvim-cmp only handles the interface of the completion menu. It does not gather data from language servers or any other source.

`cmp_nvim_lsp` is an extension for nvim-cmp. This is the plugin that collects data from the language servers and gives it to `nvim-cmp`.

If you have Neovim v0.10 you can use this configuration.

```lua
local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  snippet = {
    expand = function(args)
      -- You need Neovim v0.10 to use vim.snippet
      vim.snippet.expand(args.body)
    end,
  },
  -- List of default keymaps is here:
  -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v4.x/doc/md/autocomplete.md#keybindings
  mapping = cmp.mapping.preset.insert({}),
})
```

If you have Neovim v0.9 you will need to install a snippet engine. I recommend [luasnip](https://github.com/L3MON4D3/LuaSnip). Once you have it installed you can use it in the `snippet.expand` option.

```lua
snippet = {
  expand = function(args)
    require('luasnip').lsp_expand(args.body)
  end,
},
```

### Complete code

<details>

<summary>Expand: code snippet </summary>

```lua
---
-- LSP configuration
---
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  local opts = {buffer = bufnr}

  vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
  vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
  vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
  vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
  vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- These are just examples. Replace them with the language
-- servers you have installed in your system
require('lspconfig').gleam.setup({})
require('lspconfig').rust_analyzer.setup({})

---
-- Autocompletion setup
---
local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  snippet = {
    expand = function(args)
      -- You need Neovim v0.10 to use vim.snippet
      vim.snippet.expand(args.body)
    end,
  },
  -- List of default keymaps is here:
  -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v4.x/doc/md/autocomplete.md#keybindings
  mapping = cmp.mapping.preset.insert({}),
})
```

</details>

### Plot twist

<details>

<summary>Expand: You might not need lsp-zero </summary>

If the code I showed in this getting started section is all you ever need to be happy, then you don't need lsp-zero.

You can do the same thing without lsp-zero:

```lua
---
-- LSP configuration
---
vim.opt.signcolumn = 'yes'

local lspconfig = require('lspconfig')

-- Add cmp_nvim_lsp capabilities settings to lspconfig
lspconfig.util.default_config.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig.util.default_config.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

-- Executes the callback function every time a
-- language server is attached to a buffer.
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end,
})

-- These are just examples. Replace them with the language
-- servers you have installed in your system
require('lspconfig').gleam.setup({})
require('lspconfig').rust_analyzer.setup({})

---
-- Autocompletion setup
---
local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  snippet = {
    expand = function(args)
      -- You need Neovim v0.10 to use vim.snippet
      vim.snippet.expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({}),
})
```

</details>

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)

