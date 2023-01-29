# API reference

## Commands

* `LspZeroFormat`: Formats the current buffer or range. If the "bang" is provided formatting will be synchronous (ex: LspZeroFormat!). See [:help vim.lsp.buf.formatting()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.formatting()), [:help vim.lsp.buf.range_formatting()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.range_formatting()), [:help vim.lsp.buf.formatting_sync()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.formatting_sync()).

* `LspZeroWorkspaceRemove`: Remove the folder at path from the workspace folders. See [:help vim.lsp.buf.remove_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.remove_workspace_folder()).

* `LspZeroWorkspaceAdd`: Add the folder at path to the workspace folders. See [:help vim.lsp.buf.add_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.add_workspace_folder()).

* `LspZeroWorkspaceList`: List workspace folders. See [:help vim.lsp.buf.list_workspace_folders()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.list_workspace_folders()).

* `LspZeroSetupServers`: It takes a space separated list of servers and configures them. It calls the function [.use()](#useserver-opts) under the hood. If the `bang` is provided the root dir of the language server will be the same as neovim. It is recommended that you use only if you decide to handle server setup manually.

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

If what you want is to extend the configuration of nvim-cmp, I suggest you change the preset to `lsp-compe`. There is an [example configuration](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/advance-usage.md#the-current-api-is-not-enough) in the Advance usage page.

### `.use({server}, {opts})`

For when you want full control of the servers you want to use in particular project. It is meant to be called in project local config.

Ideally, you would setup some default values for your servers in your neovim config using [.setup_servers()](#set_server_configopts) or [.configure()](#configurename-opts). Example.

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

* `set_lsp_keymaps`: When set to `true` (the default) it creates [keybindings linked to lsp actions](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/lsp.md#default-keybindings). You can also provide a list of keys you want to omit, lsp-zero will not bind it to anything (see example below). When set to `false` all keybindings are disabled.

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

