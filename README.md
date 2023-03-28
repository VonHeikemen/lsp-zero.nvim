# LSP Zero

The purpose of this plugin is to bundle all the "boilerplate code" necessary to have [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (a popular autocompletion plugin) and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) working together. And if you opt in, it can use [mason.nvim](https://github.com/williamboman/mason.nvim) to let you install language servers from inside neovim.

If you have any question about a feature or configuration feel free to open a new [discussion](https://github.com/VonHeikemen/lsp-zero.nvim/discussions) in this repository. Or join the chat [#lsp-zero-nvim:matrix.org](https://matrix.to/#/#lsp-zero-nvim:matrix.org).

## Announcement

The branch [v2.x](https://github.com/VonHeikemen/lsp-zero.nvim/tree/v2.x) has been created. You can now test `v2` of lsp-zero. The `main` branch still points to `v1.x`, but this will probably change by the end of March. So if you are still using the `main` branch, please change it to `v1.x` to avoid breaking changes.

This new release of lsp-zero recommends a less opinionated configuration. The aim is to let lsp-zero "extend" `lspconfig` and `nvim-cmp` with some defaults, and then let the user interact with each plugin directly if they need further customizations. This will make it easier for everyone to integrate other plugins from the Neovim ecosystem with lsp-zero.

## How to get started

If you are new to neovim go to the section [Resources for new users](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/getting-started.md#resources-for-new-users).

If you know how to configure neovim go to [Quickstart (for the impatient)](#quickstart-for-the-impatient).

Also consider [you might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#you-might-not-need-lsp-zero).

## Documentation

* LSP
  * [Introduction to nvim-lspconfig](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#introduction)
  * [Default keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#default-keybindings)
  * [Commands](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#commands)
  * [Install new language servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#install-new-language-servers) 
  * [Configure language servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#configure-language-servers) 
  * [Disable a language server](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#disable-a-language-server) 
  * [Custom servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#custom-servers) 
  * [Enable format on save](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#enable-format-on-save) 
  * [Format buffer using a keybinding](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#format-buffer-using-a-keybinding) 
  * [Troubleshooting](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#troubleshooting)
  * [Diagnostics](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#diagnostics) (A.K.A. error messages and warnings)
  * [Language servers and mason.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#language-servers-and-masonnvim)
  * [You might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#you-might-not-need-lsp-zero).

* Autocompletion
  * [About nvim-cmp](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/autocomplete.md#about-nvim-cmp)
  * [Default keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/autocomplete.md#default-keybindings)
  * [Override keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/autocomplete.md#override-keybindings)
  * [Snippets](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/autocomplete.md#snippets)
  * [Common Configurations](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/autocomplete.md#common-configurations)

* How to customize lsp-zero
  * [Advance Usage](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/advance-usage.md)
  * [API Reference](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md) (Available functions)

## Quickstart (for the impatient)

This section assumes you want enable every single feature lsp-zero offers. Optional and required plugins will be marked with a comment.

If you know your way around neovim and how to configure it, take a look at this examples:

* [Lua template configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/configuration-templates.md#lua-template)
* [Vimscript template configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/configuration-templates.md#vimscript-template)

## Requirements for language servers

I suggest you read the [requirements of mason.nvim](https://github.com/williamboman/mason.nvim#requirements).

Make sure you have at least the minimum requirements listed in `unix systems` or `windows`.

## Installing

Use your favorite plugin manager to install this plugin and all its lua dependencies.

With `packer.nvim`: 

```lua
use {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v1.x',
  requires = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},                         -- Required
    {'williamboman/mason.nvim', run = ':MasonUpdate'}, -- Optional
    {'williamboman/mason-lspconfig.nvim'},             -- Optional

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
  branch = 'v1.x',
  dependencies = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},                           -- Required
    {'williamboman/mason.nvim', build = ':MasonUpdate'}, -- Optional
    {'williamboman/mason-lspconfig.nvim'},               -- Optional

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
{'VonHeikemen/lsp-zero.nvim', branch = 'v1.x'};

-- LSP Support
{'neovim/nvim-lspconfig'};                                                -- Required
{'williamboman/mason.nvim', run = function() vim.cmd('MasonUpdate') end}; -- Optional
{'williamboman/mason-lspconfig.nvim'};                                    -- Optional

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
Plug 'neovim/nvim-lspconfig'                           " Required
Plug 'williamboman/mason.nvim', {'do': ':MasonUpdate'} " Optional
Plug 'williamboman/mason-lspconfig.nvim'               " Optional

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

Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v1.x'}
```

## Usage

Inside your configuration file add this piece of lua code.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

-- (Optional) Configure lua language server for neovim
lsp.nvim_workspace()

lsp.setup()
```

If you want to install a language server for a particular file type use the command `:LspInstall`. And when the installation is done restart neovim.

If you don't want to manage your language servers with `mason.nvim` then you'll need to list the LSP servers you want to configure with [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#setup_serverslist).

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

-- When you don't have mason.nvim installed
-- You'll need to list the servers installed in your system
lsp.setup_servers({'tsserver', 'eslint'})

-- (Optional) Configure lua language server for neovim
lsp.nvim_workspace()

lsp.setup()
```

When using vimscript you can wrap lua code in `lua <<EOF ... EOF`.

```lua
lua <<EOF
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup()
EOF
```

Remember to read the documentation for [LSP](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#introduction) and [autocompletion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/autocomplete.md#about-nvim-cmp) for more details.

## FAQ

### How do I display error messages?

If you press `gl` on a line with errors (or warnings) a popup window will show up, it will tell you every "diagnostic" on that line.

### Some of the default keybindings for LSP don't work, what do I do?

By default lsp-zero will not override a keybinding if it's already "taken". Maybe you or another plugin are already using these keybindings. What you can do is modify the option `set_lsp_keymaps` so lsp-zero can force its keybindings.

```lua
set_lsp_keymaps = {preserve_mappings = false},
```

### How do I get rid warnings in my neovim lua config?

lsp-zero has a function that will configure the lua language server for you: [nvim_workspace](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#nvim_workspaceopts)

### How do I stop icons from moving my screen?

That's neovim's default behavior. Modify the option `signcolumn`, set it to "yes".

If you use lua.

```lua
vim.opt.signcolumn = 'yes'
```

If you use vimscript.

```vim
set signcolumn=yes
```

### The function .setup_nvim_cmp is not taking any effect, what do I do?

nvim-cmp is tricky. First check [Advance usage - customize nvim-cmp](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/advance-usage.md#customizing-nvim-cmp), the solution you want might be there.

If the settings you want to modify are not supported by [.setup_nvim_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/autocomplete.md#setup_nvim_cmpopts) then follow this example: [The current api is not enough?](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/advance-usage.md#the-current-api-is-not-enough)

### How about adding an option to setup_nv..?

I don't want to add anything to that function. If you have a good reason I will listen, but the answer will probably be no.

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)

