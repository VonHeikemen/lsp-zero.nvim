# API reference

## Commands

* `LspZeroFormat {server} timeout={timeout}`: Formats the current buffer or range. Under the hood lsp-zero is using the function `vim.lsp.buf.format()`. If the "bang" is provided formatting will be asynchronous (ex: `LspZeroFormat!`). If you provide the name of a language server as a first argument it will try to format only using that server. Otherwise, it will use every active language server with formatting capabilities. With the `timeout` parameter you can configure the time in milliseconds to wait for the response of the formatting requests.

* `LspZeroWorkspaceRemove`: Remove the folder at path from the workspace folders. See [:help vim.lsp.buf.remove_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.remove_workspace_folder()).

* `LspZeroWorkspaceAdd`: Add the folder at path to the workspace folders. See [:help vim.lsp.buf.add_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.add_workspace_folder()).

* `LspZeroWorkspaceList`: List workspace folders. See [:help vim.lsp.buf.list_workspace_folders()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.list_workspace_folders()).

* `LspZeroSetupServers`: It takes a space separated list of servers and configures them.

## Lua api

### `.set_sign_icons({opts})`

Defines the sign icons that appear in the gutter.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

lsp.setup()
```

### `.preset({opts})`

Here is where you can add settings specific to lsp-zero. The default configuration is described in the [minimal preset](#minimal). 

You can override any value of the preset by using a lua table, like this.

```lua
local lsp = require('lsp-zero').preset({
  float_border = 'none',
})
```

In order to remain compatible with the `v1.x` branch `{opts}` can be a string with the name of a preset.

```lua
local lsp = require('lsp-zero').preset('minimal')
```

> I would like to get rid of these "named presets" in the future. It's better if you add the settings using a lua table.

It supports the following presets:

* [minimal](#minimal)
* [recommended](#recommended)
* [lsp-only](#lsp-only)
* [manual-setup](#manual-setup)
* [system-lsp](#system-lsp)

When using a lua table as argument you can pass the property `name` to specify which preset you wish to use. And of course, you can still override the configuration in the preset.

```lua
local lsp = require('lsp-zero').preset({
  name = 'recommended',
  call_servers = 'global',
})
```

If you don't specify a preset then [minimal](#minimal) will be the default.

### Preset settings

#### `set_lsp_keymaps`

It can be a boolean or a lua table.

Supported properties:

* `preserve_mappings`. Boolean. When set to `true` lsp-zero will not override any shortcut that is already "taken". When set to `false` lsp-zero the LSP shortcuts will be created no matter what.

* `omit`. List of strings. List of shorcuts you don't want lsp-zero to override.

When set_lsp_keymaps is set to true then `preserve_mappings` is assumed to be false and `omit` is set to an empty list. When set_lsp_keymaps is false then the keybindings will not be created.

#### `manage_nvim_cmp`

It can be a boolean or a lua table. When is set to a boolean every supported property will have that value. 

Supported properties:

* `set_basic_mappings`. Boolean. When set to true it will create keybindings that emulate Neovim's default completion.

* `set_extra_mappings`. Boolean. When set to true it will setup tab completion, scrolling through documentation window, and navigation between snippets.

* `set_sources`. String or Boolean. When set to `'lsp'` it will only setup [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) as a source. When set to `'recommended'` it will try to setup a few [recommended sources](#) for nvim-cmp. When set to the Boolean `false` it won't setup any sources.

* `use_luasnip`. Boolean. When set to true it will setup luasnip to expand snippets. This option does not include a collection of snippets.

* `set_format`. Boolean. When set to true it'll modify the "format" of the completion items.
    
* `documentation_window`. Boolean. When set to true enables the documentation window.

#### `setup_servers_on_start`

Boolean. When set to true all servers installed with mason.nvim will be initialized on startup. If the value is `false` servers will be initialized when you call [.configure()](#configurename-opts) or [.setup_servers()](#setup_serverslist).

#### `call_servers`

String. When set to `local` it will use mason.nvim whenever possible. When set to `global` any feature or support that dependes on mason.nvim will be disabled.

#### `configure_diagnostics`

Boolean. When set to true adds borders and sorts "severity" of diagnostics.

#### `float_border`

String. Shape of borders in floating windows. It can be one of the following: `'none'`, `'single'`, `'double'`, `'rounded'`, `'solid'` or `'shadow'`.

### Available presets

#### minimal

Enables the support for mason.nvim if it is installed. Configures the diagnostics. Adds a basic setup to nvim-cmp. It doesn't add keybindings for LSP or autocompletion. Doesn't setup the sources for nvim-cmp.

These are the settings it uses.

```lua
{
  float_border = 'rounded',
  call_servers = 'local',
  configure_diagnostics = true,
  setup_servers_on_start = true,
  set_lsp_keymaps = false,
  manage_nvim_cmp = {
    set_sources = 'lsp',
    set_basic_mappings = true,
    set_extra_mappings = false,
    use_luasnip = true,
    set_format = true,
    documentation_window = true,
  },
}
```

#### recommended

Creates keybindings bound to [LSP actions](#lsp-actions). Configures diagnostics. Adds a complete configuration to nvim-cmp. And enables support for mason.nvim.

These are the settings it uses.

```lua
{
  float_border = 'rounded',
  call_servers = 'local',
  configure_diagnostics = true,
  setup_servers_on_start = true,
  set_lsp_keymaps = {
    preserve_mappings = false,
    omit = {},
  },
  manage_nvim_cmp = {
    set_sources = 'recommended',
    set_basic_mappings = true,
    set_extra_mappings = false,
    use_luasnip = true,
    set_format = true,
    documentation_window = true,
  },
}
```

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

### `.default_keymaps({opts})`

Create the keybindings bound to built-in LSP functions. 

The `{opts}` table supports the same properties as [set_lsp_keymaps](#set_lsp_keymaps) and adds the following:

* buffer: Number. The "id" of an open buffer. If the number `0` is provided then the keymaps will be effective in the current buffer.

#### LSP Actions

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

### `.setup()`

This is the function doing all the work. The LSP servers and autocompletion are not configured until this function is called. It should be the last function you call.

### `.on_attach({callback})`

Executes the `{callback}` function every time a server is attached to a buffer.

This is where you can declare your own keymaps and commands.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr}) -- add lsp-zero defaults

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
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

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
  setup_servers_on_start = false,
})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup_servers({'tsserver', 'rust_analyzer'})

lsp.setup()
```

### `.skip_server_setup({list})`

All the language servers in `{list}` will be ignored during setup.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.skip_server_setup({'eslint', 'rust_analyzer'})

lsp.setup()
```

### `.build_options({name}, {opts})`

Returns all the parameters lsp-zero uses to initialize a language server. This includes default capabilities and settings that were added using the [.set_server_config()](#set_server_configopts) function.

### `.nvim_lua_ls({opts})`

Returns settings specific to Neovim for the lua language server, lua_ls.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()
```

If you provide the {opts} table it'll merge it with the defaults, this way you can extend or change the values easily.

```lua
require('lspconfig').lua_ls.setup(
  lsp.nvim_lua_ls({
    single_file_support = false,
    on_attach = function(client, bufnr)
      print('hello there')
    end,
  })
)
```

If you provide the {opts} table it'll merge it with the defaults, this way you can extend or change the values easily.

### `.store_config({name}, {opts})`

Saves the configuration options for a language server, so you can use it at a later time in a local config file.

### `.use({name}, {opts})`

For when you want you want to add more settings to a particular language server in a particular project. It is meant to be called in project local config (but you can still use it in your init.lua).

Ideally, you would setup some default values for your servers in your neovim config using [.configure()](#configurename-opts), or maybe [.store_config()](#store_configname-opts) if you don't use any presets.

```lua
-- init.lua

local lsp = require('lsp-zero')

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.configure('pyright', {
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

Options from [.configure()](#configurename-opts) will be merged with the ones on `.use()` and the server will restart with the new config.

lsp-zero does not execute files. It only provides utility functions. So to execute your "local config" you'll have to use another plugin.

### `.format_on_save({opts})`

Setup autoformat on save. This will to allow you to associate a language server with a list of filetypes.

Keep in mind it's only meant to allow one LSP server per filetype, this is so the formatting is consistent.

`{opts}` supports the following properties:

  * servers: (Table) Key/value pair list. On the left hand side you must specify the name of a language server. On the right hand side you must provide a list of filetypes, this can be any pattern supported by the `FileType` autocommand.

  * format_opts: (Table). These are the options you can pass to [vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()).

When you enable async formatting the only argument in `format_opts` that will have any effect are `formatting_options` and `timeout_ms`, the rest will be ignored.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.format_on_save({
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
    ['lua_ls'] = {'lua'},
    ['rust_analyzer'] = {'rust'},
  }
})

lsp.setup()
```

### `.buffer_autoformat({client}, {bufnr}, {opts})`

Format the current buffer using the active language servers.

If {client} argument is provided it will only use the LSP server associated with that client.

  * client: (Table, Optional) if provided it must be a lua table with a `name` property or an instance of [vim.lsp.client](https://neovim.io/doc/user/lsp.html#vim.lsp.client).

  * bufnr: (Number, Optional) if provided it must be the id of an open buffer.

  * opts: (Table). These are the same options you can pass to [vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()).

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
  lsp.buffer_autoformat()
end)

lsp.setup()
```

### `.async_autoformat({client}, {bufnr}, {opts})`

Send a formatting request to `{client}`. After the getting the response from the client it will save the file (again).

Here is how it works: when you save the file Neovim will write your changes without formatting. Then, lsp-zero will send a request to `{client}`, when it gets the response it will apply the formatting and save the file again.

* client: (Table) It must be an instance of [vim.lsp.client](https://neovim.io/doc/user/lsp.html#vim.lsp.client).

* bufnr: (Number, Optional) if provided it must be the id of an open buffer.

* opts: (Table, Optional) Supports the following properties:
  
  * formatting_options: (Table, Optional) Settings send to the language server. These are the same settings as the `formatting_options` argument in [vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()).

  * timeout_ms: (Number, Optional) Defaults to 10000. Time in milliseconds to ignore the current format request.

Do not use this in the global `on_attach`, call this function with the specific language server you want to format with.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

require('lspconfig').tsserver.setup({
  on_attach = function(client, bufnr)
    lsp.async_autoformat(client, bufnr)
  end
})

lsp.setup()
```

### `.format_mapping({key}, {opts})`

Configure {key} to format the current buffer.   

The idea here is that you associate a language server with a list of filetypes, so `{key}` can format the buffer using only one LSP server.

`{opts}` supports the following properties:

  * servers: (Table) Key/value pair list. On the left hand side you must specify the name of a language server. On the right hand side you must provide a list of filetypes, this can be any pattern supported by the `FileType` autocommand.

  * format_opts: (Table). These are the options you can pass to [vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()).

  * mode: (Table). The list of modes where the keybinding will be active. By default is set to `{'n', 'x'}`, which means normal mode and visual mode.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.format_mapping('gq', {
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
    ['lua_ls'] = {'lua'},
    ['rust_analyzer'] = {'rust'},
  }
})

lsp.setup()
```

### `.new_server({opts})`

lsp-zero will execute a user provided function to detect the root directory of the project when Neovim assigns the file type for a buffer. If the root directory is detected the LSP server will be attached to the file.

This function does not depend on `lspconfig`, it's a thin wrapper around a Neovim function called [vim.lsp.start()](https://neovim.io/doc/user/lsp.html#vim.lsp.start()).

`{opts}` supports every property `vim.lsp.start` supports with a few changes:

  * `filestypes`: Can be list filetype names. This can be any pattern the `FileType` autocommand accepts.

  * `root_dir`: Can be a function, it'll be executed after Neovim assigns the file type for a buffer. If it returns a string that will be considered the root directory for the project.

Other important properties are:

  * `cmd`: (Table) A lua table with the arguments necessary to start the language server.

  * `name`: (String) This is the name Neovim will assign to the client object.

  * `on_attach`: (Function) A function that will be executed after the language server gets attached to a buffer.

Here is an example that starts the [typescript language server](https://github.com/typescript-language-server/typescript-language-server) on javascript and typescript, but only in a project that package.json in the current directory or any of its parent folders.

```lua
local lsp = require('lsp-zero')

lsp.on_attach(function()
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.new_server({
  name = 'tsserver',
  cmd = {'typescript-language-server', '--stdio'},
  filetypes = {'javascript', 'typescript'},
  root_dir = function()
    return lsp.dir.find_first({'package.json'})
  end
})
```

### `.dir.find_first({list})`

Checks the parent directories and returns the path to the first folder that has a file in `{list}`. This is useful to detect the root directory. 

Note: search will stop once it gets to your "HOME" folder.

`{list}` supports the following properties:

  * path: (String) The path from where it should start looking for the files in `{list}`.

  * buffer: (Boolean) When set to `true` use the path of the current buffer.

```lua
local lsp = require('lsp-zero')

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

require('lspconfig').lua_ls.setup({
  root_dir = function()
    --- project root will be the first directory that has
    --- either .luarc.json or .stylua.toml
    return lsp.dir.find_first({'.luarc.json', '.stylua.toml'})
  end
})

lsp.setup()
```

### `.dir.find_all({list})`

Checks the parent directories and returns the path to the first folder that has all the files in `{list}`.

Note: search will stop once it gets to your "HOME" folder.

`{list}` supports the following properties:

  * path: (String) The path from where it should start looking for the files in `{list}`.

  * buffer: (Boolean) When set to `true` use the path of the current buffer.

```lua
local lsp = require('lsp-zero')

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

require('lspconfig').vuels.setup({
  root_dir = function()
    --- project root will be the directory that has
    --- package.json + vetur config
    return lsp.dir.find_all({'package.json', 'vetur.config.js'})
  end
})

lsp.setup()
```

### `.cmp_action()`

Is a function that returns methods meant to be used as mappings for nvim-cmp.

These are the supported methods:

* `tab_complete`: Enables completion when the cursor is inside a word. If the completion menu is visible it will navigate to the next item in the list. If the line is empty it uses the fallback.

* `select_prev_or_fallback`: If the completion menu is visible navigate to the previous item in the list. Else, uses the fallback.

* `toggle_completion`: If the completion menu is visible it cancels the process. Else, it triggers the completion menu.

* `luasnip_jump_forward`: Go to the next placeholder in the snippet.

* `luasnip_jump_backward`: Go to the previous placeholder in the snippet.

* `luasnip_next`: If completion menu is visible it will navigate to the item in the list. If the cursor can jump to a snippet placeholder, it moves to it. Else, it uses the fallback.

* `luasnip_next_or_expand`: If completion menu is visible it will navigate to the item in the list. If cursor is on top of the trigger of a snippet it'll expand it. If the cursor can jump to a snippet placeholder, it moves to it. Else, it uses the fallback.

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
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
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

### `.omnifunc.setup({opts})`

Configure the behavior of Neovim's completion mechanism. If for some reason you refuse to install nvim-cmp you can use this function to make the built-in completions more user friendly.

`{opts}` supports the following properties:

  * `autocomplete`: Boolean. Default value is `false`. When enabled it triggers the completion menu if the character under the cursor matches `opts.keyword_pattern`. Completions will be disabled when you are recording a macro. Do note, the implementation here is extremely simple, there isn't any kind of optimizations in place. Is literally like pressing `<Ctrl-x><Ctrl-o>` after you insert a character in a word.

  * `tabcomplete`: Boolean. Default value is `false`. When enabled `<Tab>` will trigger the completion menu if the cursor is in the middle of a word. When the completion menu is visible it will navigate to the next item in the menu. If there is a blank character under the cursor it inserts a `Tab` character. `<Shift-Tab>` will navigate to the previous item in the menu, and if the menu is not visible it'll insert a `Tab` character.

  * `trigger`: String. It must be a valid keyboard shortcut. This will be used as a keybinding to trigger the completion menu manually. Actually, it will be able to toggle the completion menu. You'll be able to show and hide the menu with the same keybinding.

  * `use_fallback`: Boolean. Default value is `false`. When enabled lsp-zero will try to complete using the words in the current buffer. And when an LSP server is attached to the buffer, it will replace the fallback completion with the LSP completions.

  * `keyword_pattern`: String. Regex pattern used by the autocomplete implementation. Default value is `"[[:keyword:]]"`.

  * `update_on_delete`: Boolean. Default value is `false`. Turns out Neovim will hide the completion menu when you delete a character, so when you enable this option lsp-zero will trigger the menu again after you press `<backspace>`. This will only happen with LSP completions, the fallback completion updates automatically (again, this is Neovim's default behavior). This option is disabled by default because it requires lsp-zero to bind the backspace key, which may cause conflicts with other plugins.

  * `select_behavior`: String. Default value is `"select"`. Configures what happens when you select an item in the completion menu. When the value is `"insert"` Neovim will insert the text of the item in the buffer. When the value is `"select"` nothing happens, Neovim will only highlight the item in the menu, the text in the buffer will not change.

  * `preselect`: Boolean. Default value is `true`. When enabled the first item in the completion menu will be selected automatically.

  * `verbose`: Boolean. Default value is `false`. When enabled Neovim will show the state of the completion in message area.

  * `mapping`: Table. Defaults to an empty table. With this you can configure the keybinding for common actions.

    * `confirm`: Accept the selected completion item.

    * `abort`: Cancel current completion.

    * `next_item`: Navigate to next item in the completion menu.

    * `prev_item`: Navigate to previous item in the completion menu.

You can configure a basic "tab completion" behavior using these settings.

```lua
local lsp = require('lsp-zero')

lsp.omnifunc.setup({
  tabcomplete = true,
  use_fallback = true,
  update_on_delete = true,
})
```

And here is an example for autocomplete.

```lua
local lsp = require('lsp-zero')

lsp.omnifunc.setup({
  autocomplete = true,
  use_fallback = true,
  update_on_delete = true,
  trigger = '<C-Space>',
})
```

---

### Deprecated functions

The following functions will be remove in the future, whenever I feel forced to create a `v3.x` branch (I have no plans for this yet).

### `.ensure_installed({list})`

If you have support for mason.nvim enabled it will install all the servers in `{list}`. The names of the servers should match the ones listed here: [server_configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations).

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.ensure_installed({
  'tsserver',
  'eslint', 
  'rust_analyzer',
})

lsp.setup()
```

### `.set_preferences({opts})`

This function allows you to override any configuration created by a preset. Now, you can do that directly in the [.preset()](#presetopts) call, so there is no good reason to keep using `.set_preferences`.

### `.setup_nvim_cmp({opts})`

Is used to modify the default settings for nvim-cmp.

`{opts}` supports the following properties:

* `completion`: Configures the behavior of the completion menu. You can find more details about its properties if you start typing the command `:help cmp-config.completion`.

* `sources`: List of configurations for "data sources". See `:help cmp-config.sources` to know more.

* `documentation`: Modifies the look of the documentation window. You can find more details about its properties if you start typing the command `:help cmp-config.window`.

* `preselect`: Sometimes the first item in the completion menu is preselected. Disable this behaviour by setting this to `cmp.PreselectMode.None`.

* `formatting`: Modifies the look of the completion menu. You can find more details about its properties if you start typing the command `:help cmp-config.formatting`.

* `mapping`: Sets the keybindings. See `:help cmp-mapping`.

* `select_behavior`: Configure behavior when navigating between items in the completion menu. It can be set to the values `'insert'` or `'select'`. With the value 'select' nothing happens when you move between items. With the value 'insert' it'll put the text from the selection in the buffer. Is worth mention these values are available as "types" in the `cmp` module: `require('cmp').SelectBehavior`.

What to do instead of using `.setup_nvim_cmp()`?

If you really need to customize nvim-cmp I suggest you use the [minimal](#minimal) preset and setup everything directly using the `cmp` module.

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

### `.defaults.diagnostics({opts})`

Returns the configuration for diagnostics. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

### `.defaults.cmp_sources()`

Returns the list of "sources" used in nvim-cmp.

### `.defaults.cmp_mappings({opts})`

Returns a table with the default keybindings for nvim-cmp. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

### `.defaults.cmp_config({opts})`

Returns the entire configuration table for nvim-cmp. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

### `.defaults.nvim_workspace({opts})`

Returns the neovim specific settings for `lua_ls` language server.

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
  set_lsp_keymaps = {omit = {'gs', 'gl'}},
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
