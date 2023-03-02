# LSP

## Introduction

Language servers are configured and initialized using [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/).

Ever wondered what does lsp-zero does under the hood? Let me tell you.

First it adds some extra "capabilities" to lspconfig's defaults. This capabilities come from [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp). They tell the language server what features [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) adds to the editor.

Then it creates an autocommand on the event `LspAttach`. This autocommand will be triggered every time a language server is attached to a buffer. Is where all keybindings and commands are created.

Finally it calls the `.setup()` of each language server.

The code is a little bit like this.

```lua
local lspconfig = require('lspconfig')
local lsp_defaults = lspconfig.util.default_config

lsp_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lsp_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', {buffer = true})
    -- More keybindings and commands....
  end
})

lspconfig.tsserver.setup({})
lspconfig.eslint.setup({})
```

## Commands

* `LspZeroFormat`: Formats the current buffer or range. If the "bang" is provided formatting will be synchronous (ex: LspZeroFormat!). See [:help vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()).

* `LspZeroWorkspaceRemove`: Remove the folder at path from the workspace folders. See [:help vim.lsp.buf.remove_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.remove_workspace_folder()).

* `LspZeroWorkspaceAdd`: Add the folder at path to the workspace folders. See [:help vim.lsp.buf.add_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.add_workspace_folder()).

* `LspZeroWorkspaceList`: List workspace folders. See [:help vim.lsp.buf.list_workspace_folders()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.list_workspace_folders()).

* `LspZeroSetupServers`: It takes a space separated list of servers and configures them.

## Creating new keybindings

Just like the default keybindings the idea here is to create them only when a language server is active in a buffer. For this use the [.on_attach()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#on_attachcallback) function, and then use neovim's built-in functions create the keybindings.

Here is an example the replaces the default keybinding `gr` with a [telescope](https://github.com/nvim-telescope/telescope.nvim) command.

```lua
local lsp = require('lsp-zero').preset({name = 'minimal'})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})

  vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', {buffer = true})
end)

lsp.setup()
```

## Disable keybindings

To disable all keybindings just delete the call to [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#default_keymapsopts).

If you want lsp-zero to skip only a few keys you can add the `omit` property to the [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#default_keymapsopts) call. Say you want to keep the default behavior of `K` and `gs`, you would do this.

```lua
lsp.default_keymaps({
  buffer = bufnr,
  omit = {'gs', 'K'},
})
```

## Install new language servers

### Manual install

You can find the instruction for each language server in lspconfig's documentation: [server_configurations.md](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

### Via command

If you have [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim) installed you can use the command `:LspInstall` to install a language server. If you call this command while you are in a file it'll suggest a list of language server based on the type of that file.

### Automatic installs

If you have [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim) installed you can use the function [.ensure_installed()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#ensure_installedlist) to list the language servers you want to install with `mason.nvim`.

```lua
local lsp = require('lsp-zero').preset({name = 'minimal'})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.ensure_installed({
  -- Replace these with whatever servers you want to install
  'tsserver',
  'eslint',
  'rust_analyzer'
})

lsp.setup()
```

Keep in mind the names of the servers must be in [this list](https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers).

## Configure language servers

To pass arguments to a language server you can use the lspconfig directly. Just make sure you call lspconfig after the require of lsp-zero.

```lua
local lsp = require('lsp-zero').preset({name = 'minimal'})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

require('lspconfig').eslint.setup({
  single_file_support = false,
  on_attach = function(client, bufnr)
    print('hello eslint')
  end
})

lsp.setup()
```

Keep in mind that plugins like [rust-tools](https://github.com/simrat39/rust-tools.nvim) and [typescript.nvim](https://github.com/jose-elias-alvarez/typescript.nvim) use lspconfig under the hood, you must configure them after lsp-zero.

For backwards compatibility with the `v1.x` branch the [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#configurename-opts) function is still available. So this is still valid.

```lua
local lsp = require('lsp-zero').preset({name = 'minimal'})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.configure('eslint', {
  single_file_support = false,
  on_attach = function(client, bufnr)
    print('hello eslint')
  end
})

lsp.setup()
```

The name of the server can be anything [lspconfig supports](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) and the options are same you would pass to lspconfig's setup function.

## Disable a language server

Use the function [.skip_server_setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#skip_server_setupname) to tell lsp-zero to ignore a particular set of language servers.

```lua
local lsp = require('lsp-zero').preset({name = 'minimal'})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.skip_server_setup({'eslint'})

lsp.setup()
```

## Diagnostics

That's the name neovim uses for error messages, warnings, hints, etc. lsp-zero only does two things to diagnostics: add borders to floating windows and enable "severity sort". All of that can be disable from the [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#presetopts) call.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  float_border = 'none',
  configure_diagnostics = false,
})
```

If you want to disable the "virtual text" you'll need to use the function [vim.diagnostic.config()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.config()).

```lua
vim.diagnostic.config({
  virtual_text = true,
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
require('mason').setup({
  ui = {
    border = 'rounded'
  }
})

local lsp = require('lsp-zero').preset({name = 'minimal'})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()
```

### Opt-out of mason.nvim

Really all you need is to do is uninstall `mason.nvim` and `mason-lspconfig`. Or call [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#lua-api#presetopts) and use modify these settings:

```lua
setup_servers_on_start = false
call_servers = 'global'
```

Then you need to specify which language server you want to setup, for this use [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#lua-api#setup_serverslist) or [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v2/doc/md/api-reference.md#lua-api#configurename-opts).

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

