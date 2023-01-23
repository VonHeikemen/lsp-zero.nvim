# LSP Zero

The purpose of this plugin is to bundle all the "boilerplate code" necessary to have [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (a popular autocompletion plugin) and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) working together. And if you opt in, it can use [mason.nvim](https://github.com/williamboman/mason.nvim) to let you install language servers from inside neovim.

## Announcement

The branch [v1.x](https://github.com/VonHeikemen/lsp-zero.nvim/tree/v1.x) has been created. `lsp-zero` is oficially 1.0. I advise you use your favorite plugin manager to track the `v1.x` branch. The code there will remain compatible with neovim v0.5. The next branch `v2.x` will require neovim v0.8 and probably will move to a less opinionated model (which is [already possible with v1](https://dev.to/vonheikemen/make-lsp-zeronvim-coexists-with-other-plugins-instead-of-controlling-them-2i80)). I have [some ideas already](https://github.com/VonHeikemen/lsp-zero.nvim/discussions/130), would love to know what you think.

## How to get started

If you are new to neovim go to the section [Resources for new users](https://github.com/VonHeikemen/lsp-zero.nvim#resources-for-new-users).

If you know how to configure neovim go to [Quickstart (for the impatient)](https://github.com/VonHeikemen/lsp-zero.nvim#quickstart-for-the-impatient).

Also consider [you might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim#you-might-not-need-lsp-zero).

## Demo

https://user-images.githubusercontent.com/20980671/155446244-14ac3b82-44fd-4011-b25a-e4934db954dc.mp4

Showed in the video:
* Fully functional completion engine (`nvim-cmp`).
* Completions provided by the language server (`sumneko_lua`), as well as other sources.
* Snippet expansion and navigation between placeholders.
* Diagnostic icon showing in the gutter.
* Pressing `gl` on the line with a diagnostic shows the full message in a floating window.
* Code actions.

## Features

* Create [keybindings linked to lsp actions](https://github.com/VonHeikemen/lsp-zero.nvim#default-keybindings-1).
* Configures [diagnostics](https://github.com/VonHeikemen/lsp-zero.nvim#diagnostics). Like the way errors, warnings and hints are shown in the UI.
* Setup [autocompletion](https://github.com/VonHeikemen/lsp-zero.nvim#autocompletion).
* Enable automatic setup of LSP servers.

## How to get the most out of this plugin

This plugin is designed to provide an opinionated set of defaults for working with LSP servers and Autocompletion in Neovim. A few things should be considered before you use it in your own config.

* Trying to configure a plugin that is already used inside lsp-zero can cause issues and loss of functionality. If you want to customize lsp-zero please  visit the [Advance usage](https://github.com/VonHeikemen/lsp-zero.nvim/blob/main/advance-usage.md) page, in there you'll find solutions for common scenarios. You can also read about the [lua api](https://github.com/VonHeikemen/lsp-zero.nvim#lua-api) to get details about the functions available for configuration.
* lsp-zero uses [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) to configure the language servers. Manually calling the `lspconfig` while using the `recommended` preset will likely result in a broken configuration.
* If you feel something is missing, search the [discussions](https://github.com/VonHeikemen/lsp-zero.nvim/discussions) to see if it has already been discussed, and open a new discussion if not.
* If you want to set up `nvim-cmp` yourself, you still can. See the [Advanced Usage](https://github.com/VonHeikemen/lsp-zero.nvim/blob/main/advance-usage.md#the-current-api-is-not-enough) section for instructions on how to assure your own configuration does not conflict with lsp-zero.
* Snippet functionality is provided via [Luasnip](https://github.com/L3MON4D3/LuaSnip). You can use Luasnip to write snippets yourself, or install a collection of snippets. The snippet collection [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) is the one recommended in the Install section, but do note it is optional.

## Resources for new users

### Step by Step tutorial

The following tutorial will teach you how to create a minimal config from scratch. You'll learn how to use a plugin manager and setup lsp-zero.

* [Getting started with neovim's LSP client](https://dev.to/vonheikemen/getting-started-with-neovims-native-lsp-client-in-the-year-of-2022-the-easy-way-bp3#starting-from-scratch)

### Template configuration

If you haven't created a configuration file (`init.lua`) for neovim, here's a minimal working config. It has a plugin manager, a colorscheme and lsp-zero all setup.

* [nvim-starter - lsp-zero](https://github.com/VonHeikemen/nvim-starter/tree/xx-lsp-zero)

Do not clone the repo `nvim-starter`, just follow the instructions on the readme.

### I installed lsp-zero, how do I configure it?

Check out the [Available Presets](https://github.com/VonHeikemen/lsp-zero.nvim#available-presets). Maybe your use case is covered by one the presets. If not, go to [Choose your features](https://github.com/VonHeikemen/lsp-zero.nvim#choose-your-features).

Read the [Advance Usage](https://github.com/VonHeikemen/lsp-zero.nvim/blob/main/advance-usage.md) page, in there you'll find solutions to common questions.

Browse the [lua api](https://github.com/VonHeikemen/lsp-zero.nvim#lua-api). Those are the functions you can use to configure lsp-zero.

If you have any question about a feature or configuration feel free to open a new [discussion](https://github.com/VonHeikemen/lsp-zero.nvim/discussions) in this repository. Or join [#lsp-zero-nvim:matrix.org](https://matrix.to/#/#lsp-zero-nvim:matrix.org).

### But my config file is init.vim, not init.lua

In Neovim there is a thing called `lua-heredoc` it will allow you to execute lua code in your `init.vim`. This is the syntax:

```lua
lua <<EOF
print('this is an example code')
print('written in lua')
EOF
```

The configuration code for lsp-zero should be place between `lua <<EOF ... EOF`.

## Quickstart (for the impatient)

This section assumes you want enable every single feature lsp-zero offers. Optional and required plugins will be marked with a comment.

If you know your way around neovim and how to configure it, take a look at this examples:

* [Lua template configuration](https://github.com/VonHeikemen/lsp-zero.nvim/wiki/Lua-template-configuration)
* [Vimscript template configuration](https://github.com/VonHeikemen/lsp-zero.nvim/wiki/Vimscript-template-configuration)

### Requirements for language servers

I suggest you read the [requirements of mason.nvim](https://github.com/williamboman/mason.nvim#requirements).

Make sure you have at least the minimum requirements listed in `unix systems` or `windows`.

### Installing

Use your favorite plugin manager to install this plugin and all its lua dependencies.

With `packer`:

```lua
use {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v1.x',
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

With `paq`:

```lua
{'VonHeikemen/lsp-zero.nvim', branch = 'v1.x'};

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

Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v1.x'}
```

With `lazy.nvim`:

```lua
{
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v1.x',
    dependencies = {
        -- LSP Support
        'neovim/nvim-lspconfig',             -- required
        'williamboman/mason-lspconfig.nvim', -- optional
        'williamboman/mason.nvim',           -- optional
        -- Autocompletion
        'hrsh7th/cmp-buffer',                -- required
        'hrsh7th/cmp-nvim-lsp',              -- required
        'hrsh7th/cmp-nvim-lua',              -- optional
        'hrsh7th/cmp-path',                  -- optional
        'hrsh7th/nvim-cmp',                  -- optional
        'saadparwaiz1/cmp_luasnip',          -- optional
        -- Snippets
        'L3MON4D3/LuaSnip',                  -- required
        'rafamadriz/friendly-snippets',      -- optional
    },
}
```

### Usage

Inside your configuration file add this piece of lua code.

```lua
-- Learn the keybindings, see :help lsp-zero-keybindings
-- Learn to configure LSP servers, see :help lsp-zero-api-showcase
local lsp = require('lsp-zero')
lsp.preset('recommended')

-- (Optional) Configure lua language server for neovim
lsp.nvim_workspace()

lsp.setup()
```

If you don't install `mason.nvim` then you'll need to list the LSP servers you have installed using [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim#setup_serverslist).

```lua
-- Learn the keybindings, see :help lsp-zero-keybindings
-- Learn to configure LSP servers, see :help lsp-zero-api-showcase
local lsp = require('lsp-zero')
lsp.preset('recommended')

-- When you don't have mason.nvim installed
-- You'll need to list the servers installed in your system
lsp.setup_servers({'tsserver', 'eslint'})

-- (Optional) Configure lua language server for neovim
lsp.nvim_workspace()

lsp.setup()
```

Remember, when using vimscript you can wrap lua code in `lua <<EOF ... EOF`.

```lua
lua <<EOF
-- Learn the keybindings, see :help lsp-zero-keybindings
-- Learn to configure LSP servers, see :help lsp-zero-api-showcase
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.setup()
EOF
```

The `recommended` preset will enable automatic suggestions of language servers. So any time you open a filetype for the first time it'll try to ask if you want to install a language server that supports it.

If you already know what language servers you want, you can use the function [.ensure_installed()](https://github.com/VonHeikemen/lsp-zero.nvim#ensure_installedlist) to install them automatically. See the example in [API showcase](https://github.com/VonHeikemen/lsp-zero.nvim#api-showcase)

### API showcase

Before you go, allow me to showcase a configuration example a bit more complex.

```lua
-- Reserve space for diagnostic icons
vim.opt.signcolumn = 'yes'

local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.ensure_installed({
  -- Replace these with whatever servers you want to install
  'tsserver',
  'eslint',
  'sumneko_lua',
})

-- Pass arguments to a language server
lsp.configure('tsserver', {
  on_attach = function(client, bufnr)
    print('hello tsserver')
  end,
  settings = {
    completions = {
      completeFunctionCalls = true
    }
  }
})

-- Configure lua language server for neovim
lsp.nvim_workspace()

lsp.setup()
```

## Available presets

Presets are a combinations of options that determine how [.setup()](https://github.com/VonHeikemen/lsp-zero.nvim#setup) will behave, they can enable or disable features.

### recommended

* Setup every language server installed with mason.nvim at startup.
* Suggest to install a language server when you encounter a new filetype.
* Setup nvim-cmp with some default completion sources, this includes support for LSP based completion.
* Setup some default keybindings for nvim-cmp.
* Show diagnostic info with "nice" icons.
* Diagnostic messages are shown in a floating window.
* Setup some keybindings related to LSP actions, things like go to definition or rename variable.

### lsp-compe

Is the same as the `recommended` except that it assumes you want full control over the configuration for nvim-cmp. It'll provide the "client capabilities" config to the languages server but the rest of the config is controlled by the user.

### lsp-only

Is the same as the `recommended` without any support for nvim-cmp.

### manual-setup

Is the same as `recommended`, but without automatic setup for language servers. Suggestions for language server will be disabled. The user will need to call the functions [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim#setup_serverslist) or [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim#configurename-opts) in order to initialize the language servers (See [Lua api](https://github.com/VonHeikemen/lsp-zero.nvim#lua-api) section for more details in these functions).

### per-project

Very similar to `manual-setup`. Automatic setup for language servers and suggestions are disabled. The user can setup default options for each server using [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim#setup_serverslist) or [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim#configurename-opts). In order to initialize the server the user will need to call the [.use()](https://github.com/VonHeikemen/lsp-zero.nvim#useserver-opts) function. (See [Lua api](https://github.com/VonHeikemen/lsp-zero.nvim#lua-api) section for more details in these functions).

### system-lsp

Is the same as `manual-setup`, automatic setup for language servers and suggestions are going to be disabled. It is designed to call language servers installed "globally" on the system. The user will need to call [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim#setup_serverslist) or [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim#configurename-opts) in order to initialize the language servers. (See [Lua api](https://github.com/VonHeikemen/lsp-zero.nvim#lua-api) section for more details in these functions).

## Choose your features

For this I would recommend deleting the [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim#presetname) call,  use [.set_preferences()](https://github.com/VonHeikemen/lsp-zero.nvim#set_preferencesopts) instead. This function takes a "table" of options, they describe the features this plugin offers.

These are the options the `recommended` preset uses.

```lua
lsp.set_preferences({
  suggest_lsp_servers = true,
  setup_servers_on_start = true,
  set_lsp_keymaps = true,
  configure_diagnostics = true,
  cmp_capabilities = true,
  manage_nvim_cmp = true,
  call_servers = 'local',
  sign_icons = {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = ''
  }
})
```

If you want to disable a feature replace `true` with `false`.

* `suggest_lsp_servers`: enables the suggestions of lsp servers when you enter a filetype for the first time.

* `setup_servers_on_start`: when set to `true` all installed servers will be initialized on startup. When is set to the string `"per-project"` only the servers listed with the function [.use()](https://github.com/VonHeikemen/lsp-zero.nvim#useserver-opts) will be initialized. If the value is `false` servers will be initialized when you call [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim#configurename-opts) or [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim#set_server_configopts).

* `set_lsp_keymaps`: add keybindings to a buffer with a language server attached. This bindings will trigger actions like go to definition, go to reference, etc. You can also specify list of keys you want to omit, see the [lua api section](https://github.com/VonHeikemen/lsp-zero.nvim#set_preferencesopts) for an example.

* `configure_diagnostics`: uses the built-in function [vim.diagnostic.config](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.config()) to setup the way error messages are shown in the buffer. It also creates keymaps to navigate between the location of these errors.

* `cmp_capabilities`: tell the language servers what capabilities nvim-cmp supports.

* `manage_nvim_cmp`: use the default setup for nvim-cmp. It configures keybindings and completion sources for nvim-cmp.

* `call_servers`: if set to `'local'` it'll try to initialize servers that where installed using mason.nvim. If set to `'global'` all language servers you list using [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim#configurename-opts) or [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim#set_server_configopts) are assumed to be installed (a warning message will show up if they aren't).

* `sign_icons`: they are shown in the "gutter" on the line diagnostics messages are located.

## Autocompletion

### About nvim-cmp

Some details that you should know. The plugin responsable for autocompletion is [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). `nvim-cmp` has a concept of "sources", these provide the actual data displayed in neovim. `lsp-zero` will configure the following sources if they are installed:

* [cmp-buffer](https://github.com/hrsh7th/cmp-buffer): provides suggestions based on the current file.

* [cmp-path](https://github.com/hrsh7th/cmp-path): gives completions based on the filesystem.

* [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip): it shows snippets in the suggestions.

* [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp): show data send by the language server.

* [cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua): provides completions based on neovim's lua api.

### Default keybindings

* `<Enter>`: Confirms selection.

* `<Ctrl-y>`: Confirms selection.

* `<Up>`: Navigate to previous item on the list.

* `<Down>`: Navigate to the next item on the list.

* `<Ctrl-p>`: Navigate to previous item on the list.

* `<Ctrl-n>`: Navigate to the next item on the list.

* `<Ctrl-u>`: Scroll up in the item's documentation.

* `<Ctrl-f>`: Scroll down in the item's documentation.

* `<Ctrl-e>`: Toggles the completion.

* `<Ctrl-d>`: Go to the next placeholder in the snippet.

* `<Ctrl-b>`: Go to the previous placeholder in the snippet.

* `<Tab>`: Enables completion when the cursor is inside a word. If the completion menu is visible it will navigate to the next item in the list.

* `<S-Tab>`: When the completion menu is visible navigate to the previous item in the list.

## Snippets

[friendly-snippets](https://github.com/rafamadriz/friendly-snippets) is the plugin that provides the snippets. And [luasnip](https://github.com/L3MON4D3/LuaSnip/) is the "snippet engine", the thing that expands the snippet and allows you to navigate between snippet placeholders.

Both `friendly-snippets` and `luasnip` are optional. But `nvim-cmp` will give you a warning if you don't setup a snippet engine. If you don't use luasnip then configure a different snippet engine.

* How to disable snippets?

If you already have it all setup then uninstall `friendly-snippets` and also `cmp_luasnip`.

* Change to snippets with snipmate syntax

Uninstall `friendly-snippets` if you have it. Use [onza/vim-snippets](https://github.com/honza/vim-snippets). Then add the luasnip loader somewhere in your config.

```lua
require('luasnip.loaders.from_snipmate').lazy_load()
```

## LSP

Language servers are configured and initialized using [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/).

If you ever wondered "What does lsp-zero do?" This is the answer:

```lua
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
local lsp_attach = function(client, bufnr)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, {buffer = bufnr})
  -- More keybindings and commands....
end

require('lspconfig').tsserver.setup({
  on_attach = lsp_attach,
  capabilities = lsp_capabilities
})
```

In this example I'm using `tsserver` but it could be any LSP server.

What happens is that lsp-zero uses `lspconfig`'s setup function to initialize the LSP server. Then uses the `on_attach` option to create the keybindings and commands. Finally, it passes the "client capabilities" to the LSP server, this is the integration between the LSP client and the autocompletion plugin.

### Default keybindings

When a language server gets attached to a buffer you gain access to some keybindings and commands. All of these are bound to built-in functions, so you can get more details using the `:help` command.

* `K`: Displays hover information about the symbol under the cursor in a floating window. See [:help vim.lsp.buf.hover()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.hover()).

* `gd`: Jumps to the definition of the symbol under the cursor. See [:help vim.lsp.buf.definition()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.definition()).

* `gD`: Jumps to the declaration of the symbol under the cursor. Some servers don't implement this feature. See [:help vim.lsp.buf.declaration()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.declaration()).

* `gi`: Lists all the implementations for the symbol under the cursor in the quickfix window. See [:help vim.lsp.buf.implementation()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.implementation()).

* `go`: Jumps to the definition of the type of the symbol under the cursor. See [:help vim.lsp.buf.type_definition()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.type_definition()).

* `gr`: Lists all the references to the symbol under the cursor in the quickfix window. See [:help vim.lsp.buf.references()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.references()).

* `<Ctrl-k>`: Displays signature information about the symbol under the cursor in a floating window. See [:help vim.lsp.buf.signature_help()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.signature_help()). If a mapping already exists for this key this function is not bound.

* `<F2>`: Renames all references to the symbol under the cursor. See [:help vim.lsp.buf.rename()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.rename()).

* `<F4>`: Selects a code action available at the current cursor position. See [:help vim.lsp.buf.code_action()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.code_action()).

* `gl`: Show diagnostics in a floating window. See [:help vim.diagnostic.open_float()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.open_float()).

* `[d`: Move to the previous diagnostic in the current buffer. See [:help vim.diagnostic.goto_prev()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.goto_prev()).

* `]d`: Move to the next diagnostic. See [:help vim.diagnostic.goto_next()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.goto_next()).

### Commands

* `LspZeroFormat`: Formats the current buffer or range. If the "bang" is provided formatting will be synchronous (ex: `LspZeroFormat!`). See [:help vim.lsp.buf.formatting()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.formatting()), [:help vim.lsp.buf.range_formatting()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.range_formatting()), [:help vim.lsp.buf.formatting_sync()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.formatting_sync()).

* `LspZeroWorkspaceRemove`: Remove the folder at path from the workspace folders. See [:help vim.lsp.buf.remove_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.remove_workspace_folder()).

* `LspZeroWorkspaceAdd`: Add the folder at path to the workspace folders. See [:help vim.lsp.buf.add_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.add_workspace_folder()).

* `LspZeroWorkspaceList`: List workspace folders. See [:help vim.lsp.buf.list_workspace_folders()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.list_workspace_folders()).

## Diagnostics

To configure the UI for diagnostics lsp-zero uses [vim.diagnostic.config](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.config()) with the following arguments.

```lua
{
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
}
```

Now, if you notice the sign_icons "pop up" and moving your screen is because you have `signcolumn` set to `auto`. I recommend setting it to "yes" to preserve the space in the gutter.

```vim
set signcolumn=yes
```

If you use lua.

```lua
vim.opt.signcolumn = 'yes'
```

If you want to override some settings lsp-zero provides make sure you call `vim.diagnostic.config` after lsp-zero's setup.

Here is an example that restores the built-in configuration for diagnostics.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.setup()

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = false,
  float = true,
})
```

## Language servers and mason.nvim

Install and updates of language servers is done with [mason.nvim](https://github.com/williamboman/mason.nvim).

> With mason.nvim you can also install formatters and debuggers, but `lsp-zero` will only configure LSP servers.

To install a server manually use the command `LspInstall` with the name of the server you want to install. If you don't provide a name `mason-lspconfig.nvim` will try to suggest a language server based on the filetype of the current buffer.

To check for updates on the language servers use the command `Mason`. A floating window will open showing you all the tools mason.nvim can install. You can filter the packages by categories for example, language servers are in the second category, so if you press the number `2` it'll show only the language servers. The packages you have installed will appear at the top. If there is any update available the item will display a message. Navigate to that item and press `u` to install the update.

To uninstall a package use the command `Mason`. Navigate to the item you want to delete and press `X`.

To know more about the available bindings inside the floating window of `Mason` press `g?`.

If you need to customize `mason.nvim` make sure you do it before calling the `lsp-zero` module.

```lua
require('mason.settings').set({
  ui = {
    border = 'rounded'
  }
})

local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.setup()
```

### Opt-out of mason.nvim

Really all you need is to uninstall `mason.nvim` and `mason-lspconfig`. But the correct way to opt-out if you are using the `recommended` preset is to change it to `system-lsp`. Or call [.set_preferences()](https://github.com/VonHeikemen/lsp-zero.nvim#set_preferencesopts) and use these settings:

```lua
suggest_lsp_servers = false
setup_servers_on_start = false
call_servers = 'global'
```

Then you need to specify which language server you want to setup, for this use [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim#setup_serverslist) or [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim#configurename-opts).

### Migrate from nvim-lsp-installer to mason.nvim

On July 24 (2022) the author of nvim-lsp-installer [announced](https://github.com/williamboman/nvim-lsp-installer/discussions/876) the development of that project would stop. He will focus on [mason.nvim](https://github.com/williamboman/mason.nvim) instead. This new installer has a bigger scope, it can install LSP servers, formatters, linters, etc.

At the moment lsp-zero supports both nvim-lsp-installer and mason.nvim. But you should migrate to mason.nvim as soon as possible. nvim-lsp-installer no longer receives any updates.

To migrate away from nvim-lsp-installer first remove all servers installed. Execute.

```vim
:LspUninstallAll
```

Optionally, you can reset the state of the server suggestions.

```vim
:lua require('lsp-zero.state').reset()
```

Next, remove nvim-lsp-installer from neovim. Use whatever method your plugin manager has.

Last step is to install [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim).

## You might not need lsp-zero

Really. Out of [all the features](https://github.com/VonHeikemen/lsp-zero.nvim#features) this plugin offers there is a good chance the only thing you want is the automatic setup of LSP servers. Let me tell you how to configure that.

You'll need these plugins:

* [mason.nvim](https://github.com/williamboman/mason.nvim)
* [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim)
* [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/)
* [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) (optional)

After you have installed all that you configure them in this order.

```lua
require('mason').setup()

require('mason-lspconfig').setup({
  ensure_installed = {
    -- Replace these with whatever servers you want to install
    'rust_analyzer',
    'tsserver',
  }
})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
local lsp_attach = function(client, bufnr)
  -- Create your keybindings here...
end

local lspconfig = require('lspconfig')
require('mason-lspconfig').setup_handlers({
  function(server_name)
    lspconfig[server_name].setup({
      on_attach = lsp_attach,
      capabilities = lsp_capabilities,
    })
  end,
})
```

In this example I have automatic install of servers using the option `ensure_installed` in `mason-lspconfig`. You can delete that list of servers and add your own.

If you notice your LSP servers don't behave correctly, it might be because `.setup_handlers`. You can replace that function with a `for` loop.

```lua
local lspconfig = require('lspconfig')
local get_servers = require('mason-lspconfig').get_installed_servers

for _, server_name in ipairs(get_servers()) do
  lspconfig[server_name].setup({
    on_attach = lsp_attach,
    capabilities = lsp_capabilities,
  })
end
```

To learn how to use the `on_attach` option you can read the help page `:help lspconfig-keybindings`.

## Global command

* `LspZeroSetupServers`: It takes a space separated list of servers and configures them. It calls the function [.use()](https://github.com/VonHeikemen/lsp-zero.nvim#useserver-opts) under the hood. If the `bang` is provided the root dir of the language server will be the same as neovim. It is recommended that you use only if you decide to handle server setup manually.

## Lua api

### `.preset({name})`

It creates a combination of settings safe to use for specific cases. Make sure is the first function you call after you require lsp-zero module.

`{name}` can be one of the following:

* recommended
* lsp-compe
* lsp-only
* manual-setup
* per-project
* system-lsp

### `.set_preferences({opts})`

It gives the user control over the options available in the plugin.

You can use it to override options from a preset.

You could disable the automatic suggestions for language servers, and also specify a list of lsp keymaps to omit during setup.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.set_preferences({
  suggest_lsp_servers = false
  set_lsp_keymaps = {omit = {'<F2>', 'gl'}}
})

lsp.setup()
```

### `.setup()`

The one that coordinates the call to other setup functions. Handles the configuration for `nvim-cmp` and the language servers during startup. It is meant to be the last function you call.

### `.set_server_config({opts})`

Sets a default configuration for all LSP servers. You can find more details about `{opts}` in the help page `:help lspconfig-setup`.

```lua
lsp.set_server_config({
  single_file_support = false,
})
```

### `.configure({name}, {opts})`

Useful when you need to pass some custom options to a specific language server. Takes the same options as `nvim-lspconfig`'s setup function. You can find more details in the help page `:help lspconfig-setup`.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.configure('tsserver', {
  single_file_support = false,
  on_attach = function(client, bufnr)
    print('hello tsserver')
  end
})

lsp.setup()
```

If you have a server installed globally you can use the option `force_setup` to skip any internal check.

```lua
lsp.configure('dartls', {force_setup = true})
```

### `.setup_servers({list})`

Used to configure the servers specified in `{list}`. If you provide the `opts` property it will send those options to all language servers. Under the hood it calls [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim#configurename-opts) for each server on `{list}`.

```lua
local lsp_opts = {
  single_file_support = false,
}

lsp.setup_servers({'html', 'cssls', opts = lsp_opts})
```

If the servers you want to call are installed globally use the option `force` to skip any internal check.

```lua
lsp.setup_servers({'dartls', 'vls', force = true})
```

### `.skip_server_setup({name})`

Disables one or more language server. It tells lsp-zero to skip the initialization of the language servers provided. Its only effective when `setup_servers_on_start` is set to `true`.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.skip_server_setup({'eslint', 'angularls'})

lsp.setup()
```

### `.on_attach({callback})`

Execute `{callback}` function every time a server is attached to a buffer.

Let's say you want to disable all the default keybindings for lsp actions and diagnostics, and then declare your own.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.set_preferences({
  set_lsp_keymaps = false
})

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}
  local bind = vim.keymap.set

  bind('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  -- more code  ...
end)

lsp.setup()
```

### `.ensure_installed({list})`

Installs all the servers in `{list}` if they are missing.

```lua
lsp.ensure_installed({
  'html',
  'cssls',
  'tsserver'
})
```

### `.nvim_workspace({opts})`

Configures the language server for lua with all the options needed to provide completions specific to neovim.

`{opts}` supports two properties:

* `root_dir`: a function that determines the working directory of the language server.

* `library`: a list of paths that the server should analyze.

By default only the runtime files of neovim and `vim.fn.stdpath('config')` will be included. To add the path to every plugin you'll need to do this.

```lua
lsp.nvim_workspace({
  library = vim.api.nvim_get_runtime_file('', true)
})
```

### `.setup_nvim_cmp({opts})`

`{opts}` is a table that will allow you to override defaults configured by lsp-zero:

* `completion`: Configures the behavior of the completion menu. You can find more details about its properties if you start typing the command `:help cmp-config.completion`.

* `sources`: List of configurations for "data sources". See `:help cmp-config.sources` to know more.

* `documentation`: Modifies the look of the documentation window. You can find more details about its properities if you start typing the command `:help cmp-config.window`.

* `preselect`: By default, the first item in the completion menu is preselected. Disable this behaviour by setting this to `cmp.PreselectMode.None`.

* `formatting`: Modifies the look of the completion menu. You can find more details about its properities if you start typing the command `:help cmp-config.formatting`.

* `mapping`: Sets the keybindings. See `:help cmp-mapping`.

* `select_behavior`: Configure behavior when navigating between items in the completion menu. It can be set to the values `'insert'` or `'select'`. With the value 'select' nothing happens when you move between items. With the value 'insert' it'll put the text from the selection in the buffer. Is worth mention these values are available as "types" in the `cmp` module: `require('cmp').SelectBehavior`.

Some example config of these options are featured in [nvim-cmp's readme](https://github.com/hrsh7th/nvim-cmp).

If what you want is to extend the configuration of nvim-cmp, I suggest you change the preset to `lsp-compe`. There is an [example configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/main/advance-usage.md#the-current-api-is-not-enough) in the Advance usage page.

### `.use({server}, {opts})`

For when you want full control of the servers you want to use in particular project. It is meant to be called in project local config.

Ideally, you would setup some default values for your servers in your neovim config using [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim#set_server_configopts) or [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim#configurename-opts). Example.

```lua
-- init.lua

local lsp = require('lsp-zero')
lsp.preset('per-project')

lsp.configure('pyright', {
  single_file_support = false
})

lsp.setup()
```

And then in your local config you can tweak the server options even more.

```lua
-- local config

local lsp = require('lsp-zero')

lsp.use('pyright', {
  settings = {
    python = {
      analysis = {
        extraPaths = {'/path/to/my/dependencies'},
      }
    }
  }
})
```

Options from [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim#configurename-opts) will be merged with the ones on `.use()` and the server will be initialized.

`.use()` can also take a list of servers. All the servers on the list will share the same options.

```lua
-- local config

local lsp = require('lsp-zero')

local lsp_opts = {
  single_file_support = false
}

lsp.use({'html', 'cssls'}, lsp_opts)
```

### `.build_options({server}, {opts})`

Returns all the parameters necessary to start a language using `nvim-lspconfig`'s setup function. After calling this function you'll need to initialize the language server by other means.

The `{opts}` table will be merged with the rest of the default options for `{server}`.

This function was designed as an escape hatch, so you can call a language server using other tools.

For example, if you want to use `rust-tools`, this is how you'll do it.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.skip_server_setup({'rust_analyzer'})

lsp.setup()

-- Initialize rust_analyzer with rust-tools
local rust_lsp = lsp.build_options('rust_analyzer', {})
require('rust-tools').setup({server = rust_lsp})
```

### `.set_sign_icons({opts})`

Defines the sign icons that appear in the gutter. If `{opts}` is not provided the default icons will be used.

`{opts}` table supports these properties:

* `error`: Text for the error signs.
* `warn`: Text for the warning signs.
* `hint`: Text for the hint signs.
* `info`: Text for the information signs.

### `.defaults.diagnostics({opts})`

Returns the configuration for diagnostics. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

### `.defaults.cmp_sources()`

Returns the list of "sources" used in `nvim-cmp`.

### `.defaults.cmp_mappings({opts})`

Returns a table with the default keybindings for `nvim-cmp`. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

Here is an example that disables completion with tab and replace it with `Ctrl + space`.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

local cmp = require('cmp')
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>'] = cmp.mapping.abort(),
})

-- disable completion with tab
cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

-- disable confirm with Enter key
cmp_mappings['<CR>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.setup()
```

### `.defaults.cmp_config({opts})`

Returns the entire configuration table for `nvim-cmp`. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

```lua
local lsp = require('lsp-zero')
lsp.preset('lsp-compe')

lsp.setup()

vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

local cmp = require('cmp')
local cmp_config = lsp.defaults.cmp_config({
  window = {
    completion = cmp.config.window.bordered()
  }
})

cmp.setup(cmp_config)
```

### `.defaults.nvim_workspace()`

Returns the neovim specific settings for `sumneko_lua` language server.

### `.extend_lspconfig({opts})`

The purpose of this function is to allow you to interact with `lspconfig` directly and still enjoy all the keybindings and commands lsp-zero offers.

It "extends" the default configuration in `lspconfig`, adding two options to it: `capabilities` and `on_attach`.

Note: don't use it along side [.setup()](https://github.com/VonHeikemen/lsp-zero.nvim#setup). Its meant to be independent of any settings provided by presets.

This is the intended usage:

```lua
require('mason').setup()
require('mason-lspconfig').setup()
require('lsp-zero').extend_lspconfig()

require('lspconfig').tsserver.setup({})
```

Notice here it can coexists with other plugins. Allowing you to have full control of your configuration.

`{opts}` table supports the following properties:

* `set_lsp_keymaps`: When set to `true` (the default) it creates [keybindings linked to lsp actions](https://github.com/VonHeikemen/lsp-zero.nvim#default-keybindings-1). You can also provide a list of keys you want to omit, lsp-zero will not bind it to anything (see example below). When set to `false` all keybindings are disabled.

* `capabilities`: These are the "client capabilities" a language server expects. This argument will be merge nvim-cmp's default capabilities if you have it installed.

* `on_attach`: This must be a function. Think of it as "global" `on_attach` so you don't have to keep passing a function to each server's setup function.

Here's an example that showcase each option.

```lua
-- There is no need to copy any of this

require('lsp-zero').extend_lspconfig({
  set_lsp_keymaps = {omit = {'<C-k>', 'gl'}},
  on_attach = function(client, bufnr)
    print('hello there')
  end,
  capabilities = {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }
    }
  }
})
```

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)

