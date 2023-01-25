# Getting started

## Resources for new users

### Step by Step tutorial

The following tutorial will teach you how to create a minimal config from scratch. You'll learn how to use a plugin manager and setup lsp-zero v1.

* [Getting started with neovim's LSP client](https://dev.to/vonheikemen/getting-started-with-neovims-native-lsp-client-in-the-year-of-2022-the-easy-way-bp3#starting-from-scratch)

### Template configuration

If you haven't created a configuration file (`init.lua`) for neovim, here's a minimal working config. It has a plugin manager, a colorscheme and lsp-zero all setup.

* [nvim-starter - lsp-zero](https://github.com/VonHeikemen/nvim-starter/tree/xx-lsp-zero)

Do not clone the repo `nvim-starter`, just follow the instructions on the readme.

### I installed lsp-zero, how do I configure it?

Check out the [Available Presets](#available-presets). Maybe your use case is covered by one the presets. If not, go to [Choose your features](#choose-your-features).

Read the [Advance Usage](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/advance-usage.md) page, in there you'll find solutions to common questions.

Browse the [lua api](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#lua-api). Those are the functions you can use to configure lsp-zero.

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

## Available presets

Presets are a combinations of options that determine how [.setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#setup) will behave, they can enable or disable features.

### recommended

* Setup every language server installed with mason.nvim at startup.
* Suggest to install a language server when you encounter a new filetype.
* Setup nvim-cmp with some default completion sources, this includes support for LSP based completion.
* Setup some default keybindings for nvim-cmp.
* Show diagnostic info with "nice" icons.
* Diagnostic messages are shown in a floating window.
* Setup some keybindings related to LSP actions, things like go to definition or rename variable.

### lsp-compe

Is the same as the [recommended](#recommended) except that it assumes you want full control over the configuration for nvim-cmp. It'll provide the "client capabilities" config to the languages server but the rest of the config is controlled by the user.

### lsp-only

Is the same as the [recommended](#recommended) without any support for nvim-cmp.

### manual-setup

Is the same as [recommended](#recommended), but without automatic setup for language servers. Suggestions for language server will be disabled. The user will need to call the functions [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#setup_serverslist) or [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#configurename-opts) in order to initialize the language servers.

### per-project

Very similar to [manual-setup](#manual-setup). Automatic setup for language servers and suggestions are disabled. The user can setup default options for each server using [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#setup_serverslist) or [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#configurename-opts). In order to initialize the server the user will need to call the [.use()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#useserver-opts) function.

### system-lsp

Is the same as [manual-setup](#manual-setup), automatic setup for language servers and suggestions are going to be disabled. It is designed to call language servers installed "globally" on the system. The user will need to call [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#setup_serverslist) or [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#configurename-opts) in order to initialize the language servers.

## Choose your features

For this I would recommend deleting the [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#presetname) call,  use [.set_preferences()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#set_preferencesopts) instead. This function takes a "table" of options, they describe the features this plugin offers.

These are the options the [recommended](#recommended) preset uses.

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

* `setup_servers_on_start`: when set to `true` all installed servers will be initialized on startup. When is set to the string `"per-project"` only the servers listed with the function [.use()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#useserver-opts) will be initialized. If the value is `false` servers will be initialized when you call [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#configurename-opts) or [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#set_server_configopts).

* `set_lsp_keymaps`: add keybindings to a buffer with a language server attached. This bindings will trigger actions like go to definition, go to reference, etc. You can also specify list of keys you want to omit, see the [lua api section](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#set_preferencesopts) for an example.

* `configure_diagnostics`: uses the built-in function [vim.diagnostic.config](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.config()) to setup the way error messages are shown in the buffer. It also creates keymaps to navigate between the location of these errors.

* `cmp_capabilities`: tell the language servers what capabilities nvim-cmp supports.

* `manage_nvim_cmp`: use the default setup for nvim-cmp. It configures keybindings and completion sources for nvim-cmp.

* `call_servers`: if set to `'local'` it'll try to initialize servers that where installed using mason.nvim. If set to `'global'` all language servers you list using [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#configurename-opts) or [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#set_server_configopts) are assumed to be installed (a warning message will show up if they aren't).

* `sign_icons`: they are shown in the "gutter" on the line diagnostics messages are located.

