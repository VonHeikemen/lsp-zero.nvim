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
  * [Introduction to nvim-lspconfig](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/lsp.md#introduction)
  * [Default keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/lsp.md#default-keybindings)
  * [Commands](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/lsp.md#commands)
  * [Configure language servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/lsp.md#configure-language-servers) 
  * [Disable a language server](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/lsp.md#disable-a-language-server) 
  * [Diagnostics](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/lsp.md#diagnostics) (A.K.A. error messages and warnings)
  * [Language servers and mason.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/lsp.md#language-servers-and-masonnvim)
  * [You might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/lsp.md#you-might-not-need-lsp-zero).

* Autocompletion
  * [About nvim-cmp](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/autocomplete.md#about-nvim-cmp)
  * [Default keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/autocomplete.md#default-keybindings)
  * [Override keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/autocomplete.md#override-keybindings)
  * [Snippets](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/autocomplete.md#snippets)

* How to customize lsp-zero
  * [Advance Usage](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/advance-usage.md)
  * [API Reference](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md) (Available functions)

## Quickstart (for the impatient)

This section assumes you want enable every single feature lsp-zero offers. Optional and required plugins will be marked with a comment.

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
    {'hrsh7th/nvim-cmp'},         -- Required
    {'hrsh7th/cmp-nvim-lsp'},     -- Required
    {'hrsh7th/cmp-buffer'},       -- Optional
    {'hrsh7th/cmp-path'},         -- Optional
    {'saadparwaiz1/cmp_luasnip'}, -- Optional
    {'hrsh7th/cmp-nvim-lua'},     -- Optional

    -- Snippets
    {'L3MON4D3/LuaSnip'},             -- Required
    {'rafamadriz/friendly-snippets'}, -- Optional
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
    {'hrsh7th/nvim-cmp'},         -- Required
    {'hrsh7th/cmp-nvim-lsp'},     -- Required
    {'hrsh7th/cmp-buffer'},       -- Optional
    {'hrsh7th/cmp-path'},         -- Optional
    {'saadparwaiz1/cmp_luasnip'}, -- Optional
    {'hrsh7th/cmp-nvim-lua'},     -- Optional

    -- Snippets
    {'L3MON4D3/LuaSnip'},             -- Required
    {'rafamadriz/friendly-snippets'}, -- Optional
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

-- Autocompletion Engine
{'hrsh7th/nvim-cmp'};         -- Required
{'hrsh7th/cmp-nvim-lsp'};     -- Required
{'hrsh7th/cmp-buffer'};       -- Optional
{'hrsh7th/cmp-path'};         -- Optional
{'saadparwaiz1/cmp_luasnip'}; -- Optional
{'hrsh7th/cmp-nvim-lua'};     -- Optional

-- Snippets
{'L3MON4D3/LuaSnip'};             -- Required
{'rafamadriz/friendly-snippets'}; -- Optional
```

With `vim-plug`:

```vim
" LSP Support
Plug 'neovim/nvim-lspconfig'             " Required
Plug 'williamboman/mason.nvim'           " Optional
Plug 'williamboman/mason-lspconfig.nvim' " Optional

" Autocompletion Engine
Plug 'hrsh7th/nvim-cmp'         " Required
Plug 'hrsh7th/cmp-nvim-lsp'     " Required
Plug 'hrsh7th/cmp-buffer'       " Optional
Plug 'hrsh7th/cmp-path'         " Optional
Plug 'saadparwaiz1/cmp_luasnip' " Optional
Plug 'hrsh7th/cmp-nvim-lua'     " Optional

"  Snippets
Plug 'L3MON4D3/LuaSnip'             " Required
Plug 'rafamadriz/friendly-snippets' " Optional

Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'dev-v2'}
```

When using vimscript you can wrap lua code in `lua <<EOF ... EOF`.

```lua
lua <<EOF
print('this an example code')
print('written in lua')
EOF
```

## Usage

Inside your configuration file add this piece of lua code.

```lua
-- Learn the keybindings, see :help lsp-zero-keybindings
-- Learn to configure LSP servers, see :help lsp-zero-api-showcase
local lsp_zero = require('lsp-zero').preset({
  name = 'minimal',
  suggest_lsp_servers = true,
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
})

-- (Optional) Configure lua language server for neovim
lsp_zero.nvim_workspace()

lsp_zero.setup()
```

If you don't install `mason.nvim` then you'll need to list the LSP servers you have installed using [.setup_servers()](#setup_serverslist).

```lua
-- Learn the keybindings, see :help lsp-zero-keybindings
-- Learn to configure LSP servers, see :help lsp-zero-api-showcase
local lsp_zero = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
})

-- When you don't have mason.nvim installed
-- You'll need to list the servers installed in your system
lsp_zero.setup_servers({'tsserver', 'eslint'})

-- (Optional) Configure lua language server for neovim
lsp_zero.nvim_workspace()

lsp_zero.setup()
```

## Breaking changes

* `sign_icons` was removed. If you want the icons you can configure them using [.set_sign_icons()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#set_sign_iconsopts).
* `force_setup` option of [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#configurename-opts) was removed. lsp-zero will configure the server even if is not installed.
* `force` option of [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#configurename-opts) was removed. lsp-zero will configure all the servers listed even if they are not installed.
* The preset `per-project` was removed in favor of the function [.store_config()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#store_configname-opts).

## Changes/Deprecation notice

Settings and functions that will change in the `v3.x` branch. If you are using the `main` branch and want to avoid breaking changes use the `dev-v2` branch.

### Preset settings

* `set_lsp_keymaps` will be removed. The default keymaps will be opt-in in the future. The [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#default_keymapsbufnr) function will be only way to set them.
* `suggest_lsp_servers` will be removed. The suggestions will still be available (they are a feature of [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim)), they will have to be triggered manually using the command `:LspInstall`.
* `cmp_capabilities` will be removed. The features it enables will be configured automatically if [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) is installed.
* `manage_nvim_cmp` will be removed. I recommend using [.extend_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#extend_cmpopts) then call the setup function for nvim-cmp.

### Functions

* [.set_preferences()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#set_preferencesopts) will be removed in favor of overriding option directly in [.preset](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#presetname)
* [.setup_nvim_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#setup_nvim_cmpopts) will be removed in favor [.extend_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#extend_cmpopts).
* [.set_server_config()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#set_server_configopts) will be removed. There is no way I can enforce the settings unless lsp-zero controls everything... which is something I don't want to do anymore.
* [,configure](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#configurename-opts) will be removed. To pass options to an LSP server the user will need to call `lspconfig`.
* [,setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#setup_serverslist) will no longer take an options argument. It'll only be a convenient way to initialize a list of servers.
* [,nvim_workspace()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#nvim_workspaceopts) will return the arguments for the lua language server, the user will need to call the server manually.
* [.default.diagnostics()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#defaultsdiagnosticsopts) will be removed. Diagnostic config has been reduced, only `severity_sort` and borders are enabled. There is no need for this anymore.
* [.defaults.cmp_sources()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#defaultscmp_sources) will be removed. Sources for nvim-cmp will be handled by the user.
* [.defaults.cmp_mappings()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#defaultscmp_mappingsopts) will be removed. In the future only the defaults that align with Neovim's behavior will be configured. lsp-zero default functions for nvim-cmp will have to be added manually by the user.
* [,defaults.nvim_workspace()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#defaultsnvim_workspace) will be replaced by [.nvim_workspace()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#nvim_workspaceopts).

## FAQ

### How do I display error messages?

If you press `gl` on a line with errors (or warnings) a popup window will show up, it will tell you every "diagnostic" on that line.

### How do I get rid warnings in my neovim lua config?

lsp-zero has a function that will configure the lua language server for you: [nvim_workspace](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#nvim_workspaceopts)

### The function .setup_nvim_cmp is not taking any effect, what do I do?

nvim-cmp is tricky. First check [Advance usage - customize nvim-cmp](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/advance-usage.md#customizing-nvim-cmp), the solution you want might be there.

If the settings you want to modify are not supported by [.setup_nvim_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/autocomplete.md#setup_nvim_cmpopts) then follow this example: [The current api is not enough?](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/advance-usage.md#the-current-api-is-not-enough)

### How about adding an option to setup_nv..?

I don't want to add anything to that function. If you have a good reason I will listen, but the answer will probably be no.

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)

