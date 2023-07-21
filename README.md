# LSP Zero

The purpose of this plugin is to bundle all the "boilerplate code" necessary to have [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (a popular autocompletion plugin) and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) working together. And if you opt in, it can use [mason.nvim](https://github.com/williamboman/mason.nvim) to let you install language servers from inside neovim.

If you have any question about a feature or configuration feel free to open a new [discussion](https://github.com/VonHeikemen/lsp-zero.nvim/discussions) in this repository. Or join the chat [#lsp-zero-nvim:matrix.org](https://matrix.to/#/#lsp-zero-nvim:matrix.org).

## Announcement

The [development branch for v3.x](https://github.com/VonHeikemen/lsp-zero.nvim/tree/dev-v3) has been created (and is basically done). I'm thinking on making `v3.x` the default branch on `September 20`. If you want to talk about the new changes [join the discussion about v3.x](https://github.com/VonHeikemen/lsp-zero.nvim/discussions/286).

## How to get started

First, make sure you have Neovim v0.8 or greater. If you are using Neovim v0.7.2 or lower you will need to download [lsp-zero v1.x](https://github.com/VonHeikemen/lsp-zero.nvim/tree/v1.x).

If you are new to neovim and you don't have a configuration file (`init.lua`) follow this [step by step tutorial](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/tutorial.md). 

If you know how to configure neovim go to [Quickstart (for the impatient)](#quickstart-for-the-impatient).

Also consider [you might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#you-might-not-need-lsp-zero).

## Documentation

* LSP

  * [Introduction](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#introduction)
  * [Commands](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#commands)
  * [Creating new keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#creating-new-keybindings)
  * [Disable keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#disable-keybindings)
  * [Install new language servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#install-new-language-servers)
  * [Configure language servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#configure-language-servers)
  * [Disable semantic highlights](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#disable-semantic-highlights) 
  * [Disable a language server](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#disable-a-language-server)
  * [Custom servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#custom-servers)
  * [Enable Format on save](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#enable-format-on-save)
  * [Format buffer using a keybinding](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#format-buffer-using-a-keybinding) 
  * [Troubleshooting](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#troubleshooting)
  * [Diagnostics (a.k.a. error messages, warnings, etc.)](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#diagnostics)
  * [Use icons in the sign column](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#use-icons-in-the-sign-column)
  * [Language servers and mason.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#language-servers-and-masonnvim)

* Autocompletion

  * [Introduction](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#introduction)
  * [Preset settings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#preset-settings)
  * [Recommended sources](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#recommended-sources)
  * [Keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#keybindings)
  * [Use Enter to confirm completion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#use-enter-to-confirm-completion)
  * [Adding a source](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#adding-a-source)
  * [Add an external collection of snippets](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#add-an-external-collection-of-snippets)
  * [Preselect first item](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#preselect-first-item)
  * [Basic completions for Neovim's lua api](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#basic-completions-for-neovims-lua-api)
  * [Enable "Super Tab"](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#enable-super-tab)
  * [Regular tab complete](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#regular-tab-complete)
  * [Invoke completion menu manually](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#invoke-completion-menu-manually)
  * [Adding borders to completion menu](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#adding-borders-to-completion-menu)
  * [Change formatting of completion item](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#change-formatting-of-completion-item)
  * [lsp-kind](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#lsp-kind)

* Reference and guides
  
  * [API Reference](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md)
  * [Tutorial: Step by step setup from scratch](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/tutorial.md)
  * [lsp-zero under the hood](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/under-the-hood.md)
  * [You might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/lsp.md#you-might-not-need-lsp-zero)
  * [Lazy loading with lazy.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/lazy-loading-with-lazy-nvim.md)
  * [Integrate with null-ls](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/integrate-with-null-ls.md)
  * [Enable folds with nvim-ufo](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#enable-folds-with-nvim-ufo)
  * [Enable inlay hints with inlay-hints.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#enable-inlay-hints-with-inlay-hintsnvim)
  * [Setup copilot.lua + nvim-cmp](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/setup-copilot-lua-plus-nvim-cmp.md#setup-copilotlua--nvim-cmp)
  * [Setup with nvim-navic](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#setup-with-nvim-navic)
  * [Setup with rust-tools](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#setup-with-rust-tools)
  * [Setup with typescript.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#setup-with-typescriptnvim)
  * [Setup with flutter-tools](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#setup-with-flutter-tools)
  * [Setup with nvim-jdtls](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/setup-with-nvim-jdtls.md) 
  * [Setup with nvim-metals](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#setup-with-nvim-metals)
  * [Setup with haskell-tools](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#setup-with-haskell-tools)
  * [Setup with clangd_extensions.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/guides/quick-recipes.md#setup-with-clangd_extensionsnvim) 

## Quickstart (for the impatient)

This section will teach you how to create a basic configuration for autocompletion and the LSP client.

If you know your way around neovim and how to configure it, take a look at this examples:

* [Lua template configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/configuration-templates.md#lua-template)
* [Vimscript template configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/configuration-templates.md#vimscript-template)

### Requirements for language servers

I suggest you read the [requirements of mason.nvim](https://github.com/williamboman/mason.nvim#requirements).

Make sure you have at least the minimum requirements listed in `unix systems` or `windows`.

### Installing

Use your favorite plugin manager to install this plugin and all its lua dependencies.

<details>
<summary>Expand lazy.nvim snippet: </summary>

```lua
{
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v2.x',
  dependencies = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},             -- Required
    {                                      -- Optional
      'williamboman/mason.nvim',
      build = function()
        pcall(vim.api.nvim_command, 'MasonUpdate')
      end,
    },
    {'williamboman/mason-lspconfig.nvim'}, -- Optional

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},     -- Required
    {'hrsh7th/cmp-nvim-lsp'}, -- Required
    {'L3MON4D3/LuaSnip'},     -- Required
  }
}
```

</details>

<details>
<summary>Expand packer.nvim snippet: </summary>

```lua
use {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v2.x',
  requires = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},             -- Required
    {                                      -- Optional
      'williamboman/mason.nvim',
      run = function()
        pcall(vim.api.nvim_command, 'MasonUpdate')
      end,
    },
    {'williamboman/mason-lspconfig.nvim'}, -- Optional

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},     -- Required
    {'hrsh7th/cmp-nvim-lsp'}, -- Required
    {'L3MON4D3/LuaSnip'},     -- Required
  }
}
```
</details>

<details>
<summary>Expand paq.nvim snippet: </summary>

```lua
{'VonHeikemen/lsp-zero.nvim', branch = 'v2.x'};

-- LSP Support
{'neovim/nvim-lspconfig'};             -- Required
{                                      -- Optional
  'williamboman/mason.nvim',
  run = function()
    pcall(vim.api.nvim_command, 'MasonUpdate')
  end,
};
{'williamboman/mason-lspconfig.nvim'}; -- Optional

-- Autocompletion
{'hrsh7th/nvim-cmp'};     -- Required
{'hrsh7th/cmp-nvim-lsp'}; -- Required
{'L3MON4D3/LuaSnip'};     -- Required
```

</details>

<details>
<summary>Expand vim-plug snippet: </summary>

```vim
" LSP Support
Plug 'neovim/nvim-lspconfig'                           " Required
Plug 'williamboman/mason.nvim', {'do': ':MasonUpdate'} " Optional
Plug 'williamboman/mason-lspconfig.nvim'               " Optional

" Autocompletion
Plug 'hrsh7th/nvim-cmp'     " Required
Plug 'hrsh7th/cmp-nvim-lsp' " Required
Plug 'L3MON4D3/LuaSnip'     " Required

Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v2.x'}
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

Inside your configuration file add this piece of lua code.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()
```

If you want to install a language server for a particular file type use the command `:LspInstall`. And when the installation is done restart neovim.

If you don't install `mason.nvim` then you'll need to list the LSP servers you have installed using [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#configurename-opts).

> Note: if you use NixOS don't install mason.nvim

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

-- When you don't have mason.nvim installed
-- You'll need to list the servers installed in your system
lsp.setup_servers({'tsserver', 'eslint'})

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()
```

## Language servers

Here are some things you need to know:

* The configuration for the language servers are provided by [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig). 
* lsp-zero will create keybindings, commands, and will integrate nvim-cmp (the autocompletion plugin) with lspconfig if possible. You need to require lsp-zero before lspconfig for this to work.
* Even though lsp-zero calls [mason.nvim](https://github.com/williamboman/mason.nvim) under the hood it only configures LSP servers. Other tools like formatters, linters or debuggers are not configured by lsp-zero.
* If you need to configure a language server use `lspconfig`.

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

You can force lsp-zero's bindings by adding `preserve_mappings = false` to [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#default_keymapsopts).

```lua
lsp.default_keymaps({
  buffer = bufnr,
  preserve_mappings = false
})
```

### Troubleshooting

If you are having problems with a language server I recommend that you reduce your config to a minimal and check the logs of the LSP server (use the command `:LspLog`).

What do I mean with minimal? Configure the language server using just `lspconfig` and increase the log level. Here is an example test with `tsserver`.

```lua
vim.lsp.set_log_level('debug')

local lsp_zero = require('lsp-zero')
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

local cmp = require('cmp')

cmp.setup({
  sources = {{name = 'nvim_lsp'}},
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})

require('lspconfig').tsserver.setup({
  capabilities = lsp_capabilities,
  on_attach = function(client, bufnr)
    lsp_zero.default_keymaps({buffer = bufnr})
  end,
})
```

Then you can test the language server and inspect the log file using the command `:LspLog`.

## Autocomplete

The plugin responsible for autocompletion is [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). The default preset (which is called [minimal](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#minimal)) will only add the minimum required to integrate lspconfig, nvim-cmp and [luasnip](https://github.com/L3MON4D3/LuaSnip).

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
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()

-- You need to setup `cmp` after lsp-zero
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

## Breaking changes

* `sign_icons` was removed. If you want the icons you can configure them using [.set_sign_icons()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#set_sign_iconsopts).
* `force_setup` option of [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#configurename-opts) was removed. lsp-zero will configure the server even if is not installed.
* `force` option of [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#configurename-opts) was removed. lsp-zero will configure all the servers listed even if they are not installed.
* The preset `per-project` was removed in favor of the function [.store_config()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#store_configname-opts).
* `suggest_lsp_servers` was removed. The suggestions are still available (they are a feature of [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim)), they can be triggered manually using the command `:LspInstall`.
* `cmp_capabilities` was removed. The features it enables will be configured automatically if [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) is installed.
* luasnip loaders need to be called manually by the user. See [luasnip documention for details](https://github.com/L3MON4D3/LuaSnip#add-snippets). If you are using `friendly-snippets` you'll want to add the one that says "from_vscode". In the autocomplete documentation you can find an [example configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#add-an-external-collection-of-snippets).

## Future Changes/Deprecation notice

Settings and functions that will change in case I feel forced to created a `v3.x` branch.

### Preset settings

I would like to get rid of named preset in the future. It's better if you use the default preset, the [minimal](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#minimal). I would advice against using the one called "recommended". Just add your settings using the [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#presetopts) function.

* `set_lsp_keymaps` will be removed in favor of [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#default_keymapsopts).
* `manage_nvim_cmp` will be removed in favor of [.extend_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#extend_cmpopts).
* `setup_servers_on_start` will be removed. LSP servers will need to be listed explicitly using [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#configurename-opts).
* `call_servers` will be removed in favor of a explicit setup.
* `configure_diagnostics` will be removed.

### Functions

* [.set_preferences()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#set_preferencesopts) will be removed in favor of overriding option directly in [.preset](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#presetname).
* [.setup_nvim_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup_nvim_cmpopts) will be removed. Use the `cmp` module to customize nvim-cmp.
* [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup_serverslist) will no longer take an options argument. It'll only be a convenient way to initialize a list of servers.
* [.default.diagnostics()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#defaultsdiagnosticsopts) will be removed. Diagnostic config has been reduced, only `severity_sort` and borders are enabled. There is no need for this anymore.
* [.defaults.cmp_sources()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#defaultscmp_sources) will be removed. Sources for nvim-cmp will be handled by the user.
* [.defaults.cmp_mappings()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#defaultscmp_mappingsopts) will be removed. In the future only the defaults that align with Neovim's behavior will be configured. lsp-zero default functions for nvim-cmp will have to be added manually by the user.
* [.nvim_workspace()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#nvim_workspaceopts) will be removed. Use [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#nvim_lua_lsopts) to get the config and then use [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#configurename-opts) to setup the server.
* [.defaults.nvim_workspace()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#defaultsnvim_workspace) will be replaced by [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#nvim_lua_lsopts).
* [.ensure_installed()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#ensure_installedlist) will be removed. Use the module `mason-lspconfig` to install LSP servers. 
* [.setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup) will be removed.

## FAQ

### How do I get rid warnings in my neovim lua config?

lsp-zero has a function that will configure the lua language server for you: [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#nvim_lua_lsopts)

### Can I use the Enter key to confirm completion item?

Yes, you can. You can find the details in the autocomplete documentation: [Enter key to confirm completion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#use-enter-to-confirm-completion).

### My luasnip snippet don't show up in completion menu. How do I get them back?

If you have this problem I assume you are migrating from the `v1.x` branch. What you have to do is add the luasnip source in nvim-cmp, then call the correct luasnip loader. You can find more details of this in the [documentation for autocompletion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/autocomplete.md#add-an-external-collection-of-snippets).

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)

