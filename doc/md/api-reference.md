# API reference

## Commands

* `LspZeroFormat`: Formats the current buffer or range. If the "bang" is provided formatting will be synchronous (ex: LspZeroFormat!). See [:help vim.lsp.buf.formatting()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.formatting()), [:help vim.lsp.buf.range_formatting()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.range_formatting()), [:help vim.lsp.buf.formatting_sync()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.formatting_sync()).

* `LspZeroWorkspaceRemove`: Remove the folder at path from the workspace folders. See [:help vim.lsp.buf.remove_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.remove_workspace_folder()).

* `LspZeroWorkspaceAdd`: Add the folder at path to the workspace folders. See [:help vim.lsp.buf.add_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.add_workspace_folder()).

* `LspZeroWorkspaceList`: List workspace folders. See [:help vim.lsp.buf.list_workspace_folders()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.list_workspace_folders()).

* `LspZeroSetupServers`: It takes a space separated list of servers and configures them. It calls the function [.use()](#useserver-opts) under the hood. If the `bang` is provided the root dir of the language server will be the same as neovim. It is recommended that you use only if you decide to handle server setup manually.

## Lua api

### `.preset({opts})`

It creates a combination of settings safe to use for specific cases.

`{opts}` can be a string with one of these values:

* minimal
* recommended
* lsp-compe
* lsp-only
* manual-setup
* per-project
* system-lsp


If you want to override a setting from a preset use a lua table. Like this.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = {preserve_mappings = true, omit = {'K', 'gl'}},
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})
```

### `.set_preferences({opts})`

When using a preset is better to use [.preset()](#presetopts) to configure these settings.

It gives the user control over the options available in the plugin.

* `suggest_lsp_servers`: enables the suggestions of lsp servers when you enter a filetype for the first time.

* `setup_servers_on_start`: when set to `true` all installed servers will be initialized on startup. When is set to the string `"per-project"` only the servers listed with the function [.use()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#useserver-opts) will be initialized. If the value is `false` servers will be initialized when you call [.configure()](#configurename-opts) or [.setup_servers()](#setup_serverslist).

* `set_lsp_keymaps`: add keybindings to a buffer with a language server attached. You can configure the behavior using the options `preserve_mappings` and `omit`. If you enable `preserve_mappings` lsp-zero will not override your existing keybindings. Using `omit` you can specify a list of keybindings you don't want to override.

* `configure_diagnostics`: uses the built-in function [vim.diagnostic.config](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.config()) to setup the way error messages are shown in the buffer. It also creates keymaps to navigate between the location of these errors.

* `cmp_capabilities`: tells the language servers what capabilities nvim-cmp supports.

* `manage_nvim_cmp`: use the default setup for nvim-cmp. It configures keybindings and completion sources for nvim-cmp.

* `manage_luasnip`: use the default setup for luasnip.

* `call_servers`: if set to `'local'` it'll try to initialize servers that where installed using mason.nvim. If set to `'global'` all language servers you list using [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#configurename-opts) or [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#set_server_configopts) are assumed to be installed (a warning message will show up if they aren't).

* `sign_icons`: they are shown in the "gutter" on the line diagnostics messages are located.

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
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

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

Used to configure the servers specified in `{list}`. If you provide the `opts` property it will send those options to all language servers. Under the hood it calls [.configure()](#configurename-opts) for each server on `{list}`.

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
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.skip_server_setup({'eslint', 'angularls'})

lsp.setup()
```

### `.on_attach({callback})`

Execute `{callback}` function every time a server is attached to a buffer.

Let's say you want to disable all the default keybindings for lsp actions and diagnostics, and then declare your own.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = false,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}
  local bind = vim.keymap.set

  bind('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  -- more code  ...
end)

lsp.setup()
```

### `.default_keymaps({opts})`

Create [LSP keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#default-keybindings) in the current buffer.

`{opts}` supports the same properties as the setting `set_lsp_keymaps` and adds the following:

  * buffer: (Number). Needs to be the "id" of an open buffer. The number `0` means the current buffer.

### `.buffer_commands()`

Create [LSP commands](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#commands) in the current buffer.

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

If what you want is to extend the configuration of nvim-cmp, I suggest you change the preset to `lsp-compe`. There is an [example configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/advance-usage.md#the-current-api-is-not-enough) in the Advance usage page.

### `.use({server}, {opts})`

For when you want full control of the servers you want to use in particular project. It is meant to be called in project local config.

Ideally, you would setup some default values for your servers in your neovim config using [.setup_servers()](#set_server_configopts) or [.configure()](#configurename-opts). Example.

```lua
-- init.lua

local lsp = require('lsp-zero').preset({
  name = 'per-project',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
})

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

Options from [.configure()](#configurename-opts) will be merged with the ones on `.use()` and the server will be initialized.

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
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

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


### `.new_server({opts})`

lsp-zero will execute a user provided function to detect the root directory of the project when Neovim assigns the file type for a buffer. If the root directory is detected the LSP server will be attached to the file.

This function does not depend on `lspconfig`, it's a wrapper around a Neovim function called [vim.lsp.start_client()](https://neovim.io/doc/user/lsp.html#vim.lsp.start_client()).

`{opts}` supports every property `vim.lsp.start_client` supports with a few changes:

  * `filestypes`: Can be list filetype names. This can be any pattern the `FileType` autocommand accepts.

  * `root_dir`: Can be a function, it'll be executed after Neovim assigns the file type for a buffer. If it returns a string that will be considered the root directory for the project.

Other important properties are:

  * `cmd`: (Table) A lua table with the arguments necessary to start the language server.

  * `name`: (String) This is the name Neovim will assign to the client object.

  * `on_attach`: (Function) A function that will be executed after the language server gets attached to a buffer.

Here is an example that starts the [typescript language server](https://github.com/typescript-language-server/typescript-language-server) on javascript and typescript, but only in a project that package.json in the current directory or any of its parent folders.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.new_server({
  name = 'tsserver',
  cmd = {'typescript-language-server', '--stdio'},
  filetypes = {'javascript', 'typescript'},
  root_dir = function()
    return lsp.dir.find_first({'package.json'})
  end
})

lsp.setup()
```

### `.format_on_save({opts})`

Setup autoformat on save. This will to allow you to associate a language server with a list of filetypes.

Keep in mind it's only meant to allow one LSP server per filetype, this is so the formatting is consistent.

`{opts}` supports the following properties:

  * servers: (Table) Key/value pair list. On the left hand side you must specify the name of a language server. On the right hand side you must provide a list of filetypes, this can be any pattern supported by the `FileType` autocommand.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.format_on_save({
  servers = {
    ['lua_ls'] = {'lua'},
    ['rust_analyzer'] = {'rust'},
  }
})

lsp.setup()
```

### `.buffer_autoformat({client}, {bufnr})`

Format the current buffer using the active language servers.

If {client} argument is provided it will only use the LSP server associated with that client.

  * client: (Table, Optional) if provided it must be a lua table with a `name` property or an instance of [vim.lsp.client](https://neovim.io/doc/user/lsp.html#vim.lsp.client).

  * bufnr: (Number, Optional) if provided it must be the id of an open buffer.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.on_attach(function(client, bufnr)
  lsp.buffer_autoformat()
end)

lsp.setup()
```

### `.dir.find_first({list})`

Checks the parent directories and returns the path to the first folder that has a file in `{list}`. This is useful to detect the root directory. 

Note: search will stop once it gets to your "HOME" folder.

`{list}` supports the following properties:

  * path: (String) The path from where it should start looking for the files in `{list}`.

  * buffer: (Boolean) When set to `true` use the path of the current buffer.

  * stop: (String) Defaults to the HOME directory. Stop the search on this directory.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.configure('tsserver' {
  root_dir = function()
    --- project root will be the first directory that has
    --- either package.json or node_modules.
    return lsp.dir.find_first({'package.json', 'node_modules'})
  end
})

lsp.setup()
```

### `.dir.find_all({list})`

Checks the parent directories and returns the path to the first folder that has all the files in `{list}`.

Note: by default the search will stop once it gets to your "HOME" folder.

`{list}` supports the following properties:

  * path: (String) The path from where it should start looking for the files in `{list}`.

  * buffer: (Boolean) When set to `true` use the path of the current buffer.

  * stop: (String) Defaults to the HOME directory. Stop the search on this directory.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.configure('vuels' {
  root_dir = function()
    --- project root will be the directory that has
    --- package.json + vetur config
    return lsp.dir.find_all({'package.json', 'vetur.config.js'})
  end
})

lsp.setup()
```

### `.defaults.diagnostics({opts})`

Returns the configuration for diagnostics. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

### `.defaults.cmp_sources()`

Returns the list of "sources" used in `nvim-cmp`.

### `.defaults.cmp_mappings({opts})`

Returns a table with the default keybindings for `nvim-cmp`. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

Here is an example that disables completion with tab and replace it with `Ctrl + space`.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

local cmp = require('cmp')

lsp.setup_nvim_cmp({
  mapping = lsp.defaults.cmp_mappings({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),

    -- disable completion with tab
    ['<Tab>'] = vim.NIL,
    ['<S-Tab>'] = vim.NIL,

    -- disable confirm with Enter key
    ['<CR>'] = vim.NIL,
  })
})

lsp.setup()
```

### `.defaults.cmp_config({opts})`

Returns the entire configuration table for nvim-cmp. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

In this example we set `manage_nvim_cmp` to `false` then seutp nvim-cmp directly.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = false,
  suggest_lsp_servers = false,
})

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

Returns the neovim specific settings for `lua_ls` language server.

### `.extend_lspconfig({opts})`

The purpose of this function is to allow you to interact with `lspconfig` directly and still enjoy all the keybindings and commands lsp-zero offers.

It "extends" the default configuration in `lspconfig`, adding two options to it: `capabilities` and `on_attach`.

Note: don't use it along side [.setup()](#setup). Its meant to be independent of any settings provided by presets.

This is the intended usage:

```lua
require('mason').setup()
require('mason-lspconfig').setup()
require('lsp-zero').extend_lspconfig()

require('lspconfig').tsserver.setup({})
```

Notice here it can coexists with other plugins. Allowing you to have full control of your configuration.

`{opts}` table supports the following properties:

* `set_lsp_keymaps`: When set to `true` (the default) it creates [keybindings linked to lsp actions](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#default-keybindings). You can also provide a list of keys you want to omit, lsp-zero will not bind it to anything (see example below). When set to `false` all keybindings are disabled.

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

