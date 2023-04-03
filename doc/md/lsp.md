# LSP

## Introduction

Language servers are configured and initialized using [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/).

Ever wondered what does lsp-zero does under the hood? Let me tell you.

First it adds data to an option called `capabilities` in lspconfig's defaults. This new data comes from [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp). They tell the language server what features [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) adds to the editor.

Then it creates an autocommand on the event `LspAttach`. This autocommand will be triggered every time a language server is attached to a buffer. Is where all keybindings and commands are created.

Finally it calls the `.setup()` of each language server.

If you were to do it all by yourself, the code would look like this.

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

* `LspZeroFormat {server} timeout={timeout}`: Formats the current buffer or range. Under the hood lsp-zero is using the function `vim.lsp.buf.format()`. If the "bang" is provided formatting will be asynchronous (ex: `LspZeroFormat!`). If you provide the name of a language server as a first argument it will try to format only using that server. Otherwise, it will use every active language server with formatting capabilities. With the `timeout` parameter you can configure the time in milliseconds to wait for the response of the formatting requests.

* `LspZeroWorkspaceRemove`: Remove the folder at path from the workspace folders. See [:help vim.lsp.buf.remove_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.remove_workspace_folder()).

* `LspZeroWorkspaceAdd`: Add the folder at path to the workspace folders. See [:help vim.lsp.buf.add_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.add_workspace_folder()).

* `LspZeroWorkspaceList`: List workspace folders. See [:help vim.lsp.buf.list_workspace_folders()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.list_workspace_folders()).

* `LspZeroSetupServers [{servers}]`: It takes a space separated list of servers and configures them.

## Creating new keybindings

Just like the default keybindings the idea here is to create them only when a language server is active in a buffer. For this use the [.on_attach()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#on_attachcallback) function, and then use neovim's built-in functions create the keybindings.

Here is an example the replaces the default keybinding `gr` with a [telescope](https://github.com/nvim-telescope/telescope.nvim) command.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})

  vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', {buffer = true})
end)

lsp.setup()
```

## Disable keybindings

To disable all keybindings just delete the call to [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#default_keymapsopts).

If you want lsp-zero to skip only a few keys you can add the `omit` property to the [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#default_keymapsopts) call. Say you want to keep the default behavior of `K` and `gs`, you would do this.

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

If you have [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim) installed you can use the function [.ensure_installed()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#ensure_installedlist) to list the language servers you want to install with `mason.nvim`.

```lua
local lsp = require('lsp-zero').preset({})

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
local lsp = require('lsp-zero').preset({})

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

For backwards compatibility with the `v1.x` branch the [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#configurename-opts) function is still available. So this is still valid.

```lua
local lsp = require('lsp-zero').preset({})

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

Use the function [.skip_server_setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#skip_server_setupname) to tell lsp-zero to ignore a particular set of language servers.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.skip_server_setup({'eslint'})

lsp.setup()
```

## Custom servers

There are two ways you can use a server that is not supported by `lspconfig`:

### Add the configuration to lspconfig (recommended)

You can add the configuration to the module `lspconfig.configs` then you can call the `.setup` function.

You'll need to provide the command to start the LSP server, a list of filetypes where you want to attach the LSP server, and a function that detects the "root directory" of the project.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()

require('lspconfig.configs').my_new_lsp = {
  default_config = {
    name = 'my-new-lsp',
    cmd = {'my-new-lsp'},
    filetypes = {'my-filetype'},
    root_dir = require('lspconfig.util').root_pattern({'some-config-file'})
  }
}

require('lspconfig').my_new_lsp.setup({})
```

### Use the function [.new_server()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#new_serveropts)

If you don't need a "robust" solution you can use the function `.new_server()`. This function is just a thin wrapper that calls [vim.lsp.start()](https://neovim.io/doc/user/lsp.html#vim.lsp.start()) in a `FileType` autocommand.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()

lsp.new_server({
  name = 'my-new-lsp',
  cmd = {'my-new-lsp'},
  filetypes = {'my-filetype'},
  root_dir = function()
    return lsp.dir.find_first({'some-config-file'}) 
  end
})
```

## Enable Format on save

You can choose one of these methods.

### Explicit setup

If you want to control exactly what language server is used to format a file call the function [.format_on_save()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#format_on_saveopts), this will allow you to associate a language server with a list of filetypes.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.format_on_save({
  servers = {
    ['lua_ls'] = {'lua'},
    ['rust_analyzer'] = {'rust'},
  }
})

lsp.setup()
```

### Always use the active servers

If you only ever have **one** language server attached in each file and you are happy with all of them, you can call the function [.buffer_autoformat()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#buffer_autoformatclient-bufnr) in the [.on_attach](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#on_attachcallback) hook.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
  lsp.buffer_autoformat()
end)

lsp.setup()
```

If you have multiple servers active in one file it'll try to format using all of them, and I can't guarantee the order.

You could be more specific if you give the name of a server to [.buffer_autoformat()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#buffer_autoformatclient-bufnr).

```lua
lsp.buffer_autoformat({name = 'lua_ls'})
```

## Format buffer using a keybinding

### Using built-in functions

You'll want to bind the function [vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()) to a keymap.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})

  vim.keymap.set({'n', 'x'}, 'gq', function()
    vim.lsp.buf.format({async = false, timeout_ms = 10000})
  end)
end)

lsp.setup()
```

With this the keyboard shortcut `gq` will be able to format the current buffer using **all** active servers with formatting capabilities.

If you want to allow only a list of servers, use the `filter` option.

```lua
local lsp = require('lsp-zero').preset({})

local function allow_format(servers)
  return function(client) return vim.tbl_contains(servers, client.name) end
end

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
  local opts = {buffer = bufnr}

  vim.keymap.set({'n', 'x'}, 'gq', function()
    vim.lsp.buf.format({
      async = false,
      timeout_ms = 10000,
      filter = allow_format({'lua_ls', 'rust_analyzer'})
    })
  end, opts)
end)

lsp.setup()
```

Using this `allow_format` function you can specify the language servers that you want to use.

### Ensure only one LSP server per filetype

If you want to control exactly what language server can format, use the function [.format_mapping()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#format_mappingkey-opts). It will allow you to associate a list of filetypes to a particular language server.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.format_mapping('gq', {
  servers = {
    ['lua_ls'] = {'lua'},
    ['rust_analyzer'] = {'rust'},
  }
})

lsp.setup()
```

## Troubleshooting

### Automatic setup failed

To figure out what happened use the function `require('lsp-zero.check').run()` in command mode, pass a string with the name of the language server.

Here is an example with `lua_ls`.

```lua
:lua require('lsp-zero.check').run('lua_ls')
```

> The name of the language server must match with one in this list: [server_configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations).

If the language server is not being configured you'll get a message like this.

```
LSP server: lua_ls
- was not installed with mason.nvim
- hasn't been configured with lspconfig
```

This means `mason.nvim` doesn't have the server listed as "available" and that's why the automatic setup failed. Try re-install with the command `:LspInstall`.

When everything is fine the report should be this.

```
LSP server: lua_ls
+ was installed with mason.nvim
+ was configured using lspconfig
+ "lua-language-server" is executable
```

If it says `- "lua-language-server" was not found` it means Neovim could not find the executable in the "PATH".

You can inspect your PATH using this command.

```lua
:lua vim.tbl_map(print, vim.split(vim.env.PATH, ':'))
```

> Note: if you use windows replace ':' with ';' in the second argument of `vim.split`. 

The executable for your language server should be in one of those folders. Make sure it is present and the file itself is executable.

### Root directory not found

You used the command `:LspInfo` and it showed `root directory: Not found.` This means [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/) couldn't figure out what is the "root" folder of your project. In this case you should go to `lspconfig`'s github repo and browse the [server_configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) file, look for the language server then search for `root_dir`, it'll have something like this.

```lua
root_pattern("somefile.json", ".somefile" , ".git")
```

`root_pattern` is a function inside `lspconfig`, it tries to look for one of those files/folders in the current folder or any of the parent folders. Make sure you have at least one of the files/folders listed in the arguments of the function.

Now, sometimes the documentation in lspconfig just says `see source file`. This means you need to go the source code to figure out what lspconfig looks for. You need to go to the [server config folder](https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/server_configurations), click in the file for the language server, look for the `root_dir` property that is inside a "lua table" called `default_config`.

### Inspect server settings

Let say that you added some "settings" to a server... something like this.

```lua
lsp.configure('tsserver', {
  settings = {
    completions = {
      completeFunctionCalls = true
    }
  }
})
```

Notice here that we have a property called `settings`, and you want to know if lsp-zero did send your config to the active language server. Use the function `require('lsp-zero.check').inspect_settings()` in command mode, pass a string with the name of the language server.

```lua
:lua require('lsp-zero.check').inspect_settings('tsserver')
```

If everything went well you should get every default config lspconfig added plus your own.

If this didn't showed your settings, make sure you don't call `lspconfig` in another part of your neovim config. lspconfig can override everything lsp-zero does.

### Inspect the entire server config

Use the function `require('lsp-zero.check').inspect_server_config()` in command mode, pass a string with the name of the language server.

Here is an example.

```lua
:lua require('lsp-zero.check').inspect_server_config('tsserver')
```

> The name of the language server must match with one in this list: [server_configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations).

## Diagnostics

That's the name neovim uses for error messages, warnings, hints, etc. lsp-zero only does two things to diagnostics: add borders to floating windows and enable "severity sort". All of that can be disable from the [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#presetopts) call.

```lua
local lsp = require('lsp-zero').preset({
  float_border = 'none',
  configure_diagnostics = false,
})
```

If you want to disable the "virtual text" you'll need to use the function [vim.diagnostic.config()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.config()).

```lua
vim.diagnostic.config({
  virtual_text = false,
})
```

## Use icons in the sign column

If you don't know, the "sign column" is a space in the gutter next to the line numbers. When there is a warning or an error in a line Neovim will show you a letter like `W` or `E`. Well, you can turn that into icons if you wanted to, using the function [.set_sign_icons](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#set_sign_iconsopts). 

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

local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()
```

### Opt-out of mason.nvim

Really all you need is to do is uninstall `mason.nvim` and `mason-lspconfig`. Or call [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#lua-api#presetopts) and use modify these settings:

```lua
setup_servers_on_start = false
call_servers = 'global'
```

Then you need to specify which language server you want to setup, for this use [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#lua-api#setup_serverslist) or [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#lua-api#configurename-opts).

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

