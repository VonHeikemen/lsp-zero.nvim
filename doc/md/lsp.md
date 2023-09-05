# LSP

## How does it work?

Language servers are configured and initialized using [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/).

lsp-zero first adds data to an option called `capabilities` in lspconfig's defaults. This new data comes from [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp). It tells the language server what features [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) adds to the editor.

Then it creates an autocommand on the event `LspAttach`. This autocommand will be triggered every time a language server is attached to a buffer. This is where all keybindings and commands are created.

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
    local opts = {buffer = event.buf}

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

    vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
    vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
    vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts) 
  end
})

lspconfig.tsserver.setup({})
lspconfig.rust_analyzer.setup({})
```

## Commands

* `LspZeroFormat {server} timeout={timeout}`: Formats the current buffer or range. Under the hood lsp-zero is using the function `vim.lsp.buf.format()`. If the "bang" is provided formatting will be asynchronous (ex: `LspZeroFormat!`). If you provide the name of a language server as a first argument it will try to format only using that server. Otherwise, it will use every active language server with formatting capabilities. With the `timeout` parameter you can configure the time in milliseconds to wait for the response of the formatting requests.

* `LspZeroWorkspaceRemove`: Remove the folder at path from the workspace folders. See [:help vim.lsp.buf.remove_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.remove_workspace_folder()).

* `LspZeroWorkspaceAdd`: Add the folder at path to the workspace folders. See [:help vim.lsp.buf.add_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.add_workspace_folder()).

* `LspZeroWorkspaceList`: List workspace folders. See [:help vim.lsp.buf.list_workspace_folders()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.list_workspace_folders()).

* `LspZeroSetupServers [{servers}]`: It takes a space separated list of servers and configures them.

## Creating new keybindings

Just like the default keybindings the idea here is to create them only when a language server is active in a buffer. For this use the [.on_attach()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#on_attachcallback) function, and then use neovim's built-in functions create the keybindings.

Here is an example that replaces the default keybinding `gr` with a [telescope](https://github.com/nvim-telescope/telescope.nvim) command.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})

  vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', {buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

## Disable keybindings

To disable all keybindings just delete the call to [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#default_keymapsopts).

If you want lsp-zero to skip only a few keys you can add the `exclude` property to the [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#default_keymapsopts) call. Say you want to keep the default behavior of `K` and `gl`, you would do this.

```lua
lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({
    buffer = bufnr,
    exclude = {'gl', 'K'},
  })
end)
```

## Install new language servers

### Manual install

You can find install instructions for each language server in lspconfig's documentation: [server_configurations.md](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

### Via command

If you have [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim) installed you can use the command `:LspInstall` to install a language server. If you call this command while you are in a file it'll suggest a list of language server based on the type of that file.

### Automatic installs

If you have [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim), you can instruct `mason-lspconfig` to install the language servers you want using the option `ensure_installed`. Keep in mind the name of the language server must be [on this list](https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers).

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  -- Replace the language servers listed here
  -- with the ones you want to install
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {
    lsp_zero.default_setup,
  }
})
```

Notice here we also use the function [.default_setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#default_setupserver). We add this to the `handlers` so we can get automatic setup for all the language servers installed with `mason.nvim`.

For more details on how to use mason.nvim with lsp-zero [read this guide](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/integrate-with-mason-nvim.md).

## Configure language servers

To pass arguments to a language server you can use the lspconfig directly.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('lspconfig').tsserver.setup({
  single_file_support = false,
  on_attach = function(client, bufnr)
    print('hello tsserver')
  end
})
```

If you use `mason-lspconfig` to manage the setup of your language servers then you will need to add a custom handler. Here is an example.

```lua
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
    tsserver = function()
      require('lspconfig').tsserver.setup({
        single_file_support = false,
        on_attach = function(client, bufnr)
          print('hello tsserver')
        end
      })
    end,
  }
})
```

Notice in `handlers` there is a new property with the name of the language server and it has a function assign to it. That is where you configure the language server.

### Disable semantic highlights

Neovim v0.9 allows an LSP server to define highlight groups, this is known as semantic tokens. This new feature is enabled by default. To disable it we need to modify the `server_capabilities` property of the language server, more specifically we need to "delete" the `semanticTokensProvider` property.

We can disable this new feature in every server using the function [.set_server_config()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#set_server_configopts). 

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.set_server_config({
  on_init = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

Note that defining an `on_init` hook in a language server will override the one in [.set_server_config()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#set_server_configopts). 

If you just want to disable it for a particular server, use lspconfig to assign the `on_init` hook to that server.

```lua
require('lspconfig').tsserver.setup({
  on_init = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})
```

### Disable formatting capabilities

Sometimes you might want to prevent Neovim from using a language server as a formatter. For this you can use the `on_init` hook to modify the client instance.

```lua
require('lspconfig').tsserver.setup({
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentFormattingRangeProvider = false
  end,
})
```

## Custom servers

There are two ways you can use a server that is not supported by `lspconfig`:

### Add the configuration to lspconfig (recommended)

You can add the configuration to the module `lspconfig.configs` then you can call the `.setup` function.

You'll need to provide the command to start the LSP server, a list of filetypes where you want to attach the LSP server, and a function that detects the "root directory" of the project.

Note: before doing anything, make sure the server you want to add is **not** supported by `lspconfig`. Read the [list of supported LSP servers](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations).

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

local lsp_configurations = require('lspconfig.configs')

if not lsp_configurations.my_new_lsp then
  lsp_configurations.my_new_lsp = {
    default_config = {
      name = 'my-new-lsp',
      cmd = {'my-new-lsp'},
      filetypes = {'my-filetype'},
      root_dir = require('lspconfig.util').root_pattern('some-config-file')
    }
  }
end

require('lspconfig').my_new_lsp.setup({})
```

### Use the function [.new_client()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#new_clientopts)

If you don't need a "robust" solution you can use the function `.new_client()`. This function is just a thin wrapper that calls [vim.lsp.start()](https://neovim.io/doc/user/lsp.html#vim.lsp.start()) in a `FileType` autocommand.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.new_client({
  name = 'my-new-lsp',
  cmd = {'my-new-lsp'},
  filetypes = {'my-filetype'},
  root_dir = function()
    return lsp_zero.dir.find_first({'some-config-file'}) 
  end
})
```

## Enable Format on save

You have two ways to enable format on save.

Note: When you enable format on save your LSP server is doing the formatting. The LSP server does not share the same style configuration as Neovim. Tabs and indents can change after the LSP formats the code in the file. Read the documentation of the LSP server you are using, figure out how to configure it to your prefered style.

### Explicit setup

If you want to control exactly what language server is used to format a file call the function [.format_on_save()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#format_on_saveopts), this will allow you to associate a language server with a list of filetypes.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.format_on_save({
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
    ['tsserver'] = {'javascript', 'typescript'},
    ['rust_analyzer'] = {'rust'},
  }
})

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

### Always use the active servers

If you only ever have **one** language server attached in each file and you are happy with all of them, you can call the function [.buffer_autoformat()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#buffer_autoformatclient-bufnr) in the [.on_attach](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#on_attachcallback) hook.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
  lsp_zero.buffer_autoformat()
end)

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

If you have multiple servers active in one file it'll try to format using all of them, and I can't guarantee the order.

Is worth mention [.buffer_autoformat()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#buffer_autoformatclient-bufnr) is a blocking (synchronous) function. If you want something that behaves like [.buffer_autoformat()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#buffer_autoformatclient-bufnr) but is asynchronous you'll have to use [lsp-format.nvim](https://github.com/lukas-reineke/lsp-format.nvim).

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})

  -- make sure you use clients with formatting capabilities
  -- otherwise you'll get a warning message
  if client.supports_method('textDocument/formatting') then
    require('lsp-format').on_attach(client)
  end
end)

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

## Format buffer using a keybinding

### Using built-in functions

You'll want to bind the function [vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()) to a keymap. The next example will create a keymap `gq` to format the current buffer using **all** active servers with formatting capabilities.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
  local opts = {buffer = bufnr}

  vim.keymap.set({'n', 'x'}, 'gq', function()
    vim.lsp.buf.format({async = false, timeout_ms = 10000})
  end, opts)
end)

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

If you want to allow only a list of servers, use the `filter` option. You can create a function that compares the current server with a list of allowed servers.

```lua
local lsp_zero = require('lsp-zero')

local function allow_format(servers)
  return function(client) return vim.tbl_contains(servers, client.name) end
end

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
  local opts = {buffer = bufnr}

  vim.keymap.set({'n', 'x'}, 'gq', function()
    vim.lsp.buf.format({
      async = false,
      timeout_ms = 10000,
      filter = allow_format({'lua_ls', 'rust_analyzer'})
    })
  end, opts)
end)

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'lua_ls', 'rust_analyzer'})
```

### Ensure only one LSP server per filetype

If you want to control exactly what language server can format, use the function [.format_mapping()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#format_mappingkey-opts). It will allow you to associate a list of filetypes to a particular language server.

Here is an example using `gq` as the keymap.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.format_mapping('gq', {
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
    ['tsserver'] = {'javascript', 'typescript'},
    ['rust_analyzer'] = {'rust'},
  }
})

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

## Diagnostics

### Use icons in the sign column

If you don't know, the "sign column" is a space in the gutter next to the line numbers. When there is a warning or an error in a line Neovim will show you a letter like `W` or `E`. Well, you can turn that into icons if you wanted to, using the function [.set_sign_icons](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#set_sign_iconsopts). 

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

## Troubleshooting

### Automatic setup failed

First check that Neovim can find the executable of the language server, use the function `require('lsp-zero.check').executable()`. The first argument of the function must be the name of language server on [this list](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations).

```lua
:lua require('lsp-zero.check').executable('lua_ls')
```

If Neovim can't find the executable for the language server you'll get a message like this.

```
LSP server: lua_ls
- "lua-language-server" was not found.
```

Make sure your language was installed using `mason.nvim`. You can use the module `mason-lspconfig` to list all avaible servers.

```lua
:lua = require('mason-lspconfig').get_installed_servers()
```

If your language is not listed there then install it using the command `:LspInstall`.

### Root directory not found

You used the command `:LspInfo` and it showed `root directory: Not found.` This means [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/) couldn't figure out what is the "root" folder of your project. In this case you should go to `lspconfig`'s github repo and browse the [server_configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) file, look for the language server then search for `root_dir`, it'll have something like this.

```lua
root_pattern('somefile.json', '.somefile' , '.git')
```

`root_pattern` is a function inside `lspconfig`, it tries to look for one of those files/folders in the current folder or any of the parent folders. Make sure you have at least one of the files/folders listed in the arguments of the function.

Sometimes the documentation in lspconfig just says `see source file`. This means you need to go the source code to figure out what lspconfig looks for. You need to go to the [server config folder](https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/server_configurations), click in the file for the language server, look for the `root_dir` property that is inside a "lua table" called `default_config`.

### Inspect server settings

Let's say that you added some "settings" to a server... something like this.

```lua
lsp_zero.configure('tsserver', {
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

