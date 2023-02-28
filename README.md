# LSP Zero

The purpose of this plugin is to bundle all the "boilerplate code" necessary to have [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (a popular autocompletion plugin) and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) working together. And if you opt in, it can use [mason.nvim](https://github.com/williamboman/mason.nvim) to let you install language servers from inside neovim.

If you have any question about a feature or configuration feel free to open a new [discussion](https://github.com/VonHeikemen/lsp-zero.nvim/discussions) in this repository. Or join the chat [#lsp-zero-nvim:matrix.org](https://matrix.to/#/#lsp-zero-nvim:matrix.org).

## Announcement

This is the development branch for version 2 of lsp-zero.

## How to get started

If you are new to neovim go to the section [Resources for new users](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/getting-started.md#resources-for-new-users).

If you know how to configure neovim go to [Quickstart (for the impatient)](#quickstart-for-the-impatient).

Also consider [you might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/lsp.md#you-might-not-need-lsp-zero).

## Documentation

* LSP

TODO

* Autocompletion

TODO

* How to customize lsp-zero

TODO

## Quickstart (for the impatient)

This section will teach you how to create a basic configuration for autocompletion and the LSP client.

If you know your way around neovim and how to configure it, take a look at this examples:

* [Lua template configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/configuration-templates.md#lua-template)
* [Vimscript template configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/configuration-templates.md#vimscript-template)

## Requirements for language servers

I suggest you read the [requirements of mason.nvim](https://github.com/williamboman/mason.nvim#requirements).

Make sure you have at least the minimum requirements listed in `unix systems` or `windows`.

## Installing

Use your favorite plugin manager to install this plugin and all its lua dependencies.

With `packer.nvim`: 

```lua
use {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'dev-v2',
  requires = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},             -- Required
    {'williamboman/mason.nvim'},           -- Optional
    {'williamboman/mason-lspconfig.nvim'}, -- Optional

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},     -- Required
    {'hrsh7th/cmp-nvim-lsp'}, -- Required
    {'L3MON4D3/LuaSnip'},     -- Required
  }
}
```

With `lazy.nvim`:

```lua
{
  'VonHeikemen/lsp-zero.nvim',
  branch = 'dev-v2',
  dependencies = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},             -- Required
    {'williamboman/mason.nvim'},           -- Optional
    {'williamboman/mason-lspconfig.nvim'}, -- Optional

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},     -- Required
    {'hrsh7th/cmp-nvim-lsp'}, -- Required
    {'L3MON4D3/LuaSnip'},     -- Required
  }
}
```

With `paq`:

```lua
{'VonHeikemen/lsp-zero.nvim', branch = 'dev-v2'};

-- LSP Support
{'neovim/nvim-lspconfig'};             -- Required
{'williamboman/mason.nvim'};           -- Optional
{'williamboman/mason-lspconfig.nvim'}; -- Optional

-- Autocompletion
{'hrsh7th/nvim-cmp'};     -- Required
{'hrsh7th/cmp-nvim-lsp'}; -- Required
{'L3MON4D3/LuaSnip'};     -- Required
```

With `vim-plug`:

```vim
" LSP Support
Plug 'neovim/nvim-lspconfig'             " Required
Plug 'williamboman/mason.nvim'           " Optional
Plug 'williamboman/mason-lspconfig.nvim' " Optional

" Autocompletion
Plug 'hrsh7th/nvim-cmp'     " Required
Plug 'hrsh7th/cmp-nvim-lsp' " Required
Plug 'L3MON4D3/LuaSnip'     " Required

Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'dev-v2'}
```

When using vimscript you can wrap lua code in `lua <<EOF ... EOF`.

```vim
" Don't copy this example
lua <<EOF
print('this an example code')
print('written in lua')
EOF
```

## Usage

Inside your configuration file add this piece of lua code.

```lua
local lsp = require('lsp-zero').preset({name = 'minimal'})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- (Optional) Configure lua language server for neovim
lsp.configure('lua_ls', lsp.nvim_lua_ls())

lsp.setup()
```

If you want to install a language server for a particular file type use the command `:LspInstall`. And when the installation is done restart neovim.

If you don't install `mason.nvim` then you'll need to list the LSP servers you have installed using [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#configurename-opts).

> Note: if you use NixOS don't install mason.nvim

```lua
local lsp = require('lsp-zero').preset({name = 'minimal'})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- When you don't have mason.nvim installed
-- You'll need to list the servers installed in your system
lsp.setup_servers({'tsserver', 'eslint'})

-- (Optional) Configure lua language server for neovim
lsp.configure('lua_ls', lsp.nvim_lua_ls())

lsp.setup()
```

## Breaking changes

* `sign_icons` was removed. If you want the icons you can configure them using [.set_sign_icons()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#set_sign_iconsopts).
* `force_setup` option of [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#configurename-opts) was removed. lsp-zero will configure the server even if is not installed.
* `force` option of [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#configurename-opts) was removed. lsp-zero will configure all the servers listed even if they are not installed.
* The preset `per-project` was removed in favor of the function [.store_config()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#store_configname-opts).
* `suggest_lsp_servers` was removed. The suggestions are still available (they are a feature of [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim)), they can be triggered manually using the command `:LspInstall`.
* `cmp_capabilities` was removed. The features it enables will be configured automatically if [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) is installed.

## Changes/Deprecation notice

Settings and functions that will change in the future. If you are using the `main` branch and want to avoid breaking changes use the `v1.x` branch.

### Preset settings

* `set_lsp_keymaps` will be removed in favor of [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#default_keymapsopts)

### Functions

* [.set_preferences()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#set_preferencesopts) will be removed in favor of overriding option directly in [.preset](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#presetname)
* [.setup_nvim_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#setup_nvim_cmpopts) will be removed. Use the `cmp` module to customize nvim-cmp.
* [,setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#setup_serverslist) will no longer take an options argument. It'll only be a convenient way to initialize a list of servers.
* [.default.diagnostics()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#defaultsdiagnosticsopts) will be removed. Diagnostic config has been reduced, only `severity_sort` and borders are enabled. There is no need for this anymore.
* [.defaults.cmp_sources()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#defaultscmp_sources) will be removed. Sources for nvim-cmp will be handled by the user.
* [.defaults.cmp_mappings()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#defaultscmp_mappingsopts) will be removed. In the future only the defaults that align with Neovim's behavior will be configured. lsp-zero default functions for nvim-cmp will have to be added manually by the user.
* [,nvim_workspace()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#nvim_workspaceopts) will be removed. Use [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#nvim_lua_lsopts) to get the config and then use [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#configurename-opts) to setup the server.
* [,defaults.nvim_workspace()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#defaultsnvim_workspace) will be replaced by [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#nvim_lua_lsopts).

## FAQ

### How do I get rid warnings in my neovim lua config?

lsp-zero has a function that will configure the lua language server for you: [nvim_workspace](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#nvim_workspaceopts)

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)

