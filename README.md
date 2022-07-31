# LSP Zero

Say you want to start using neovim's built-in LSP client. You browse around the internet and find some blogposts and repositories... everything seems overwhelming. If this scenario sounds familiar to you, then this plugin might be able to help you.

The purpose of this plugin is to bundle all the "boilerplate code" necessary to get [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (a popular completion engine) and the LSP client to work together nicely. Additionally, with the help of [nvim-lsp-installer](https://github.com/williamboman/nvim-lsp-installer/), it can let you install language servers from inside neovim.

Provided that you meet all the requirements for the installation of this plugin and the language servers, the following piece of code should be enough to get started.

```lua
local lsp = require('lsp-zero')

lsp.preset('recommended')
lsp.setup()
```
> If you want to know all the things this preset does for you check out the [Under the hood](https://github.com/VonHeikemen/lsp-zero.nvim/wiki/Under-the-hood) section in the wiki.

`.preset()` will indicate what set of options and features you want enabled. And `.setup()` will be the one doing the heavy lifting. Other forms of customization are available, of course, they are detailed in the [Lua api](https://github.com/VonHeikemen/lsp-zero.nvim#lua-api) section and the [Advance usage](https://github.com/VonHeikemen/lsp-zero.nvim/blob/main/advance-usage.md) page.

If you have any question about configuration, usage or a feature, feel free to ask in the [discussion page](https://github.com/VonHeikemen/lsp-zero.nvim/discussions/).

## Demo

https://user-images.githubusercontent.com/20980671/155446244-14ac3b82-44fd-4011-b25a-e4934db954dc.mp4

Featured in the video:
* Fully functional completion engine (`nvim-cmp`).
* Completions provided by the language server (`sumneko_lua`), as well as other sources.
* Snippet expansion and navigation between placeholders.
* Diagnostic icon showing in the gutter.
* Showing diagnostic message in a floating window.
* Code actions.

## Quickstart (for the impatient)

This section assumes you have chosen the `recommended` preset. It also assumes you don't have any other completion engine installed in your current neovim config.

### Installing

Use your favorite plugin manager to install this plugin and all its lua dependencies.

With `packer`:

```lua
use {
  'VonHeikemen/lsp-zero.nvim',
  requires = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},
    {'williamboman/nvim-lsp-installer'},

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},
    {'hrsh7th/cmp-buffer'},
    {'hrsh7th/cmp-path'},
    {'saadparwaiz1/cmp_luasnip'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/cmp-nvim-lua'},

    -- Snippets
    {'L3MON4D3/LuaSnip'},
    {'rafamadriz/friendly-snippets'},
  }
}
```

With `paq`:

```lua
{'VonHeikemen/lsp-zero.nvim'};

-- LSP Support
{'neovim/nvim-lspconfig'};
{'williamboman/nvim-lsp-installer'};

-- Autocompletion
{'hrsh7th/nvim-cmp'};
{'hrsh7th/cmp-buffer'};
{'hrsh7th/cmp-path'};
{'saadparwaiz1/cmp_luasnip'};
{'hrsh7th/cmp-nvim-lsp'};
{'hrsh7th/cmp-nvim-lua'};

-- Snippets
{'L3MON4D3/LuaSnip'};
{'rafamadriz/friendly-snippets'};
```

With `vim-plug`:

```vim
" LSP Support
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'

" Autocompletion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-nvim-lua'

"  Snippets
Plug 'L3MON4D3/LuaSnip'
Plug 'rafamadriz/friendly-snippets'

Plug 'VonHeikemen/lsp-zero.nvim'
```

### Requirements for language servers

I would suggest you make a quick read in to the [requirements section of nvim-lsp-installer](https://github.com/williamboman/nvim-lsp-installer/#requirements).

Make sure you have at least the minimum requirements listed in `unix systems` or `windows`.

Is worth mention right now that nvim-lsp-installer will be replaced in the future by [mason.nvim](https://github.com/williamboman/mason.nvim). This new installer is based on nvim-lsp-installer and created by the same author. Both are supported in lsp-zero at the moment. Which one I recommend? `nvim-lsp-installer`.

mason.nvim is still very new, but if you'd like to try it replace this plugin:

```
williamboman/nvim-lsp-installer
```

With these two plugins.

```
williamboman/mason.nvim
williamboman/mason-lspconfig.nvim
```

### Usage

Inside your configuration file add this.

```lua
local lsp = require('lsp-zero')

lsp.preset('recommended')
lsp.setup()
```

If you wish to add support for your config written in lua, add this line above `lsp.setup()`.

```lua
lsp.nvim_workspace()
```

Note. If you are using `init.vim` you can wrap the code in `lua-heredoc`s.

```vim
lua <<EOF
local lsp = require('lsp-zero')

lsp.preset('recommended')
lsp.setup()
EOF
```

## Available presets

Presets are a combinations of options that determine how `.setup()` will behave, they can enable or disable features.

### recommended

* Setup every language server installed with `nvim-lsp-installer` at startup.
* Suggest to install a language server when you encounter a new filetype.
* Setup `nvim-cmp` with some default completion sources, this includes support for LSP based completion.
* Setup some default keybindings for `nvim-cmp`.
* Show diagnostic info with "nice" icons.
* Diagnostic messages are shown in a floating window.
* Setup some keybindings related to LSP actions, things like go to definition or rename variable.

### lsp-compe

Is the same as the `recommended` except that it assumes you want full control over the configuration for `nvim-cmp`. It'll provide the `capabilities` config to the languages server but the rest of the config is controlled by the user.

### lsp-only

Is the same as the `recommended` without any support for `nvim-cmp`.

### manual-setup

Is the same as `recommended`, but without automatic setup for language servers. Suggestions for language server will be disabled. The user will need to call the functions `.setup_servers()` or `.configure()` in order to initialize the language servers (See [Lua api](https://github.com/VonHeikemen/lsp-zero.nvim#lua-api) section for more details in these functions).

### per-project

Very similar to `manual-setup`. Automatic setup for language servers and suggestions are disabled. The user can setup default options for each server using `.setup_servers()` or `.configure()`. In order to initialize the server the user will need to call the `.use()` function. (See [Lua api](https://github.com/VonHeikemen/lsp-zero.nvim#lua-api) section for more details in these functions).

### system-lsp

Is the same as `manual-setup`, automatic setup for language servers and suggestions are going to be disabled. It is designed to call language servers installed "globally" on the system. The user will need to call `.configure()` or `.setup_servers()` in order to initialize the language servers. (See [Lua api](https://github.com/VonHeikemen/lsp-zero.nvim#lua-api) section for more details in these functions).

## Choose your features

For this I would recommend deleting the `.preset()` call,  use `.set_preferences()` instead. This function takes a "table" of options, they describe the features this plugin offers.

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

* `suggest_lsp_servers` enables the suggestions of lsp servers when you enter a filetype for the first time.

* `setup_servers_on_start` when set to `true` all installed servers will be initialized on startup. When is set to the string `"per-project"` only the servers listed with the function `.use()` will be initialized. If the value is `false` servers will be initialized when you call `.configure()` or `.setup_servers()`.

* `set_lsp_keymaps` add keybindings to a buffer with a language server attached. This bindings will trigger actions like go to definition, go to reference, etc.

* `configure_diagnostics` uses the built-in function `vim.diagnostic.config` to setup the way error messages are shown in the buffer. It also creates keymaps to navigate between the location of these errors.

* `cmp_capabilities` tell the language servers what capabilities `nvim-cmp` supports.

* `manage_nvim_cmp` use the default setup for `nvim-cmp`. It configures keybindings and completion sources for `nvim-cmp`.

* `call_servers` if set to `'local'` it'll try to setup one of the supported installers (`nvim-lsp-installer` or `mason.nvim`). If set to `'lsp-installer'` it will setup nvim-lsp-installer. If set to `mason` it will setup mason.nvim. If set to `'global'` it will only try to use language servers available globally.

* `sign_icons` they are shown in the "gutter" on the line diagnostics messages are located.

## Autocompletion

### About nvim-cmp

Some details that you should know. The plugin responsable for autocompletion is [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). `nvim-cmp` has a concept of "sources", these provide the actual data displayed in neovim. `lsp-zero` depends on the following sources:

* [cmp-buffer](https://github.com/hrsh7th/cmp-buffer): provides suggestions based on the current file.

* [cmp-path](https://github.com/hrsh7th/cmp-path): gives completions based on the filesystem.

* [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip): it shows snippets in the suggestions.

* [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp): show data send by the language server.

* [cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua): provides completions based on neovim's lua api.

### Default keybindings

* `<Enter>`: Confirms selection.

* `<Up>`: Navigate to previous item on the list.

* `<Down>`: Navigate to the next item on the list.

* `<Ctrl-u>`: Scroll up in the item's documentation.

* `<Ctrl-f>`: Scroll down in the item's documentation.

* `<Ctrl-e>`: Toggles the completion.

* `<Ctrl-d>`: Go to the next placeholder in the snippet.

* `<Ctrl-b>`: Go to the previous placeholder in the snippet.

* `<Tab>`: Enables completion when the cursor is inside a word. If the completion menu is visible it will navigate to the next item in the list.

* `<S-Tab>`: When the completion menu is visible navigate to the previous item in the list.

## LSP

When a language server gets attached to a buffer you gain access to some keybindings and commands. All of these are bound to built-in functions, so you can get more details using the `:help` command.

### Default keybindings

* `K`: Displays hover information about the symbol under the cursor in a floating window. See `:help vim.lsp.buf.hover()`.

* `gd`: Jumps to the definition of the symbol under the cursor. See `:help vim.lsp.buf.definition()`.

* `gD`: Jumps to the declaration of the symbol under the cursor. Some servers don't implement this feature. See `:help vim.lsp.buf.declaration()`.

* `gi`: Lists all the implementations for the symbol under the cursor in the quickfix window. See `:help vim.lsp.buf.implementation()`.

* `go`: Jumps to the definition of the type of the symbol under the cursor. See `:help vim.lsp.buf.type_definition()`.

* `gr`: Lists all the references to the symbol under the cursor in the quickfix window. See `:help vim.lsp.buf.references()`.

* `<Ctrl-k>`: Displays signature information about the symbol under the cursor in a floating window. See `:help vim.lsp.buf.signature_help()`. If a mapping already exists for this key this function is not bound.

* `<F2>`: Renames all references to the symbol under the cursor. See `:help vim.lsp.buf.rename()`.

* `<F4>`: Selects a code action available at the current cursor position. See `:help vim.lsp.buf.code_action()`.

### Commands

* `LspZeroFormat`: Formats the current buffer. See `:help vim.lsp.buf.formatting()`.

* `LspZeroWorkspaceRemove`: Remove the folder at path from the workspace folders. See `:help vim.lsp.buf.remove_workspace_folder()`.

* `LspZeroWorkspaceAdd`: Add the folder at path to the workspace folders. See `:help vim.lsp.buf.add_workspace_folder()`.

* `LspZeroWorkspaceList`: List workspace folders. See `:help vim.lsp.buf.list_workspace_folders()`.

## Diagnostics

In addition to the lsp keymap you also have access to these keybindings when a server is attached to a buffer.

* `gl`: Show diagnostics in a floating window. See `:help vim.diagnostic.open_float()`.
* `[d`: Move to the previous diagnostic in the current buffer. See `:help vim.diagnostic.goto_prev()`.
* `]d`: Move to the next diagnostic. See `:help vim.diagnostic.goto_next()`.

## Language servers and nvim-lsp-installer

Install and updates of language servers is done with [nvim-lsp-installer](https://github.com/williamboman/nvim-lsp-installer/).

> Note: nvim-lsp-installer will be replace by mason.nvim in the far (very far) future. For now, both are supported. But you can only have one installed.

To install a server manually use the command `LspInstall` with the name of the server you want to install. If you don't provide a name `nvim-lsp-installer` will try to suggest a language server based on the filetype of the current buffer.

To check for updates on the language servers use the command `LspInstallInfo`. A floating window will open showing you all the language servers you have installed. If there is any update available, the item will display a message. Navigate to that item and press `u` to install the update.

To uninstall a server use the command `LspInstallInfo`. Navigate to the language server you want to delete and press `X`.

To know more about the available bindings inside the floating window of `LspInstallInfo` press `?`.

If you need to customize `nvim-lsp-installer` make sure you do it before calling the `lsp-zero` module.

```lua
require('nvim-lsp-installer').settings({
  ui = {
    border = 'rounded'
  }
})

local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.setup()
```

### Mason.nvim

On July 24 (2022) the author of nvim-lsp-installer [announced](https://github.com/williamboman/nvim-lsp-installer/discussions/876) the development of nvim-lsp-installer would stop. He will focus on a new installer called [mason.nvim](https://github.com/williamboman/mason.nvim). This new installer has a bigger scope, it can install LSP servers, formatters, linters, etc.

At the moment lsp-zero supports both nvim-lsp-installer and mason.nvim. Usage of mason.nvim is opt-in. If you set the option `call_servers` to `'local'` (this is what the `recommended` preset does) lsp-zero will try to choose the installer based on what plugins are available. You can choose explicitly what installer you want by setting `call_servers` to `'lsp-installer'` or `'mason'`.

If you want to migrate away from nvim-lsp-installer first remove all servers installed. Execute.

```vim
:LspUninstallAll
```

Optionally, you can reset the state of the server suggestions.

```vim
:lua require('lsp-zero.state').reset()
```

Next, remove nvim-lsp-installer from neovim. Use whatever method your plugin manager has.

Last step is to install [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim).

To install packages with mason.nvim use the command `:Mason`. A floating window will show up, it will have the same keybindings as nvim-lsp-installer window.

If you want to customize mason.nvim, you should do it before calling the lsp-zero module. Here is an example.

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

## Global command

* `LspZeroSetupServers`: It takes a space separated list of servers and configures them. It calls the function `.use()` under the hood. If the `bang` is provided the root dir of the language server will be the same as neovim. It is recommended that you use only if you decide to handle server setup manually.

## Lua api

### `.preset({name})`

It creates a combination of settings safe to use for specific cases.

### `.set_preferences({opts})`

It gives the user control over the options available in the plugin.

You can use it to override options from a preset. For example, you could disable the automatic suggestions for language servers even if you are using the `recommended` preset.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.set_preferences({
  suggest_lsp_servers = false
})

lsp.setup()
```

### `.setup()`

The one that coordinates the call to other setup functions. Handles the configuration for `nvim-cmp` and the language servers during startup. It is meant to be the last function you call.

### `.configure({name}, {opts})`

Useful when you need to pass some custom options to a specific language server. Takes the same options as `nvim-lspconfig`'s setup function. More details of these options can be found [here](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

```lua
lsp.configure('tsserver', {
  flags = {
    debounce_text_changes = 150,
  },
  on_attach = function(client, bufnr)
    print('hello tsserver')
  end
})
```

### `.setup_servers({list})`

Used to configure the servers specified in `{list}`. If you provide the `opts` property it will send those options to all language servers. Under the hood it calls `.configure()` for each server on `{list}`.

```lua
local lsp_opts = {
  flags = {
    debounce_text_changes = 150,
  }
}

lsp.setup_servers({
  'html',
  'cssls',
  opts = lsp_opts
})
```

There is a special property called `root_dir`, when set to `true` it will set the root directory of the language server to be the working directory in neovim. `opts` and `root_dir` are mutually exclusive.

```lua
lsp.setup_servers({
  root_dir = true,
  'html',
  'cssls'
})
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
  local noremap = {buffer = bufnr, remap = false}
  local bind = vim.keymap.set

  bind('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<cr>', noremap)
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

`{opts}` is table that will allow you to override some of `nvim-cmp` defaults:

* `completion`: Configures the behavior of the completion menu. You can find more details about its properities if you start typing the command `:help cmp-config.completion`.

* `sources`: List of configurations for "data sources". See `:help cmp-config.sources` to know more.

* `documentation`: Modifies the look of the documentation window. You can find more details about its properities if you start typing the command `:help cmp-config.window`.

* `formatting`: Modifies the look of the completion menu. You can find more details about its properities if you start typing the command `:help cmp-config.formatting`.

* `mapping`: Sets the keybindings. See `:help cmp-mapping`.

Some example config of these options are featured in [nvim-cmp's readme](https://github.com/hrsh7th/nvim-cmp).

### `.use({server}, {opts})`

For when you want full control of the servers you want to use in particular project. It is meant to be called in project local config.

Ideally, you would setup some default values for your servers in your neovim config using `.setup_servers()` or `.configure()`. Example.

```lua
-- init.lua

local lsp = require('lsp-zero')
lsp.preset('per-project')

lsp.configure('pyright', {
  flags = {
    debounce_text_changes = 150,
  }
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

Options from `.configure()` will be merged with the ones on `.use()` and the server will be initialized.

`.use()` can also take a list of servers. All the servers on the list will share the same options.

```lua
-- local config

local lsp = require('lsp-zero')

local lsp_opts = {
  flags = {
    debounce_text_changes = 150,
  }
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

-- Initialize rust_analyzer with rust-tools
require('rust-tools').setup({
  server = lsp.build_options('rust_analyzer', {})
})

lsp.setup()
```

In case you are using the `recommended` preset (or any preset that sets `setup_servers_on_start` to `true`) you need to call `.build_options` before calling `.setup()`.

### `.defaults.cmp_mappings()`

Returns a table with the default keybindings for `nvim-cmp`

### `.defaults.cmp_sources()`

Returns the list of "sources" used in `nvim-cmp`.

### `.defaults.cmp_config()`

Returns the entire configuration table for `nvim-cmp`.

### `.defaults.nvim_workspace()`

Returns the neovim specific settings for `sumneko_lua` language server.

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)

