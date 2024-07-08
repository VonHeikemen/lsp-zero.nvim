# LSP configuration

## Default keybindings

If you choose to use the function `.default_keymaps()` you'll be able to use Neovim's built-in functions for various actions. Things like jump to definition, rename variable, format current file, and some more.

Note that lsp-zero's keybindings have to be enabled explicitly, like this.

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end

lsp_zero.extend_lspconfig({
  lsp_attach = lsp_attach,
})
```

Here's the list of available keybindings:

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

By default lsp-zero will not create a keybinding if its "taken". This means if you already use one of these in your config, or some other plugins uses it ([which-key](https://github.com/folke/which-key.nvim) might be one), then lsp-zero's bindings will not work.

You can force lsp-zero's bindings by adding `preserve_mappings = false` to `.default_keymaps()`.

```lua
local lsp_attach = function(client, bufnr)
  lsp_zero.default_keymaps({
    buffer = bufnr,
    preserve_mappings = false
  })
end
```

## Disable keybindings

To disable lsp-zero's keybindings just delete the call to `.default_keymaps()`.

If you want lsp-zero to skip only a few keys you can add the `exclude` property to the `.default_keymaps()` call. Say you want to keep the default behavior of `K` and `gr`, you would do this.

```lua
local lsp_attach = function(client, bufnr)
  lsp_zero.default_keymaps({
    buffer = bufnr,
    exclude = {'gr', 'K'},
  })
end
```
## Creating new keybindings

The convention here is to create keymaps only when a language server is active in a buffer. For this use the `lsp_attach` option in `.extend_lspconfig()`, and then use neovim's built-in functions create the keybindings.

Here is an example that uses `gr` with a [telescope](https://github.com/nvim-telescope/telescope.nvim) command.

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', {buffer = bufnr})
end

lsp_zero.extend_lspconfig({
  lsp_attach = lsp_attach,
})
```

## Install new language servers

### Manual install

You can find install instructions for each language server in lspconfig's documentation: [server_configurations.md](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

### Via command

If you have [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim) installed you can use the command `:LspInstall` to install a language server. If you call this command while you are in a file it'll suggest a list of language server based on the type of that file.

### Automatic installs

If you have [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig](https://github.com/williamboman/mason-lspconfig.nvim), you can instruct `mason-lspconfig` to install the language servers you want using the option `ensure_installed`.

> [!NOTE]
> The name of the language server you want to install must be [on this list](https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers).

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  ---
  -- Code omitted for brevity
  ---
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
})

require('mason').setup({})
require('mason-lspconfig').setup({
  -- Replace the language servers listed here
  -- with the ones you want to install
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  }
})
```

We add a "default handler" to the `handlers` option so we can get automatic setup for all the language servers installed with `mason.nvim`.

## Configure language servers

To pass arguments to a language server you can use the lspconfig directly.

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  ---
  -- Code omitted for brevity
  ---
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
})

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
    -- this first function is the "default handler"
    -- it applies to every language server without a "custom handler"
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,

    -- this is the "custom handler" for `tsserver`
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

Neovim v0.9 allows a language server to apply new highlights, this is known as semantic tokens. This new feature is enabled by default. To disable it we need to modify the `server_capabilities` property of the language server, more specifically we need to "delete" the `semanticTokensProvider` property.

We can disable this new feature in every server whenever they attach to a buffer.

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  -- Disable semantic highlights
  client.server_capabilities.semanticTokensProvider = nil
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
})
```

If you just want to disable it for a particular server, use lspconfig to assign the `on_attach` hook to that server.

```lua
require('lspconfig').tsserver.setup({
  on_attach = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})
```

### Disable formatting capabilities

Sometimes you might want to prevent Neovim from using a language server as a formatter. For this you can use the `on_attach` hook to modify the client instance.

```lua
require('lspconfig').tsserver.setup({
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentFormattingRangeProvider = false
  end,
})
```

## Custom servers

There are two ways you can use a server that is not supported by `lspconfig`:

### Add the configuration to lspconfig (recommended)

You can add the configuration to the module `lspconfig.configs` then you can call the `.setup` function.

You'll need to provide the command that starts the language server, a list of filetypes where you want to attach the language server, and a function that detects the "root directory" of the project.

Note: before doing anything, make sure the server you want to add is **not** supported by `lspconfig`. Read the [list of supported language servers](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#configurations).

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  ---
  -- Code omitted for brevity
  ---
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
})

local lsp_configurations = require('lspconfig.configs')

if not lsp_configurations.name_of_my_lsp then
  lsp_configurations.name_of_my_lsp = {
    default_config = {
      cmd = {'command-that-start-the-lsp'},
      filetypes = {'my-filetype'},
      root_dir = require('lspconfig.util').root_pattern('some-config-file')
    }
  }
end

require('lspconfig').name_of_my_lsp.setup({})
```

> [!NOTE]
> `root_pattern` expects a list of files. The files that you list there should help `lspconfig` identify the root of your project.


### Use the function `.new_client()`

If you don't need a "robust" solution you can use the function `.new_client()`. This function is just a thin wrapper that calls [vim.lsp.start()](https://neovim.io/doc/user/lsp.html#vim.lsp.start()) in a `FileType` autocommand.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.new_client({
  name = 'my-new-lsp',
  cmd = {'command-that-start-the-lsp'},
  filetypes = {'my-filetype'},
  root_dir = function()
    return lsp_zero.dir.find_first({'some-config-file'}) 
  end
})
```

## Enable Format on save

You have two ways to enable format on save.

Note: When you enable format on save your language server is doing the formatting. The language server does not share the same style configuration as Neovim. Tabs and indents can change after the language server formats the code in the file. Read the documentation of the language server you are using, figure out how to configure it to your prefered style.

### Explicit setup

If you want to control exactly what language server is used to format a file call the function `.format_on_save()`, this will allow you to associate a language server with a list of filetypes.

```lua
local lsp_zero = require('lsp-zero')

-- don't add this function in the `lsp_attach` callback.
-- `format_on_save` should run only once, before the language servers are active.
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
```

### Always use the active servers

If you only ever have **one** language server attached in each file and you are happy with all of them, you can call the function `.buffer_autoformat()` when a language server is active in the current buffer.

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  lsp_zero.buffer_autoformat()
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
})
```

If you have multiple servers active in one file it'll try to format using all of them, and I can't guarantee the order.

It's worth mentioning `.buffer_autoformat()` is a blocking (synchronous) function. If you want something that behaves like `.buffer_autoformat()` but is asynchronous you'll have to use [lsp-format.nvim](https://github.com/lukas-reineke/lsp-format.nvim).

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  -- make sure you use clients with formatting capabilities
  -- otherwise you'll get a warning message
  if client.supports_method('textDocument/formatting') then
    require('lsp-format').on_attach(client)
  end
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
})
```

## Format using a keybinding

### Using built-in functions

You'll want to bind the function [vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()) to a keymap. The next example will create a keymap `gq` to format the current buffer using **all** active servers with formatting capabilities.

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  local opts = {buffer = bufnr}

  vim.keymap.set({'n', 'x'}, 'gq', function()
    vim.lsp.buf.format({async = false, timeout_ms = 10000})
  end, opts)
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
})
```

If you want to allow only a list of servers, use the `filter` option. You can create a function that compares the current server with a list of allowed servers.

```lua
local lsp_zero = require('lsp-zero')

local allow_format = function(servers)
  return function(client) return vim.tbl_contains(servers, client.name) end
end

local lsp_attach = function(client, bufnr)
  local opts = {buffer = bufnr}

  vim.keymap.set({'n', 'x'}, 'gq', function()
    vim.lsp.buf.format({
      async = false,
      timeout_ms = 10000,
      filter = allow_format({'lua_ls', 'rust_analyzer'})
    })
  end, opts)
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
})
```

### Ensure only one language server per filetype

If you want to control exactly what language server can format, use the function `.format_mapping()`. It will allow you to associate a list of filetypes to a particular language server.

Here is an example using `gq` as the keymap.

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  ---
  -- Code omitted for brevity
  ---
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
})

-- don't add this function in the `lsp_attach` callback.
-- `format_mapping` should run only once, before the language servers are active.
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
```

## How to format file using [tool]?

Where `[tool]` can be prettier or black or stylua or any command line tool that was create before the LSP protocol existed.

Short answer: You need some sort of adapter. Another plugin or a language server that can communicate with `[tool]`.

Long answer: Your question should be more specific to Neovim and not lsp-zero. You should be looking for "how to make [vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()) use `[tool]`?" And once you know how to do that you can use one of lsp-zero helper functions... or just `vim.lsp.buf.format()`.

If you really want to integrate that command line tool with Neovim's LSP client, these are your options:

* [efm-langserver](https://github.com/mattn/efm-langserver)
* [none-ls](https://github.com/nvimtools/none-ls.nvim)

Personally, I would use a plugin that communicates directly with the CLI tool. Here are a few options:

* [conform.nvim](https://github.com/stevearc/conform.nvim)
* [Formatter.nvim](https://github.com/mhartington/formatter.nvim)
* [guard.nvim](https://github.com/nvimdev/guard.nvim)

If you are going that route and you are wondering which one to choose, use `conform.nvim`. People say it's good. Don't think about it too much.

## Diagnostics

The function `.extend_lspconfig()` has the option `sign_text`, with it you can enable or disable the diagnostic signs.

The value `true` will enable diagnostic signs in the `vim.diagnostic` module. It will also change the value of the vim option `signcolumn` from "auto" to "yes" to avoid a layout shift when signs appear on screen.

```lua
lsp_zero.extend_lspconfig({
  sign_text = true,
})
```

If `sign_text` is `false` it will disable diagnostic signs in the `vim.diagnostic` module. The vim option `signcolumn` will not be modified.

```lua
lsp_zero.extend_lspconfig({
  sign_text = false,
})
```

`sign_text` can also be a table, this will allow you to change the text of diagnostic signs.

```lua
lsp_zero.extend_lspconfig({
  sign_text = {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = '»',
  },
})
```

If you don't provide `sign_text` to `extend_lspconfig()` you get the default behavior your Neovim version has for diagnostic signs.

## How does it work?

Language servers are configured and initialized using [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/).

lsp-zero first adds data to an option called `capabilities` in lspconfig's defaults. This new data comes from [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp). It tells the language server what features [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) adds to the editor.

Then it creates an autocommand on the event `LspAttach`. This autocommand will be triggered every time a language server is attached to a buffer. This is where all keybindings and commands are created.

So this example configuration

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities()
})

require('lspconfig').tsserver.setup({})
require('lspconfig').rust_analyzer.setup({})
```

Is the same as this:

```lua
vim.opt.signcolumn = 'yes'

vim.diagnostic.config({
  signs = true
})

local lspconfig = require('lspconfig')

lspconfig.util.default_config.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig.util.default_config.capabilities,
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
  end,
})

lspconfig.tsserver.setup({})
lspconfig.rust_analyzer.setup({})
```

