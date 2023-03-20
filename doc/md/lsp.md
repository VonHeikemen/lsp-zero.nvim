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

Call the function [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#presetopts) then change the option `set_lsp_keymaps`.

To disable all default keybindings change `set_lsp_keymaps` to `false`.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = false,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup()
```

If you just want to disable a few of them use the `omit` option.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = {omit = {'<F2>', 'gl'}},
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup()
```

### Create new keybindings

Just like the default keybindings the idea here is to create them only when a language server is active in a buffer. For this use the [.on_attach()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#on_attachcallback) function, and then use neovim's built-in functions create the keybindings.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

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

## Install new language servers

If you have `mason.nvim` available then you can use the command `:LspInstall` to get a list of language servers available for the current file type. You'll also be able to use the function [.ensure_installed()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#ensure_installedlist) to install a list of servers automatically.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.ensure_installed({
  'tsserver',
  'rust_analyzer',
})

lsp.setup()
```

If you don't have `mason.nvim` you'll need to install each server manually in your system. You can find the install instructions for the supported LSP servers here: [server configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

## Configure language servers

To pass arguments to language servers use the function [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#configurename-opts). You'll need to call it before [.setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#setup).

You can find the list of servers here: [server configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

Here is an example that adds a few options to `tsserver`.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

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
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.skip_server_setup({'eslint'})

lsp.setup()
```

## Custom servers

There are two ways you can use a server that is not supported by `lspconfig`:

### Add the configuration to lspconfig (recommended)

You can add the configuration to the module `lspconfig.configs` and then use lsp-zero.

You'll need to provide the command to start the LSP server, a list of filetypes where you want to attach the LSP server, and a function that detects the "root directory" of the project.

```lua
require('lspconfig.configs').my_new_lsp = {
  default_config = {
    name = 'my-new-lsp',
    cmd = {'my-new-lsp'},
    filetypes = {'my-filetype'},
    root_dir = require('lspconfig.util').root_pattern({'some-config-file'})
  }
}

local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.configure('my_new_lsp', {force_setup = true})

lsp.setup()
```

### Use the function [.new_server()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#new_serveropts)

If you don't need a "robust" solution you can use the function `.new_server()`. This function is just a wrapper that calls [vim.lsp.start_client()](https://neovim.io/doc/user/lsp.html#vim.lsp.start_client()) in a `FileType` autocommand.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.new_server({
  name = 'my-new-lsp',
  cmd = {'my-new-lsp'},
  filetypes = {'my-filetype'},
  root_dir = function()
    return lsp.dir.find_first({'some-config-file'}) 
  end
})

lsp.setup()
```

## Enable Format on save

You can use the function [.format_on_save()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#format_on_saveopts) to associate a language server with a list of filetypes.

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
root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")
```

`root_pattern` is a function inside `lspconfig`, it tries to look for one of those files/folders in the current folder or any of the parent folders.

Make sure you have at least one of those files in your project.

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

### Testing a server in isolation

And by that I mean without the lsp-zero setup.

First thing you'll need to do is delete or "comment out" the configuration you have for lsp-zero. Then do everything manually. Call the setup function for `mason` and `mason-lspconfig`. After that, use `lspconfig` to configure the language server you want to test. If you use lsp-zero's keybindings or commands, you can add them in the `.on_attach` function.

Here is an example configuration for `tsserver`.

```lua
local lsp_zero = require('lsp-zero')
local lspconfig = require('lspconfig')

require('mason').setup()
require('mason-lspconfig').setup()

lspconfig.tsserver.setup({
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  on_attach = function(client, bufnr)
    lsp_zero.default_keymaps({buffer = bufnr})
    lsp_zero.buffer_commands()
  end
})
```

If the issue you have persists even without lsp-zero and you want to ask for help in `stackoverflow` or any other forum, I suggest you present a minimal config like this one. You'll increase the chances of getting support from the community (because sadly there aren't any lsp-zero experts out there).

If you need a minimal config for nvim-cmp, use this.

```lua
local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
  })
})
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
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

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

local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup()
```

### Opt-out of mason.nvim

Really all you need is to do is uninstall `mason.nvim` and `mason-lspconfig`. Or call [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#lua-api#presetopts) and use these settings:

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

