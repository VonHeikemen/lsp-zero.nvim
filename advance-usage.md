# Advance usage

## Configuring language servers

Here's an example configuration showing the functions you have available to configure and install LSP servers.

```lua
-- reserve space for diagnostic icons
vim.opt.signcolumn = 'yes'

local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

-- make sure this servers are installed
-- see :help lsp-zero.ensure_installed()
lsp.ensure_installed({
  'rust_analyzer',
  'tsserver',
  'eslint',
  'sumneko_lua',
})

-- don't initialize this language server
-- we will use rust-tools to setup rust_analyzer
lsp.skip_server_setup({'rust_analyzer'})

-- the function below will be executed whenever
-- a language server is attached to a buffer
lsp.on_attach(function(client, bufnr)
  print('Greetings from on_attach')
end)

-- pass arguments to a language server
-- see :help lsp-zero.configure()
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

-- share configuration between multiple servers
-- see :help lsp-zero.setup_servers()
lsp.setup_servers({
  'eslint',
  'angularls',
  opts = {
    single_file_support = false,
    on_attach = function(client, bufnr)
      print("I'm doing web dev")
    end
  }
})

-- configure lua language server for neovim
-- see :help lsp-zero.nvim_workspace()
lsp.nvim_workspace()

lsp.setup()

-- initialize rust_analyzer with rust-tools
-- see :help lsp-zero.build_options()
local rust_lsp = lsp.build_options('rust_analyzer', {
  single_file_support = false,
  on_attach = function(client, bufnr)
    print('hello rust-tools')
  end
})

require('rust-tools').setup({server = rust_lsp})
```

## Setup LSP keybindings in vimscript

The easiest way I can think of is using a global function. Somewhere in your config you declare a function with your keybindings.

```vim
function! LspAttached() abort
  nnoremap <buffer> <leader>r <cmd>lua vim.lsp.buf.rename()<cr>
  nnoremap <buffer> <leader>k <cmd>lua vim.lsp.buf.signature_help()<CR>
  " and many more ...
endfunction
```

Next you call that function when the LSP server is attached to a buffer.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = false, -- (optional) Disable default keybindings
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.on_attach(function(client, bufnr)
  vim.call('LspAttached')
end)

lsp.setup()
```

## Can I use that one language server I have installed globally?

Yes, call the function [.configure()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#configurename-opts) and set the option `force_setup` to `true`.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.configure('dartls', {
  force_setup = true,
  on_attach = function()
    print('hello dartls')
  end,
})

lsp.setup()
```

## Configure errors messages

You are looking for "diagnostics". If you want to configure them use the function [vim.diagnostic.config](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.config()), and make sure to call it after lsp-zero's setup function.

Here is an example that enables virtual text.

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
})
```

## Buffer formats twice

This can happen because the built-in function for formatting ([vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format())) uses every server with "formatting capabilities" enabled.

You can disable an LSP server formatting capabilities like this:

```lua
lsp.configure("tsserver", {
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentFormattingRangeProvider = false
  end
})
```

Or if you have a custom `lsp.on_attach`:

```lua
lsp.on_attach(function(client, bufnr)
  -- Disable LSP server formatting, to prevent formatting twice. 
  -- Once by the LSP server, second time by NULL-ls.
  if client.name == "volar" or client.name == "tsserver" then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentFormattingRangeProvider = false
  end
end)
```

## Customizing nvim-cmp

Using [.setup_nvim_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#setup_nvim_cmpopts) will allow you to override some options of nvim-cmp. Here's a few useful things you can do.

### Don't preselect first match

You want to modify `completion.completeopt`. For this to work write all the defaults and then add `noselect`. Then make sure "preselect mode" is set to `none`. Like this. 

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup_nvim_cmp({
  preselect = 'none',
  completion = {
    completeopt = 'menu,menuone,noinsert,noselect'
  },
})

lsp.setup()
```

In theory, you should use `preselect = require('cmp').PreselectMode.None`. But for now is the same as `'none'`.

### Setting up sources

Using the `sources` option you can specify the priority of each source by changing the order. You could also include new ones. Check out nvim-cmp's documentation to know what are the possibilities.

Here is an example that recreates the default configuration for sources.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup_nvim_cmp({
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp', keyword_length = 1},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  }
})

-- still, setup must be the last function
lsp.setup()
```

### Change the look

This you do with the `formatting` option. It is kind of a complex topic because it requires some knowledge about `nvim-cmp` and lua. Again, you should check out `nvim-cmp` docs.

Anyway, here is an example changing the names of the sources with some icons.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup_nvim_cmp({
  formatting = {
    -- changing the order of fields so the icon is the first
    fields = {'menu', 'abbr', 'kind'},

    -- here is where the change happens
    format = function(entry, item)
      local menu_icon = {
        nvim_lsp = 'λ',
        luasnip = '⋗',
        buffer = 'Ω',
        path = '🖫',
        nvim_lua = 'Π',
      }

      item.menu = menu_icon[entry.source.name]
      return item
    end,
  },
})

lsp.setup()
```

### Documentation window

We can change that too. There's the `documentation` option. Is the same as nvim-cmp's `window.documentation` option. And these are the defaults.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup_nvim_cmp({
  documentation = {
    max_height = 15,
    max_width = 60,
    border = 'rounded',
    col_offset = 0,
    side_padding = 1,
    winhighlight = 'Normal:Normal,FloatBorder:Normal,CursorLine:Visual,Search:None',
    zindex = 1001
  }
})

lsp.setup()
```

You could also disable it if you set it to `false`.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup_nvim_cmp({
  documentation = false
})

lsp.setup()
```

### Changing the keybindings

The option you want is `mapping`. The trickiest. Here you are going to find yourself in an all or nothing situation, if you choose to use it then **you** are in charge of all mappings, all the defaults will disappear. But don't worry, you can access those defaults with the function [lsp.defaults.cmp_mappings()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#defaultscmp_mappingsopts).

Here is an example that adds `<C-Space>` to trigger completion and makes `<C-e>` cancel the completion instead of toggling.

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
  })
})

lsp.setup()
```

Want to know how much fun you can have creating your own mappings? Check out the wiki section [Under the hood](https://github.com/VonHeikemen/lsp-zero.nvim/wiki/Under-the-hood) and scroll down all the way where it says `Autocompletion`.

### I just want to use vim default keybindings for autocomplete

You can use the preset that comes with nvim-cmp.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

local cmp = require('cmp')

lsp.setup_nvim_cmp({
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
  })
})

lsp.setup()
```

What about the navigating through snippets placeholder? That's not a part vim's default, I don't know what those should be. But here, I suggest these:

```lua
-- go to next placeholder in the snippet
['<C-g>'] = cmp.mapping(function(fallback)
  if luasnip.jumpable(1) then
    luasnip.jump(1)
  else
    fallback()
  end
end, {'i', 's'}),

-- go to previous placeholder in the snippet
['<C-d>'] = cmp.mapping(function(fallback)
  if luasnip.jumpable(-1) then
    luasnip.jump(-1)
  else
    fallback()
  end
end, {'i', 's'}),
```

### "Unmap" a default keybinding

You can disable any default keymap by overriding the `mapping` property in `nvim-cmp`. Use [lsp.defaults.cmp_mappings()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#defaultscmp_mappingsopts) to expose the default keybindings then "delete" the one you want. Let's make an example with `Tab`.

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
    ['<Tab>'] = vim.NIL,
    ['<S-Tab>'] = vim.NIL,
  })
})

lsp.setup()
```

### Adding a source

You can extend the sources by overriding the `sources` property. Use [lsp.defaults.cmp_sources()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#defaultscmp_sources) to expose the default sources and then insert the new source.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

local cmp_sources = lsp.defaults.cmp_sources()

table.insert(cmp_sources, {name = 'name-of-new-source'})

lsp.setup_nvim_cmp({
  sources = cmp_sources
})

lsp.setup()
```

### Invoke completion menu manually

Not a fan of constant completion suggestions? Don't worry there is a way to invoke the completion only demand. If you set `completion.autocomplete` to `false`, the menu will only show up when you press `tab` or `ctrl + e`.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup_nvim_cmp({
  completion = {autocomplete = false}
})

lsp.setup()
```

### The current api is not enough?

Welp, that's interesting. Maybe this is a good time to setup `nvim-cmp` yourself. Disable the setting `manage_nvim_cmp` and then use the function [lsp.defaults.cmp_config()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#defaultscmp_mappingsopts) to extend or change the default configuration table.

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

Finally, in case no one has told you this today... you should read nvim-cmp's documentation. You are awesome.

## Intergrate with `null-ls`

### Standalone null-ls instance

null-ls isn't a real language server, if you want "integrate it" with lsp-zero all you need to do is call their setup function after lsp-zero's config.

The only option that makes sense to share with null-ls is the `on_attach` function. Here is an example on how to do it.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup()

local null_ls = require('null-ls')
local null_opts = lsp.build_options('null-ls', {})

null_ls.setup({
  on_attach = function(client, bufnr)
    null_opts.on_attach(client, bufnr)
    ---
    -- you can add other stuff here....
    ---
  end,
  sources = {
    -- Replace these with the tools you have installed
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.formatting.stylua,
  }
})
```

> Make sure the `build_options` is after `lsp.setup()`. see [#60](https://github.com/VonHeikemen/lsp-zero.nvim/issues/60#issuecomment-1363800412)

### Format buffer using only null-ls

The solution I propose here is to use the `on_attach` function to create a command called `NullFormat`. This new command will have all the arguments necessary to send a formatting request specifically to null-ls. You could then create a keymap bound to the `NullFormat` command.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup()

local null_ls = require('null-ls')
local null_opts = lsp.build_options('null-ls', {})

null_ls.setup({
  on_attach = function(client, bufnr)
    null_opts.on_attach(client, bufnr)

    local format_cmd = function(input)
      vim.lsp.buf.format({
        id = client.id,
        timeout_ms = 5000,
        async = input.bang,
      })
    end

    local bufcmd = vim.api.nvim_buf_create_user_command
    bufcmd(bufnr, 'NullFormat', format_cmd, {
      bang = true,
      range = true,
      desc = 'Format using null-ls'
    })
  end,
  sources = {
    --- Replace these with the tools you have installed
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettier,
  }
})

```

### Adding mason-null-ls.nvim

[mason-null-ls.nvim](https://github.com/jay-babu/mason-null-ls.nvim) can help you install tools compatible with null-ls.

### Automatic Install

Ensure the tools you have listed in the `sources` option are installed automatically.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup()

local null_ls = require('null-ls')
local null_opts = lsp.build_options('null-ls', {})

null_ls.setup({
  on_attach = function(client, bufnr)
    null_opts.on_attach(client, bufnr)
    ---
    -- you can add other stuff here....
    ---
  end,
  sources = {
    -- Replace these with the tools you want to install
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.formatting.stylua,
  }
})

-- See mason-null-ls.nvim's documentation for more details:
-- https://github.com/jay-babu/mason-null-ls.nvim#setup
require('mason-null-ls').setup({
  ensure_installed = nil,
  automatic_installation = true,
  automatic_setup = false,
})
```

### Automatic setup

Make null-ls aware of the tools you installed using mason.nvim, and configure them automatically.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup()

local null_ls = require('null-ls')
local null_opts = lsp.build_options('null-ls', {})

null_ls.setup({
  on_attach = function(client, bufnr)
    null_opts.on_attach(client, bufnr)
  end,
  sources = {
    -- You can add tools not supported by mason.nvim
  }
})

-- See mason-null-ls.nvim's documentation for more details:
-- https://github.com/jay-babu/mason-null-ls.nvim#setup
require('mason-null-ls').setup({
  ensure_installed = nil,
  automatic_installation = false, -- You can still set this to `true`
  automatic_setup = true,
})

-- Required when `automatic_setup` is true
require('mason-null-ls').setup_handlers()
```

