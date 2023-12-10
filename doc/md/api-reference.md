# API reference

## Commands

* `LspZeroFormat {server} timeout={timeout}`: Formats the current buffer or range. If the "bang" is provided formatting will be asynchronous (ex: `LspZeroFormat!`). If you provide the name of a language server as a first argument it will try to format only using that server. Otherwise, it will use every active language server with formatting capabilities. With the `timeout` parameter you can configure the time in milliseconds to wait for the response of the formatting requests.

* `LspZeroWorkspaceRemove`: Remove the folder at path from the workspace folders. See [:help vim.lsp.buf.remove_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.remove_workspace_folder()).

* `LspZeroWorkspaceAdd`: Add the folder at path to the workspace folders. See [:help vim.lsp.buf.add_workspace_folder()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.add_workspace_folder()).

* `LspZeroWorkspaceList`: List workspace folders. See [:help vim.lsp.buf.list_workspace_folders()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.list_workspace_folders()).

* `LspZeroSetupServers`: It takes a space separated list of servers and configures them.

## Global variables

* `lsp_zero_extend_cmp`: When set to `0` then lsp-zero will not integrate with nvim-cmp automatically.

* `lsp_zero_extend_lspconfig`: When set to `0` then lsp-zero will not integrate with lspconfig automatically.

* `lsp_zero_ui_float_border`: Set the style of border of diagnostic floating window, hover window and signature help window. Can have one of these: `'none'`, `'single'`, `'double'`, `'rounded'`, `'solid'` or `'shadow'`. The default value is `rounded`. If set to `0` then lsp-zero will not configure the border style.

* `lsp_zero_ui_signcolumn`: When set to `0` the lsp-zero will not configure the space in the gutter for diagnostics.

* `lsp_zero_api_warnings`: When set to `0` it will supress the warning messages from deprecated functions. (Note: if you get one of those warnings, know that showing that message is the only thing they do. They are "empty" functions.)

Now, when I say global variable I mean a vim global variable. So to modify them from lua you would do something like this

```lua
vim.g.lsp_zero_extend_lspconfig = 0
```

But if you are using vimscript, you can do something like this

```vim
let g:lsp_zero_extend_lspconfig = 0
```

## Lua api

### `.default_keymaps({opts})`

Create the keybindings using Neovim's built-in LSP functions. 

The `{opts}` table supports these properties:

  * buffer: (optional) Number. The "id" of an open buffer. If the number 0 is provided then the keymaps will be effective in the current buffer.

  * preserve_mappings: (optional) Boolean, default value is `true`. When set to `true` lsp-zero will not override your existing keybindings.

  * exclude: (optional) Table. List of string, must be valid keybindings. lsp-zero will preserve the behavior of these keybindings.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

#### LSP Actions

* `K`: Displays hover information about the symbol under the cursor in a floating window. See [:help vim.lsp.buf.hover()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.hover()).

* `gd`: Jumps to the definition of the symbol under the cursor. See [:help vim.lsp.buf.definition()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.definition()).

* `gD`: Jumps to the declaration of the symbol under the cursor. Some servers don't implement this feature. See [:help vim.lsp.buf.declaration()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.declaration()).

* `gi`: Lists all the implementations for the symbol under the cursor in the quickfix window. See [:help vim.lsp.buf.implementation()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.implementation()).

* `go`: Jumps to the definition of the type of the symbol under the cursor. See [:help vim.lsp.buf.type_definition()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.type_definition()).

* `gr`: Lists all the references to the symbol under the cursor in the quickfix window. See [:help vim.lsp.buf.references()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.references()).

* `gs`: Displays signature information about the symbol under the cursor in a floating window. See [:help vim.lsp.buf.signature_help()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.signature_help()). If a mapping already exists for this key this function is not bound.

* `<F2>`: Renames all references to the symbol under the cursor. See [:help vim.lsp.buf.rename()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.rename()).

* `<F3>`: Format code in current buffer. See [:help vim.lsp.buf.formatting()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.formatting()).

* `<F4>`: Selects a code action available at the current cursor position. See [:help vim.lsp.buf.code_action()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.code_action()).

* `gl`: Show diagnostics in a floating window. See [:help vim.diagnostic.open_float()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.open_float()).

* `[d`: Move to the previous diagnostic in the current buffer. See [:help vim.diagnostic.goto_prev()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.goto_prev()).

* `]d`: Move to the next diagnostic. See [:help vim.diagnostic.goto_next()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.goto_next()).

### `.set_sign_icons({opts})`

Defines the sign icons that appear in the gutter.

`{opts}` table supports these properties:

  * error: Text for the error signs.

  * warn: Text for the warning signs.

  * hint: Text for the hint signs.

  * info: Text for the information signs.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})
```

### `highlight_symbol({client}, {bufnr})`

Uses the `CursorHold` event to trigger a document highlight request. In other words, it will highlight the symbol under the cursor.

For this to work properly your colorscheme needs to set these highlight groups: `LspReferenceRead`, `LspReferenceText` and `LspReferenceWrite`.

Keep in mind the event `CursorHold` depends on the `updatetime` option. If you want the highlight to happen fast, you will need to set this option to a "low" value.

```lua
vim.opt.updatetime = 350
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.highlight_symbol(client, bufnr)
end)
```

### `.on_attach({callback})`

Executes the `{callback}` function every time `lspconfig` attaches a server to a buffer.

This is where you can declare your own keymaps and commands.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
  local opts = {buffer = bufnr}

  vim.keymap.set('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  -- more code  ...
end)
```

### `.set_server_config({opts})`

It will share the configuration options with all the language servers initialized by `lspconfig`. These options are the same nvim-lspconfig uses in their setup function, see [:help lspconfig-setup](https://github.com/neovim/nvim-lspconfig/blob/41dc4e017395d73af0333705447e858b7db1f75e/doc/lspconfig.txt#L68).

Here is an example that enables the folding capabilities and disable single file support.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.set_server_config({
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
local lsp_zero = require('lsp-zero')

lsp_zero.configure('tsserver', {
  single_file_support = false,
  on_attach = function(client, bufnr)
    print('hello tsserver')
  end
})
```

### `.setup_servers({list}, {opts})`

Will configure all the language servers you have on `{list}`.

The `{opts}` table supports the following properties:

  * exclude: (optional) Table. List of names of LSP servers you **don't** want to setup.

```lua
local lsp_zero = require('lsp-zero')

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

### `.default_setup({server})`

Configures `{server}` with the default config provided by lspconfig.

This is meant to be used with `mason-lspconfig.nvim`, in order to help configure automatic setup of language servers. It can be added as a default handler in the setup function of the module `mason-lspconfig`.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
  },
})
```

### `.noop()`

Doesn't do anything. Literally.

You can use think of this as "empty handler" for `mason-lspconfig.nvim`. Consider this example.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {'tsserver', 'eslint', 'jdtls'},
  handlers = {
    lsp_zero.default_setup,
    jdtls = lsp_zero.noop,
  },
})
```

In here `mason-lspconfig` will install all the servers in `ensure_installed`. Then it will try configure the servers but it will ignore `jdtls` because the handler doesn't do anything. So you are free to configure jdtls however you like.

### `.get_capabilities()`

Returns Neovim's default capabilities mixed with the capabilities provided by the `cmp_nvim_lsp` plugin.

This is useful when you want to configure a language using a specialized plugin. See the examples in [quick-recipes.md](https://github.com/VonHeikemen/lsp-zero.nvim/blob/compat-07/doc/md/guides/quick-recipes.md).

### `.build_options({name}, {opts})`

Returns all the parameters lsp-zero uses to initialize a language server. This includes default capabilities and settings that were added using the [.set_server_config()](#set_server_configopts) function.

### `.nvim_lua_ls({opts})`

Returns settings specific to Neovim for the lua language server, `lua_ls`. If you provide the `{opts}` table it'll merge it with the defaults, this way you can extend or change the values easily.

```lua
local lsp_zero = require('lsp-zero')
local lua_opts = lsp_zero.nvim_lua_ls({
  single_file_support = false,
  on_attach = function(client, bufnr)
    print('hello world')
  end,
  settings = {
    Lua = {
      completion = {keywordSnippet = 'Disable'}
    }
  }
})

require('lspconfig').lua_ls.setup(lua_opts)
```

### `.store_config({name}, {opts})`

Saves the configuration options for a language server, so you can use it at a later time in a local config file.

### `.use({name}, {opts})`

For when you want you want to add more settings to a particular language server in a particular project. It is meant to be called in project local config (but you can still use it in your init.lua).

Ideally, you would setup some default values for your servers in your neovim config using [.configure()](#configurename-opts), or maybe [.store_config()](#store_configname-opts).

```lua
-- init.lua

local lsp_zero = require('lsp-zero')

lsp_zero.configure('pyright', {
  single_file_support = false,
})
```

And then in your local config you can tweak the server options even more.

```lua
-- local config

local lsp_zero = require('lsp-zero')

lsp_zero.use('pyright', {
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

lsp-zero does not execute files. It only provides utility functions. So to execute your "local config" you'll have to use other methods.

### `.format_on_save({opts})`

Setup autoformat on save. This will to allow you to associate a language server with a list of filetypes.

Keep in mind it's only meant to allow one LSP server per filetype, this is so the formatting is consistent.

`{opts}` supports the following properties:

  * servers: (Table) Key/value pair list. On the left hand side you must specify the name of a language server. On the right hand side you must provide a list of filetypes, this can be any pattern supported by the `FileType` autocommand.

  * format_opts: (Table, optional). Configuration that will passed to the formatting function. It supports the following properties:
    
    * async: (Boolean, optional). If true it will send an asynchronous format request to the LSP server.

    * timeout_ms: (Number, optional). Time in milliseconds to block for formatting requests. Defaults to `10000`.

    * formatting_options: (Table, optional). Can be used to set `FormattingOptions`, these options are sent to the language server. See [FormattingOptions Specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#formattingOptions).  

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.format_on_save({
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
    ['rust_analyzer'] = {'rust'},
    ['tsserver'] = {'javascript', 'typescript'},
  }
})
```

### `.buffer_autoformat({client}, {bufnr}, {opts})`

Format the current buffer using the active language servers.

If {client} argument is provided it will only use the LSP server associated with that client.

  * client: (Table, Optional) if provided it must be a lua table with a `name` property or an instance of [vim.lsp.client](https://neovim.io/doc/user/lsp.html#vim.lsp.client).

  * bufnr: (Number, Optional) if provided it must be the id of an open buffer.

  * opts: (Table, optional). Configuration that will passed to the formatting function. It supports the following properties:
    
    * formatting_options: (Table, optional). Can be used to set `FormattingOptions`, these options are sent to the language server. See [FormattingOptions Specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#formattingOptions).  

    * timeout_ms: (Number, optional). Time in milliseconds to block for formatting requests. Defaults to `10000`.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
  lsp_zero.buffer_autoformat()
end)
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
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('lspconfig').tsserver.setup({
  on_attach = function(client, bufnr)
    lsp_zero.async_autoformat(client, bufnr)
  end
})
```

### `.format_mapping({key}, {opts})`

Configure {key} to format the current buffer.   

The idea here is that you associate a language server with a list of filetypes, so `{key}` can format the buffer using only one LSP server.

`{opts}` supports the following properties:

  * servers: (Table) Key/value pair list. On the left hand side you must specify the name of a language server. On the right hand side you must provide a list of filetypes, this can be any pattern supported by the `FileType` autocommand.

  * format_opts: (Table, Optional) Supports the following properties:

    * async: (Boolean, optional). If true it will send an asynchronous format request to the LSP server.

    * formatting_options: (Table, Optional) Settings send to the language server. These are the same settings as the `formatting_options` argument in [vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()).

    * timeout_ms: (Number, Optional) Defaults to 10000. Time in milliseconds to ignore the current format request.

  * mode: (Table). The list of modes where the keybinding will be active. By default is set to `{'n', 'x'}`, which means normal mode and visual mode.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.format_mapping('gq', {
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
    ['lua_ls'] = {'lua'},
    ['rust_analyzer'] = {'rust'},
  }
})
```

### `.new_client({opts})`

lsp-zero will execute a user provided function to detect the root directory of the project when Neovim assigns the file type for a buffer. If the root directory is detected the LSP server will be attached to the file.

This function does not depend on `lspconfig`, it's a thin wrapper around a Neovim function called [vim.lsp.start_client()](https://neovim.io/doc/user/lsp.html#vim.lsp.start_client()).

`{opts}` supports every property `vim.lsp.start_client` supports with a few changes:

  * `filestypes`: Can be list filetype names. This can be any pattern the `FileType` autocommand accepts.

  * `root_dir`: Can be a function, it'll be executed after Neovim assigns the file type for a buffer. If it returns a string that will be considered the root directory for the project.

Other important properties are:

  * `cmd`: (Table) A lua table with the arguments necessary to start the language server.

  * `name`: (String) This is the name Neovim will assign to the client object.

  * `on_attach`: (Function) A function that will be executed after the language server gets attached to a buffer.

Here is an example that starts the [typescript language server](https://github.com/typescript-language-server/typescript-language-server) on javascript and typescript, but only in a project that package.json in the current directory or any of its parent folders.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function()
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.new_client({
  name = 'tsserver',
  cmd = {'typescript-language-server', '--stdio'},
  filetypes = {'javascript', 'typescript'},
  root_dir = function()
    return lsp_zero.dir.find_first({'package.json'})
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
local lsp_zero = require('lsp-zero')

require('lspconfig').lua_ls.setup({
  root_dir = function()
    --- project root will be the first directory that has
    --- either .luarc.json or .stylua.toml
    return lsp_zero.dir.find_first({'.luarc.json', '.stylua.toml'})
  end
})
```

### `.dir.find_all({list})`

Checks the parent directories and returns the path to the first folder that has all the files in `{list}`.

Note: search will stop once it gets to your "HOME" folder.

`{list}` supports the following properties:

  * path: (String) The path from where it should start looking for the files in `{list}`.

  * buffer: (Boolean) When set to `true` use the path of the current buffer.

```lua
local lsp_zero = require('lsp-zero')

require('lspconfig').vuels.setup({
  root_dir = function()
    --- project root will be the directory that has
    --- package.json + vetur config
    return lsp_zero.dir.find_all({'package.json', 'vetur.config.js'})
  end
})
```

### `.extend_lspconfig()`

Takes care of the integration between lspconfig and nvim-cmp.

It extends the `capabilities` option in lspconfig's defaults, using the plugin `cmp_nvim_lsp`. And it creates a "hook" so users can provide their own default config using [.set_server_config()](#set_server_configopts)).

### `.cmp_action()`

Is a function that returns methods meant to be used as mappings for nvim-cmp.

These are the supported methods:

* `tab_complete`: Enables completion when the cursor is inside a word. If the completion menu is visible it will navigate to the next item in the list. If the line is empty it uses the fallback.

* `select_prev_or_fallback`: If the completion menu is visible navigate to the previous item in the list. Else, uses the fallback.

* `toggle_completion`: If the completion menu is visible it cancels the process. Else, it triggers the completion menu. You can use the property `modes` in the first argument to specify where this mapping should active (the default is `{modes = {'i'}}`).

* `luasnip_jump_forward`: Go to the next placeholder in the snippet.

* `luasnip_jump_backward`: Go to the previous placeholder in the snippet.

* `luasnip_next`: If completion menu is visible it will navigate to the item in the list. If the cursor can jump to a snippet placeholder, it moves to it. Else, it uses the fallback.

* `luasnip_next_or_expand`: If completion menu is visible it will navigate to the item in the list. If cursor is on top of the trigger of a snippet it'll expand it. If the cursor can jump to a snippet placeholder, it moves to it. Else, it uses the fallback.

* `luasnip_supertab`: If the completion menu is visible it will navigate to the next item in the list. If cursor is on top of the trigger of a snippet it'll expand it. If the cursor can jump to a snippet placeholder, it moves to it. If the cursor is in the middle of a word that doesn't trigger a snippet it displays the completion menu. Else, it uses the fallback.

* `luasnip_shift_supertab`: If the completion menu is visible it will navigate to previous item in the list. If the cursor can navigate to a previous snippet placeholder, it moves to it. Else, it uses the fallback.

Quick note: "the fallback" is the default behavior of the key you assign to a method.

### `.cmp_format()`

When used the completion items will show a label that identifies the source they come from.

```lua
local cmp = require('cmp')
local cmp_format = require('lsp-zero').cmp_format()

cmp.setup({
  formatting = cmp_format
})
```

### `.extend_cmp({opts})`

Creates a minimal working config for nvim-cmp.

`{opts}` supports the following properties:

  * set_lsp_source: (Boolean, Optional) Defaults to `true`. When enabled it adds `cmp-nvim-lsp` as a source.

  * set_mappings: (Boolean, Optional) Defaults to `true`. When enabled it will create keybindings that emulate Neovim's default completions bindings.

  * use_luasnip: (Boolean, Optional) Defaults to `true`. When enabled it will setup luasnip to expand snippets. This option does not include a collection of snippets.

  * set_format: (Boolean, Optional) Defaults to `true`. When enabled it will the completion items will show a label that identifies the source they come from. 

  * documentation_window: (Boolean, Optional) Defaults to `true`. When enabled it will configure the max height and width of the documentation window.

After you use this function you can customize nvim-cmp using the module `cmp`. Here is an example that adds some keybindings.

```lua
require('lsp-zero').extend_cmp()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  })
})
```

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
local lsp_zero = require('lsp-zero')

lsp_zero.omnifunc.setup({
  tabcomplete = true,
  use_fallback = true,
  update_on_delete = true,
})
```

And here is an example for autocomplete.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.omnifunc.setup({
  autocomplete = true,
  use_fallback = true,
  update_on_delete = true,
  trigger = '<C-Space>',
})
```

