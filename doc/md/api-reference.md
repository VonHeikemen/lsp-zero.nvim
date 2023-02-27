# API reference

## Commands

* `LspZeroFormat`: Formats the current buffer or range. If the "bang" is provided formatting will be synchronous (ex: LspZeroFormat!). See [:help vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()).

* `LspZeroWorkspaceRemove`: Remove the folder at path from the workspace folders. See [:help vim.lsp.buf.remove_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.remove_workspace_folder()).

* `LspZeroWorkspaceAdd`: Add the folder at path to the workspace folders. See [:help vim.lsp.buf.add_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.add_workspace_folder()).

* `LspZeroWorkspaceList`: List workspace folders. See [:help vim.lsp.buf.list_workspace_folders()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.list_workspace_folders()).

* `LspZeroSetupServers`: It takes a space separated list of servers and configures them.

## Lua api

### `.set_sign_icons({opts})`

Defines the sign icons that appear in the gutter.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
})

lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

lsp.setup()
```

### `.preset({opts})`

The most basic usage `{opts}` can be a string with the name of a preset.

```lua
local lsp = require('lsp-zero').preset('minimal')
```

This creates a combination of settings suitable for common use cases. It supports the following presets:

* [minimal](#minimal)
* [recommended](#recommended)
* [lsp-only](#lsp-only)
* [manual-setup](#manual-setup)
* [system-lsp](#system-lsp)

With time I've learned these presets are only useful to a tiny set of users. So I suggest you start with the [minimal](#minimal) preset and enable other options when you need them.

So you also have the ability to override any setting in the preset if you pass a lua table.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
})
```

### Preset settings

#### `set_lsp_keymaps`

It can be a boolean or a lua table.

Supported properties:

* `preserve_mappings`. Boolean. When set to `false` lsp-zero will not override any shortcut that is already "taken". When set to `true` lsp-zero the LSP shortcuts will be created no matter what.

* `omit`. List of strings. List of shorcuts you don't want lsp-zero to override.

When set_lsp_keymaps is set to true then `preserve_mappings` is assumed to be false and `omit` is set to an empty list. When set_lsp_keymaps is false then the keybindings will not be created.

#### `manage_nvim_cmp`

It can be a boolean or a lua table. When is set to a boolean every supported property will have that value. 

Supported properties:

* `set_mappings`. Boolean. When set to true keybindings for autocomplete will be choosen for you.

* `set_sources`. Boolean. When set to true it will try to setup some [recommended sources](#) for nvim-cmp.

* `use_luasnip`. Boolean. When set to true it will setup luasnip to expand snippets. This option does not include a collection of snippets.

* `set_format`. Boolean. When set to true it'll modify the "format" of completion items.
    
* `documentation_border`. Boolean. When set to true adds border to the documentation window.

#### `setup_servers_on_start`

Boolean. When set to true all servers installed with mason.nvim will be initialized on startup. If the value is `false` servers will be initialized when you call [.configure()](#configurename-opts) or [.setup_servers()](#setup_serverslist).

#### `call_servers`

String. When set to `local` it will use mason.nvim whenever possible. When set to `global` any feature or support that dependes on mason.nvim will be disabled.

#### `configure_diagnostics`

Boolean. When set to true adds borders and sorts "severity" of diagnostics.

### Available presets

#### minimal

Enables the support for mason.nvim if it is installed. Configures the diagnostics. Adds a basic setup to nvim-cmp. It doesn't add keybindings for LSP or autocompletion. Doesn't setup the sources for nvim-cmp.

These are the settings it uses.

```lua
{
  call_servers = 'local',
  configure_diagnostics = true,
  setup_servers_on_start = true,
  set_lsp_keymaps = false,
  manage_nvim_cmp = {
    set_mappings = false,
    set_sources = false,
    use_luasnip = true,
    set_format = true,
    documentation_border = true,
  },
}
```

#### recommended

Creates keybindings bound to [LSP actions](#). Configures diagnostics. Adds a complete configuration to nvim-cmp. And enables support for mason.nvim.

These are the settings it uses.

```lua
{
  call_servers = 'local',
  configure_diagnostics = true,
  setup_servers_on_start = true,
  set_lsp_keymaps = {
    preserve_mappings = false,
    omit = {},
  },
  manage_nvim_cmp = {
    set_mappings = true,
    set_sources = true,
    use_luasnip = true,
    set_format = true,
    documentation_border = true,
  },
}
```

Only use this if you agree with every default setting lsp-zero creates. Otherwise you'll have a very complicated setup that tries to disable everything lsp-zero does (I've seen it happen. Don't be that person).

#### lsp-only

Is base on [recommended](#recommended) but it disables the support for nvim-cmp.

```lua
manage_nvim_cmp = false
```

#### manual-setup

Is based on [recommended](#recommended) but it disables the automatic setup of language servers.

```lua
setup_servers_on_start = false
```

#### system-lsp

Is based on [recommended](#recommended) but it disables all the features that depends on mason.nvim.

```lua
setup_servers_on_start = false
call_servers = 'global'
```

### `.setup()`

This is the function doing all the work. The LSP servers and autocompletion are not configured until this function is called. It should be the last function you call.

### `.on_attach({callback})`

Executes the `{callback}` function every time a server is attached to a buffer.

This is where you can declare your own keymaps and commands.

```lua
local lsp = require('lsp-zero').preset('minimal')

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr}
  local bind = vim.keymap.set

  bind('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  -- more code  ...
end)

lsp.setup()
```

### `.set_server_config({opts})`

It will share the configuration options with all the language servers lsp-zero initializes. These options are the same nvim-lspconfig uses in their setup function, see [:help lspconfig-setup](https://github.com/neovim/nvim-lspconfig/blob/41dc4e017395d73af0333705447e858b7db1f75e/doc/lspconfig.txt#L68).

Here is an example that enables the folding capabilities and disable single file support.

```lua
lsp.set_server_config({
  single_file_support = false,
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

### `.configure({name}, {opts})`

Gathers the arguments for a particular language server. `{name}` must be a string with the name of language server in this list: [server_configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations). And `{opts}` is a lua table with the options for that server. These options are the same nvim-lspconfig uses in their setup function, see [:help lspconfig-setup](https://github.com/neovim/nvim-lspconfig/blob/41dc4e017395d73af0333705447e858b7db1f75e/doc/lspconfig.txt#L68) for more details.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
})

lsp.configure('tsserver', {
  single_file_support = false,
  on_attach = function(client, bufnr)
    print('hello tsserver')
  end
})

lsp.setup()
```

### `.setup_servers({list})`

Will configure all the language servers you have on `{list}`.

This is useful when you disable the automatic setup of language servers.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  setup_servers_on_start = false,
})

lsp.setup_servers({'tssever', 'rust_analyzer'})

lsp.setup()
```

### `.nvim_workspace({opts})`

Configures the language server for lua with options specifically tailored for Neovim.

`{opts}` supports the following properties:

* `root_dir`: a function that determines the working directory of the language server.

* `library`: a list of paths that the server should analyze.

By default only the runtime files of neovim and `vim.fn.stdpath('config')` will be included. To add the path to every plugin you'll need to do this.

```lua
lsp.nvim_workspace({
  library = vim.api.nvim_get_runtime_file('', true)
})
```

### `.skip_server_setup({list})`

All the language servers in `{list}` will be ignored during setup.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
})

lsp.skip_server_setup({'eslint', 'rust_analyzer'})

lsp.setup()
```


### `.ensure_installed({list})`

If you have support for mason.nvim enabled it will install all the servers in `{list}`. The names of the servers should match the ones listed here: [server_configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations).

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
})

lsp.ensure_installed({
  'tsserver',
  'eslint', 
  'rust_analyzer',
})

lsp.setup()
```

### `.build_options({name}, {opts})`

Returns all the parameters lsp-zero uses to initialize a language server. This includes default capabilities and settings that were added using the [.set_server_config()](#set_server_configopts) function.

### `.store_config({name}, {opts})`

Saves the configuration options for a language server, so you can use it at a later time in a local config file.

### `.use({name}, {opts})`

For when you want full control of the servers you want to use in a particular project. It is meant to be called in project local config.

Ideally, you would setup some default values for your servers in your neovim config using [.store_config()](#store_configname-opts).

```lua
-- init.lua

local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
})

lsp.store_config('pyright', {
  single_file_support = false,
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

Options from [.store_config()](#store_configname-opts) will be merged with the ones on `.use()` and the server will be initialized.

lsp-zero does not execute files. It only provides utility functions. So to execute your "local config" you'll have to use another plugin.

### `.cmp_action()`

Is a function that returns methods meant to be used as mappings for nvim-cmp.

These are the supported methods:

* `tab_complete`: Enables completion when the cursor is inside a word. If the completion menu is visible it will navigate to the next item in the list. If the line is empty it uses the fallback.

* `select_prev_or_fallback`: If the completion menu is visible navigate to the previous item in the list. Else, uses the fallback.

* `toggle_completion`: If the completion menu is visible it cancels the process. Else, it triggers the completion menu.

* `luasnip_jump_forward`: Go to the next placeholder in the snippet.

* `luasnip_jump_backward`: Go to the previous placeholder in the snippet.

* `luasnip_supertab`: If the completion menu is visible it will navigate to the next item in the list. If cursor is on top of the trigger of a snippet it'll expand it. If the cursor can jump to a snippet placeholder, it moves to it. If the cursor is in the middle of a word that doesn't trigger a snippet it displays the completion menu. Else, it uses the fallback.

* `luasnip_shift_supertab`: If the completion menu is visible it will navigate to previous item in the list. If the cursor can navigate to a previous snippet placeholder, it moves to it. Else, it uses the fallback.

Quick note: "the fallback" is the default behavior of the key you assign to a method.

### `.extend_cmp({opts})`

In case you don't want to use lsp-zero to actually setup any LSP servers, or want to lazy load nvim-cmp, you can use `.extend_cmp` to setup nvim-cmp.

When you invoke this function it is assumed you want a "minimal" configuration. Meaning that if you call it without `{opts}` it will use the same config the [minimal](#minimal) preset uses in the setting [manage_nvim_cmp](#manage_nvim_cmp).

This is completely valid.

```lua
require('lsp-zero').extend_cmp()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-y>'] = cmp.mapping.confirm({select = true}),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
  }
})
```

`{opts}` supports the same properties [manage_nvim_cmp](#manage_nvim_cmp) has.

### `.extend_lspconfig({opts})`

The purpose of this function is to allow you to interact with `lspconfig` directly and still get some features lsp-zero offers.

It "extends" the default configuration in `lspconfig` by adding the `capabilities` provided by cmp_nvim_lsp. And, it creates an autocommand that executes a function everytime a language server is attached to a buffer.

Note: don't use it along side [.setup()](#setup). It is meant to be independent of any settings provided by presets.

This is the intended usage:

```lua
require('mason').setup()
require('mason-lspconfig').setup()
require('lsp-zero').extend_lspconfig()

require('lspconfig').tsserver.setup({})
```

Notice here it can coexists with other plugins. Allowing you to have full control of your configuration.

`{opts}` table supports the following properties:

* `set_lsp_keymaps`: it supports the same properties as the [preset counter part](#set_lsp_keymaps).

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

---

### Deprecated functions

The following functions will be remove in the future, whenever I feel forced to create a `v3.x` branch (I have no plans for this yet).

### `.set_preferences({opts})`

This function allows you to override any configuration created by a preset. Now, you can do that directly in the [.preset()](#presetopts) call, so there is no good reason to keep using `.set_preferences`.

### `.setup_nvim_cmp({opts})`

Is used to modify the default settings for nvim-cmp.

`{opts}` supports the following properties:

* `completion`: Configures the behavior of the completion menu. You can find more details about its properties if you start typing the command `:help cmp-config.completion`.

* `sources`: List of configurations for "data sources". See `:help cmp-config.sources` to know more.

* `documentation`: Modifies the look of the documentation window. You can find more details about its properities if you start typing the command `:help cmp-config.window`.

* `preselect`: Sometimes the first item in the completion menu is preselected. Disable this behaviour by setting this to `cmp.PreselectMode.None`.

* `formatting`: Modifies the look of the completion menu. You can find more details about its properities if you start typing the command `:help cmp-config.formatting`.

* `mapping`: Sets the keybindings. See `:help cmp-mapping`.

* `select_behavior`: Configure behavior when navigating between items in the completion menu. It can be set to the values `'insert'` or `'select'`. With the value 'select' nothing happens when you move between items. With the value 'insert' it'll put the text from the selection in the buffer. Is worth mention these values are available as "types" in the `cmp` module: `require('cmp').SelectBehavior`.

What to do instead of using `.setup_nvim_cmp()`?

If you really need to customize nvim-cmp I suggest you use the [minimal](#minimal) preset and setup the `sources` and `mappings` directly using the `cmp` module. Like this.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
})

lsp.setup()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-y>'] = cmp.mapping.confirm({select = true}),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
  })
})
```

### `.defaults.diagnostics({opts})`

Returns the configuration for diagnostics. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

### `.defaults.cmp_soures()`

Returns the list of "sources" used in nvim-cmp.

### `.defaults.cmp_mappings({opts})`

Returns a table with the default keybindings for nvim-cmp. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

### `.defaults.cmp_config({opts})`

Returns the entire configuration table for nvim-cmp. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

### `.defaults.nvim_workspace({opts})`

Returns the neovim specific settings for `lua_ls` language server.


