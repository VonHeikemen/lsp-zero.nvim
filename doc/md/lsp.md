# LSP

## Introduction

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

## Default keybindings

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

### Disable default keybindings

Call the function [.set_preferences()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#set_preferencesopts) right after you set the preset, then change the option `set_lsp_keymaps`.

To disable all default keybindings change `set_lsp_keymaps` to `false`.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.set_preferences({
  set_lsp_keymaps = false,
})

lsp.setup()
```

If you just want to disable a few of them use the `omit` option.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.set_preferences({
  set_lsp_keymaps = {omit = {'<F2>', 'gl'}}
})

lsp.setup()
```

### Create new keybindings

Just like the default keybindings the idea here is to create them only when a language server is active in a buffer. For this use the [.on_attach()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#on_attachcallback) function, and then use neovim's built-in functions create the keybindings.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr}
  local bind = vim.keymap.set

  bind('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  -- more keybindings...
end)

lsp.setup()
```

## Commands

* `LspZeroFormat`: Formats the current buffer or range. If the "bang" is provided formatting will be synchronous (ex: LspZeroFormat!). See [:help vim.lsp.buf.formatting()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.formatting()), [:help vim.lsp.buf.range_formatting()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.range_formatting()), [:help vim.lsp.buf.formatting_sync()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.formatting_sync()).

* `LspZeroWorkspaceRemove`: Remove the folder at path from the workspace folders. See [:help vim.lsp.buf.remove_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.remove_workspace_folder()).

* `LspZeroWorkspaceAdd`: Add the folder at path to the workspace folders. See [:help vim.lsp.buf.add_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.add_workspace_folder()).

* `LspZeroWorkspaceList`: List workspace folders. See [:help vim.lsp.buf.list_workspace_folders()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.list_workspace_folders()).

## Configure language servers

To pass arguments to language servers use the function [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#configurename-opts). You'll need to call it before [.setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#setup). 

Here is an example that adds a few options to `tsserver`.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

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

lsp.setup()
```

This ".configure()" function uses [lspconfig](https://github.com/neovim/nvim-lspconfig/) under the hood. So the call to `.configure()` is very close to this.

```lua
--- **Do not** use the module `lspconfig` after using lsp-zero.

require('lspconfig')['tsserver'].setup({
  on_attach = function(client, bufnr)
    print('hello tsserver')
  end,
  settings = {
    completions = {
      completeFunctionCalls = true
    }
  }
})
```

I'm telling you this because I want you to know you can "translate" any config that uses `lspconfig` to lsp-zero.

### Disable a language server

Use the function [.skip_server_setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#skip_server_setupname) to tell lsp-zero to ignore a particular set of language servers.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.skip_server_setup({'eslint'})

lsp.setup()
```

## Diagnostics

### Default settings

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

### Configure diagnostics

If you want to override some settings lsp-zero provides make sure you call `vim.diagnostic.config` after lsp-zero's setup.

Here is an example that restores neovim's default configuration for diagnostics.

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

> With mason.nvim you can also install formatters and debuggers, but lsp-zero will only configure LSP servers.

To install a server manually use the command `LspInstall` with the name of the server you want to install. If you don't provide a name `mason-lspconfig.nvim` will try to suggest a language server based on the filetype of the current buffer.

To check for updates on the language servers use the command `Mason`. A floating window will open showing you all the tools mason.nvim can install. You can filter the packages by categories for example, language servers are in the second category, so if you press the number `2` it'll show only the language servers. The packages you have installed will appear at the top. If there is any update available the item will display a message. Navigate to that item and press `u` to install the update.

To uninstall a package use the command `Mason`. Navigate to the item you want to delete and press `X`.

To know more about the available bindings inside the floating window of Mason press `g?`.

If you need to customize mason.nvim make sure you do it before calling the lsp-zero module.

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

Really all you need is to do is uninstall `mason.nvim` and `mason-lspconfig`. But the correct way to opt-out if you are using the [recommended](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/getting-started.md#recommended) preset is to change it to [system-lsp](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/getting-started.md#system-lsp). Or call [.set_preferences()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#lua-api#set_preferencesopts) and use these settings:

```lua
suggest_lsp_servers = false
setup_servers_on_start = false
call_servers = 'global'
```

Then you need to specify which language server you want to setup, for this use [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#lua-api#setup_serverslist) or [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#lua-api#configurename-opts).

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

Really. Out of all the features this plugin offers there is a good chance the only thing you want is the automatic setup of LSP servers. Let me tell you how to configure that.

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

In this example I have automatic install of servers using the option `ensure_installed` in mason-lspconfig. You can delete that list of servers and add your own.

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

