# LSP Zero

Collection of functions that will help you setup Neovim's LSP client, so you can get IDE-like features with minimum effort.

Out of the box it will help you integrate [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (an autocompletion plugin) and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) (a collection of configurations for various language servers). So a minimal config can look like this.

```lua
require('lsp-zero')
require('lspconfig').lua_ls.setup({})
-- don't copy/paste this if you don't know what is `lua_ls`.
-- yes, lsp-zero has changed since ThePrimeagen released his video "0 to LSP".
```

With this code when `lua_ls` (a language server) is active you'll get all the features Neovim offers by default plus autocompletion.

If you came here from a tutorial read the [migration guide section](#migration-guides) 

<details>
<summary>Expand: What happens under the hood? </summary>

When `require('lsp-zero')` is called this is what happens:

* lsp-zero makes sure the configuration provided by [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) is applied to every language server configured by `nvim-lspconfig`.
* Sets up a "backup" configuration for the essential options in nvim-cmp. So autocompletion can work even if the user forgets something important.
* Reserves a space for the signcolumn.
* Adds border to floating windows on diagnostics, the documentation window of the hover handler and signature help handler.

[Here's the simplified code of these steps](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/what-require-lsp-zero-does.md). In case you want to understand it without looking at source code of the plugin itself.

Note that lsp-zero offers more features but those are opt-in, see [usage section](#usage).

</details>

## How to get started

If you are new to neovim and you don't have a configuration file (`init.lua`) follow this [step by step tutorial](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/tutorial.md).

If you know how to configure neovim go to [Quickstart (for the impatient)](#quickstart-for-the-impatient).

Also consider [you might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/you-might-not-need-lsp-zero.md).

### If you need any help

Feel free to open a new [discussion](https://github.com/VonHeikemen/lsp-zero.nvim/discussions) in this repository. Or join the chat [#lsp-zero-nvim:matrix.org](https://matrix.to/#/#lsp-zero-nvim:matrix.org).

If have problems with a language server read this guide: [What to do when the language server doesn't start?](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/what-to-do-when-lsp-doesnt-start.md).

## Migration guides

`v3.x` is the current version of lsp-zero. If you are using a previous version follow one of these guides.

* [Migrate from v1.x branch](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/migrate-from-v1-branch.md)
* [Migrate from v2.x branch](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/migrate-from-v2-branch.md)
* [ThePrimeagen's 0 to LSP config](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/configuration-templates.md#primes-config)
* [Migrate away from lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/you-might-not-need-lsp-zero.md)

## Documentation

* LSP

  * [How does it work?](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#how-does-it-work)
  * [Commands](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#commands)
  * [Creating new keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#creating-new-keybindings)
  * [Disable keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#disable-keybindings)
  * [Install new language servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#install-new-language-servers)
  * [Configure language servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#configure-language-servers)
  * [Disable semantic highlights](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#disable-semantic-highlights)
  * [Exclude a language server from the automatic setup](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md#exclude-a-language-server-from-the-automatic-setup)
  * [Custom servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#custom-servers)
  * [Enable Format on save](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#enable-format-on-save)
  * [Format buffer using a keybinding](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#format-buffer-using-a-keybinding)
  * [Use icons in the sign column](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#use-icons-in-the-sign-column)
  * [What to do when a language server doesn't start?](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/what-to-do-when-lsp-doesnt-start.md)

* Autocompletion

  * [How does it work?](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#how-does-it-work)
  * [Keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#keybindings)
  * [Use Enter to confirm completion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#use-enter-to-confirm-completion)
  * [Adding a source](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#adding-a-source)
  * [Add an external collection of snippets](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#add-an-external-collection-of-snippets)
  * [Preselect first item](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#preselect-first-item)
  * [Basic completions for Neovim's lua api](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#basic-completions-for-neovims-lua-api)
  * [Enable "Super Tab"](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#enable-super-tab)
  * [Regular tab complete](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#regular-tab-complete)
  * [Invoke completion menu manually](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#invoke-completion-menu-manually)
  * [Adding borders to completion menu](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#adding-borders-to-completion-menu)
  * [Change formatting of completion item](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#change-formatting-of-completion-item)
  * [lsp-kind](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#lsp-kind)

* Reference and guides

  * [API Reference](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md)
  * [Tutorial: Step by step setup from scratch](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/tutorial.md)
  * [What to do when the language server doesn't start?](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/what-to-do-when-lsp-doesnt-start.md)
  * [Migrate from v1.x branch](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/migrate-from-v1-branch.md)
  * [Migrate from v2.x branch](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/migrate-from-v2-branch.md)
  * [lsp-zero under the hood](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/under-the-hood.md)
  * [You might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/you-might-not-need-lsp-zero.md)
  * [Lazy loading with lazy.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/lazy-loading-with-lazy-nvim.md)
  * [Integrate with mason.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md)
  * [Enable folds with nvim-ufo](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/quick-recipes.md#enable-folds-with-nvim-ufo)
  * [Enable inlay hints with lsp-inlayhints.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/quick-recipes.md#enable-inlay-hints-with-lsp-inlayhintsnvim)
  * [Setup copilot.lua + nvim-cmp](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/setup-copilot-lua-plus-nvim-cmp.md#setup-copilotlua--nvim-cmp)
  * [Setup with nvim-navic](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/quick-recipes.md#setup-with-nvim-navic)
  * [Setup with rustaceanvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/quick-recipes.md#setup-with-rustaceanvim)
  * [Setup with flutter-tools](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/quick-recipes.md#setup-with-flutter-tools)
  * [Setup with nvim-jdtls](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/setup-with-nvim-jdtls.md)
  * [Setup with nvim-metals](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/quick-recipes.md#setup-with-nvim-metals)
  * [Setup with haskell-tools](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/quick-recipes.md#setup-with-haskell-tools)

## Quickstart (for the impatient)

lsp-zero requires Neovim v0.8 or greater. If you need support for Neovim v0.7 use the [branch compat-07](https://github.com/VonHeikemen/lsp-zero.nvim/tree/compat-07).

If you know your way around Neovim and how to configure it, take a look at this examples:

* [Lua template configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/configuration-templates.md#lua-template)
* [Vimscript template configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/configuration-templates.md#vimscript-template)
* [ThePrimeagen's "0 to LSP" config adapted to version 3](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/configuration-templates.md#primes-config)

The following sections will show how to create a basic configuration.

### Installing

Use your favorite plugin manager to install this plugin and all its lua dependencies.

<details>
<summary>Expand: lazy.nvim </summary>

For a more advance config that lazy loads everything take a look at the example on this link: [Lazy loading guide](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/lazy-loading-with-lazy-nvim.md).

```lua
--- Uncomment the two plugins below if you want to manage the language servers from neovim
-- {'williamboman/mason.nvim'},
-- {'williamboman/mason-lspconfig.nvim'},

{'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
{'neovim/nvim-lspconfig'},
{'hrsh7th/cmp-nvim-lsp'},
{'hrsh7th/nvim-cmp'},
{'L3MON4D3/LuaSnip'},
```

</details>

<details>
<summary>Expand: packer.nvim </summary>

```lua
use {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v3.x',
  requires = {
    --- Uncomment the two plugins below if you want to manage the language servers from neovim
    -- {'williamboman/mason.nvim'},
    -- {'williamboman/mason-lspconfig.nvim'},

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
<summary>Expand: paq.nvim </summary>

```lua
{'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'};

--- Uncomment the two plugins below if you want to manage the language servers from neovim
-- {'williamboman/mason.nvim'};
-- {'williamboman/mason-lspconfig.nvim'};

-- LSP Support
{'neovim/nvim-lspconfig'};
-- Autocompletion
{'hrsh7th/nvim-cmp'};
{'hrsh7th/cmp-nvim-lsp'};
{'L3MON4D3/LuaSnip'};
```

</details>

<details>
<summary>Expand: vim-plug </summary>

```vim
"  Uncomment the two plugins below if you want to manage the language servers from neovim
"  Plug 'williamboman/mason.nvim'
"  Plug 'williamboman/mason-lspconfig.nvim'

" LSP Support
Plug 'neovim/nvim-lspconfig'
" Autocompletion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'

Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v3.x'}
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

First thing you will want to do setup some default keybindings. The common convention here is to setup these keybindings only when you have a language server active in the current file. Here is the code to achieve that.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- here you can setup the language servers 
```

Next step is to install a language server. Go to nvim-lspconfig's documentation, in the [server_configuration.md](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) file you'll find a list of language servers and how to install them.

Once you have a language server installed in your system, add the setup in your Neovim config. Use the module `lspconfig`, like this.

```lua
require('lspconfig').example_server.setup({})

--- in your own config you should replace `example_server`
--- with the name of a language server you have installed
```

If you need to customize the language server, add your settings inside the `{}`. To know more details about lspconfig use the command `:help lspconfig` or [click here](https://github.com/neovim/nvim-lspconfig/blob/8917d2c830e04bf944a699b8c41f097621283828/doc/lspconfig.txt#L46).

If you did install `lua_ls` and you want to configure it specifically for Neovim [these are your options](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/neovim-lua-ls.md).

#### Automatic setup of language servers

If you decided to install [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) you can manage the installation of the language servers from inside Neovim, and then use lsp-zero to handle the configuration.

Here is a basic usage example.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- to learn how to use mason.nvim with lsp-zero
-- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md
require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {},
  handlers = {
    lsp_zero.default_setup,
  },
})
```

If you need to configure a language server installed by `mason.nvim`, add a "handler function" to the `handlers` option. Something like this:

```lua
require('mason-lspconfig').setup({
  ensure_installed = {},
  handlers = {
    lsp_zero.default_setup,

    --- replace `example_server` with the name of a language server
    example_server = function()
      --- in this function you can setup
      --- the language server however you want. 
      --- in this example we just use lspconfig

      require('lspconfig').example_server.setup({
        ---
        -- in here you can add your own
        -- custom configuration
        ---
      })
    end,
  },
})
```

For more details about how to use mason.nvim with lsp-zero see the guide on how to [integrate with mason.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md).

## Language servers

### Keybindings

If you choose to use the function [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#default_keymapsopts) you'll be able to use Neovim's built-in functions for various actions. Things like jump to definition, rename variable, format current file, and some more.

Note that the keybindings have to be enabled explicitly, like this.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)
```

Here's the full list:

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

You can force lsp-zero's bindings by adding `preserve_mappings = false` to [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#default_keymapsopts).

```lua
lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({
    buffer = bufnr,
    preserve_mappings = false
  })
end)
```

### Root directory

When you open a file compatible with a language server `lspconfig` will search for a set of files in the current folder or any of the parent folders. If it finds them, the language server will start analyzing that folder. So the "root directory" is basically your project folder.

Some language servers have "single file support" enabled, this means if `lspconfig` can't determine the root directory then the current working directory becomes your root directory.

If your language server doesn't attach to a file, make sure the file and the project folder meet the requirements of the language server.

How do you know what are the requirements? Search the [list of language servers](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) and read their documentation, or inspect the configuration provided by lspconfig using the command `LspZeroViewConfigSource`.

For example, this command will open the configuration for the lua language server.

```vim
LspZeroViewConfigSource lua_ls
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

To add more keybindings I recommend you use [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) directly.

Here is an example configuration.

```lua
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate between snippet placeholder
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  })
})
```

## Breaking changes

Changed/Removed features from the `v2.x` branch.

Note: You can disable the warnings about removed functions by setting the global variable `lsp_zero_api_warnings` to `0`. Before you require the module lsp-zero, put this `vim.g.lsp_zero_api_warnings = 0`.

### Functions

* [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#presetopts) was removed. Most settings were remove. The remaining settings can be changed using global variables, see [global variables](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#global-variables).
* [.set_preferences()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#set_preferencesopts) was removed in favor of overriding option directly in the [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#presetname).
* [.setup_nvim_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup_nvim_cmpopts) was be removed. Use the `cmp` module to customize nvim-cmp.
* [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup_serverslist) will no longer take an options argument. It'll only be a convenient way to initialize a list of servers.
* [.default.diagnostics()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#defaultsdiagnosticsopts) was removed. Diagnostics are not configured anymore.
* [.defaults.cmp_sources()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#defaultscmp_sources) was removed. Sources for nvim-cmp should be handled by the user.
* [.defaults.cmp_mappings()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#defaultscmp_mappingsopts) was removed. All nvim-cmp mappings can be overriden using the `cmp` module.
* [.nvim_workspace()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#nvim_workspaceopts) was removed. Use [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#nvim_lua_lsopts) to get the config for the lua language server.
* [.defaults.nvim_workspace()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#defaultsnvim_workspace) was replaced by [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#nvim_lua_lsopts).
* [.ensure_installed()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#ensure_installedlist) was removed. Use the module `mason-lspconfig` to install the language servers.
* [.new_server()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#new_serveropts) was renamed to [.new_client()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/api-reference.md#new_clientopts).

## FAQ

### How do I get rid warnings in my neovim lua config?

You have two choices, and the details about them are on this guide: [lua_ls for Neovim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/neovim-lua-ls.md).

### Can I use the Enter key to confirm completion item?

Yes, you can. You can find the details in the autocomplete documentation: [Enter key to confirm completion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#use-enter-to-confirm-completion).

### Configure sign_icons

[Here is an example](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#use-icons-in-the-sign-column).

### How to configure snippets?

I hope you mean custom snippets like [friendly snippets](https://github.com/rafamadriz/friendly-snippets), 'cause some language servers already provide snippets. Anyway, [the answer is here](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/autocomplete.md#add-an-external-collection-of-snippets).

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)

