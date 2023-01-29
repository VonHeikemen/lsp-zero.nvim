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

## Usage

Inside your configuration file add this piece of lua code.

```lua
-- Learn the keybindings, see :help lsp-zero-keybindings
-- Learn to configure LSP servers, see :help lsp-zero-api-showcase
local lsp = require('lsp-zero').preset({
  name = 'mason-lsp',
  set_lsp_keymaps = true,
})

-- (Optional) Configure lua language server for neovim
lsp.nvim_workspace()

lsp.setup()
```

If you don't install `mason.nvim` then you'll need to list the LSP servers you have installed using [.setup_servers()](#setup_serverslist).

```lua
-- Learn the keybindings, see :help lsp-zero-keybindings
-- Learn to configure LSP servers, see :help lsp-zero-api-showcase
local lsp = require('lsp-zero').preset({
  name = 'system-lsp',
  set_lsp_keymaps = true,
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
print('this an example code')
print('written in lua')
EOF
```

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

