# LSP Zero

The purpose of this plugin is to bundle all the "boilerplate code" necessary to have [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (a popular autocompletion plugin) and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) working together.

If you have any question about a feature or configuration feel free to open a new [discussion](https://github.com/VonHeikemen/lsp-zero.nvim/discussions) in this repository. Or join the chat [#lsp-zero-nvim:matrix.org](https://matrix.to/#/#lsp-zero-nvim:matrix.org).

## Announcement

Hello, there. This is the development branch for version 3 of lsp-zero. 

This version requires Neovim v0.8 or greater. If have Neovim v0.7.2 or lower please use the [v1.x branch](https://github.com/VonHeikemen/lsp-zero.nvim/tree/v1.x).

## How to get started

If you are new to neovim and you don't have a configuration file (`init.lua`) follow this [step by step tutorial](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/tutorial.md). 

If you know how to configure neovim go to [Quickstart (for the impatient)](#quickstart-for-the-impatient).

Also consider [you might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#you-might-not-need-lsp-zero).

## Documentation

* LSP

  * [Introduction](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#introduction)
  * [Commands](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#commands)
  * [Creating new keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#creating-new-keybindings)
  * [Disable keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#disable-keybindings)
  * [Install new language servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#install-new-language-servers)
  * [Configure language servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#configure-language-servers)
  * [Disable semantic highlights](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#disable-semantic-highlights) 
  * [Disable a language server](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#disable-a-language-server)
  * [Custom servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#custom-servers)
  * [Enable Format on save](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#enable-format-on-save)
  * [Format buffer using a keybinding](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#format-buffer-using-a-keybinding) 
  * [Troubleshooting](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#troubleshooting)
  * [Diagnostics (a.k.a. error messages, warnings, etc.)](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#diagnostics)
  * [Use icons in the sign column](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#use-icons-in-the-sign-column)
  * [Language servers and mason.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#language-servers-and-masonnvim)

* Autocompletion

  * [Introduction](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#introduction)
  * [Preset settings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#preset-settings)
  * [Recommended sources](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#recommended-sources)
  * [Keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#keybindings)
  * [Use Enter to confirm completion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#use-enter-to-confirm-completion)
  * [Adding a source](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#adding-a-source)
  * [Add an external collection of snippets](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#add-an-external-collection-of-snippets)
  * [Preselect first item](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#preselect-first-item)
  * [Basic completions for Neovim's lua api](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#basic-completions-for-neovims-lua-api)
  * [Enable "Super Tab"](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#enable-super-tab)
  * [Regular tab complete](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#regular-tab-complete)
  * [Invoke completion menu manually](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#invoke-completion-menu-manually)
  * [Adding borders to completion menu](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#adding-borders-to-completion-menu)
  * [Change formatting of completion item](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#change-formatting-of-completion-item)
  * [lsp-kind](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#lsp-kind)

* Reference and guides
  
  * [API Reference](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md)
  * [Tutorial: Step by step setup from scratch](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/tutorial.md)
  * [lsp-zero under the hood](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/under-the-hood.md)
  * [You might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#you-might-not-need-lsp-zero)
  * [Lazy loading with lazy.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/lazy-loading-with-lazy-nvim.md)
  * [Integrate with mason.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/integrate-with-mason-nvim.md)
  * [Integrate with null-ls](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/integrate-with-null-ls.md)
  * [Enable folds with nvim-ufo](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#enable-folds-with-nvim-ufo)
  * [Enable inlay hints with inlay-hints.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#enable-inlay-hints-with-inlay-hintsnvim)
  * [Setup copilot.lua + nvim-cmp](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/setup-copilot-lua-plus-nvim-cmp.md#setup-copilotlua--nvim-cmp)
  * [Setup with nvim-navic](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-nvim-navic)
  * [Setup with rust-tools](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-rust-tools)
  * [Setup with typescript.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-typescriptnvim)
  * [Setup with flutter-tools](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-flutter-tools)
  * [Setup with nvim-jdtls](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/setup-with-nvim-jdtls.md) 
  * [Setup with nvim-metals](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-nvim-metals)
  * [Setup with haskell-tools](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-haskell-tools)
  * [Setup with clangd_extensions.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-clangd_extensionsnvim) 

## Quickstart (for the impatient)

This section will teach you how to create a basic configuration.

### Installing

Use your favorite plugin manager to install this plugin and all its lua dependencies.

<details>
<summary>Expand lazy.nvim snippet: </summary>

```lua
{
  'VonHeikemen/lsp-zero.nvim',
  branch = 'dev-v3',
  dependencies = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},
    -- Autocompletion
    {'hrsh7th/nvim-cmp'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'L3MON4D3/LuaSnip'},
  }
}
```

</details>

<details>
<summary>Expand packer.nvim snippet: </summary>

```lua
use {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'dev-v3',
  requires = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},
    -- Autocompletion
    {'hrsh7th/nvim-cmp'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'L3MON4D3/LuaSnip'},
  }
}
```
</details>

<details>
<summary>Expand paq.nvim snippet: </summary>

```lua
{'VonHeikemen/lsp-zero.nvim', branch = 'dev-v3'};

-- LSP Support
{'neovim/nvim-lspconfig'};
-- Autocompletion
{'hrsh7th/nvim-cmp'};
{'hrsh7th/cmp-nvim-lsp'};
{'L3MON4D3/LuaSnip'};
```

</details>

<details>
<summary>Expand vim-plug snippet: </summary>

```vim
" LSP Support
Plug 'neovim/nvim-lspconfig'
" Autocompletion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'

Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'dev-v3'}
```

When using vimscript you can wrap lua code in `lua <<EOF ... EOF`.

```vim
" Don't copy this example
lua <<EOF
print('this an example code')
print('written in lua')
EOF
```

</details>

### Usage

I will show the configuration code in sections.

#### Manual setup of LSP servers

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones installed in your system
lsp.setup_servers({'tsserver', 'rust_analyzer'})
```

If you need to customize a language server use the module `lspconfig`. Call the `setup` function of the LSP server like this.

```lua
require('lspconfig').lua_ls.setup({})
```

Here `lua_ls` is the language server we want to configure. And inside the `{}` is where you place the config.

#### Automatic setup of LSP servers

You can use [mason.nvim](https://github.com/williamboman/mason.nvim) to manage the installation of the LSP servers, and lsp-zero to handle the configuration of the servers.

For more details about how to use mason.nvim see the guide how to [integrate with mason.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/integrate-with-mason-nvim.md).

Here a usage example.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  -- Replace the language servers listed here 
  -- with the ones you want to install
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {lsp.default_setup},
})
```

#### Autocompletion

For your autocomplete needs you can get a working basic config using lsp-zero, and then add your custom config using the `cmp` module directly.

```lua
require('lsp-zero').extend_cmp()

---
-- calling `cmp.setup` is optional I'm just showing
-- how you can customize nvim-cmp
---
local cmp = require('cmp')

cmp.setup({
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<Enter>'] = cmp.mapping.confirm({select = false}),
  }
})
```

## Language servers

Here are some things you need to know:

* The configuration for the language servers are provided by [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig). 
* lsp-zero will create keybindings, commands, and will integrate nvim-cmp (the autocompletion plugin) with lspconfig if possible. You need to call lsp-zero's preset function before using lspconfig.

### Keybindings

When a language server gets attached to a buffer you gain access to some keybindings and commands. All of these shortcuts are bound to built-in functions, so you can get more details using the `:help` command.

* `K`: Displays hover information about the symbol under the cursor in a floating window. See [:help vim.lsp.buf.hover()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.hover()).

* `gd`: Jumps to the definition of the symbol under the cursor. See [:help vim.lsp.buf.definition()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.definition()).

* `gD`: Jumps to the declaration of the symbol under the cursor. Some servers don't implement this feature. See [:help vim.lsp.buf.declaration()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.declaration()).

* `gi`: Lists all the implementations for the symbol under the cursor in the quickfix window. See [:help vim.lsp.buf.implementation()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.implementation()).

* `go`: Jumps to the definition of the type of the symbol under the cursor. See [:help vim.lsp.buf.type_definition()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.type_definition()).

* `gr`: Lists all the references to the symbol under the cursor in the quickfix window. See [:help vim.lsp.buf.references()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.references()).

* `gs`: Displays signature information about the symbol under the cursor in a floating window. See [:help vim.lsp.buf.signature_help()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.signature_help()). If a mapping already exists for this key this function is not bound.

* `<F2>`: Renames all references to the symbol under the cursor. See [:help vim.lsp.buf.rename()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.rename()).

* `<F3>`: Format code in current buffer. See [:help vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()).

* `<F4>`: Selects a code action available at the current cursor position. See [:help vim.lsp.buf.code_action()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.code_action()).

* `gl`: Show diagnostics in a floating window. See [:help vim.diagnostic.open_float()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.open_float()).

* `[d`: Move to the previous diagnostic in the current buffer. See [:help vim.diagnostic.goto_prev()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.goto_prev()).

* `]d`: Move to the next diagnostic. See [:help vim.diagnostic.goto_next()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.goto_next()).

By default lsp-zero will not create a keybinding if its "taken". This means if you already use one of these in your config, or some other plugins uses it ([which-key](https://github.com/folke/which-key.nvim) might be one), then lsp-zero's bindings will not work.

You can force lsp-zero's bindings by adding `preserve_mappings = false` to [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#default_keymapsopts).

```lua
lsp.default_keymaps({
  buffer = bufnr,
  preserve_mappings = false
})
```

## Autocomplete

The plugin responsable for autocompletion is [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). The default config in lsp-zero will only add the minimum required to integrate lspconfig, nvim-cmp and [luasnip](https://github.com/L3MON4D3/LuaSnip).

### Keybindings

The default keybindings in lsp-zero are meant to emulate Neovim's default whenever possible.

* `<Ctrl-y>`: Confirms selection.

* `<Ctrl-e>`: Cancel completion.

* `<Down>`: Navigate to the next item on the list.

* `<Up>`: Navigate to previous item on the list.

* `<Ctrl-n>`: If the completion menu is visible, go to the next item. Else, trigger completion menu.

* `<Ctrl-p>`: If the completion menu is visible, go to the previous item. Else, trigger completion menu.

* `<Ctrl-d>`: Scroll down the documentation window.

* `<Ctrl-u>`: Scroll up the documentation window.

To add more keybindings I recommend you use [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) directly.

Here is an example configuration.

```lua
require('lsp-zero').extend_cmp()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = {
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate between snippet placeholder
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
  }
})
```

### Adding extra sources

In nvim-cmp a "source" is a neovim plugin that provides the actual data displayed in the completion menu.

Here is a list of sources you might want to configure (and install) to get a better experience.

* [cmp-buffer](https://github.com/hrsh7th/cmp-buffer): provides suggestions based on the current file.

* [cmp-path](https://github.com/hrsh7th/cmp-path): gives completions based on the filesystem.

* [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip): it shows snippets loaded by luasnip in the suggestions. This is useful when you install an external collection of snippets like [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) (See [autocomplete docs for more details](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#add-an-external-collection-of-snippets)).

* [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp): show data sent by the language server.

Quick note: when you configure the `source` option in nvim-cmp the previous config will be overriden. This means that is if you use it you need to add the source for LSP again.

```lua
-- For this code to work you need to install these plugins:
-- hrsh7th/cmp-path
-- hrsh7th/cmp-nvim-lsp
-- hrsh7th/cmp-buffer
-- saadparwaiz1/cmp_luasnip
-- rafamadriz/friendly-snippets

require('lsp-zero').extend_cmp()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  },
  mapping = {
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
  }
})
```

## Breaking changes

TODO

## FAQ

### How do I get rid warnings in my neovim lua config?

lsp-zero has a function that will configure the lua language server for you: [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#nvim_lua_lsopts)

### Can I use the Enter key to confirm completion item?

Yes, you can. You can find the details in the autocomplete documentation: [Enter key to confirm completion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#use-enter-to-confirm-completion).

### My luasnip snippet don't show up in completion menu. How do I get them back?

If you have this problem I assume you are migrating from the `v1.x` branch. What you have to do is add the luasnip source in nvim-cmp, then call the correct luasnip loader. You can find more details of this in the [documentation for autocompletion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#add-an-external-collection-of-snippets).

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)

