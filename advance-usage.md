# Advance usage

## Changing sign icons

After setting the preset you are allowed to override the icons shown in the gutter for diagnostics.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.set_preferences({
  sign_icons = {
    error = 'E',
    warn = 'W',
    hint = 'H',
    info = 'I'
  }
})
```

## Yes, you can override the settings of a preset

Be careful though. If you are going to override a preset do it right after calling `.preset()`.

If you have any questions you can stop by the [discussions](https://github.com/VonHeikemen/lsp-zero.nvim/discussions) page.

## Configuring language servers

To pass custom options to a server you have the functions `.configure()` and `setup_servers()`. You can install servers at startup with `.ensure_installed()`. Finally, you can use `.on_attach()` to define a callback that will be executed when a language server is attached to a buffer.

Here's an example config.

```lua
local lsp = require('lsp-zero')

-- use recommended settings
lsp.preset('recommended')

-- make sure these servers are installed
lsp.ensure_installed({
  'html',
  'cssls',
  'angularls',
  'tsserver'
})

-- share options between serveral servers
local lsp_opts = {
  flags = {
    debounce_text_changes = 150,
  }
}

lsp.setup_servers({
  'html',
  'cssls',
  opts = lsp_opts
})

-- configure an individual server
lsp.configure('tsserver', {
  flags = {
    debounce_text_changes = 150,
  },
  on_attach = function(client, bufnr)
    print('hello tsserver')
  end
})

-- the function below will be executed whenever
-- a language server is attached to a buffer
lsp.on_attach(function(client, bufnr)
  local noremap = {buffer = bufnr, remap = false}
  local bind = vim.keymap.set

  bind('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<cr>', noremap)
  bind('n', 'Q', function() print('Hello') end, {buffer = bufnr, desc = 'Say hello'})
  -- more code  ...
end)

-- setup must be the last function
-- this one does all the things
lsp.setup()
```

## Configure diagnostics

Inside lsp-zero diagnostics are configured right before calling the first language server. In a common scenario where you use the `recommended` preset you can call [vim.diagnostic.config](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.config()) after you setup lsp-zero.

Here is an example that restores the default behavior of diagnostics.

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
local lsp = require('lsp-zero')
lsp.preset('recommended')

-- Disable default keybindings (optional)
lsp.set_preferences({
  set_lsp_keymaps = false
})

lsp.on_attach(function(client, bufnr)
  vim.call('LspAttached')
end)

lsp.setup()
```

## Can I use that one language server I have installed globally?

Yes, call the function `.configure()` and set the option `force_setup` to `true`.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.configure('dartls', {
  force_setup = true,
  on_attach = function()
    print('hello dartls')
  end,
})

lsp.setup()
```

## Customizing nvim-cmp

Using `setup_nvim_cmp` will allow you to override some options of `nvim-cmp`. Here's a few useful things you can do.

### Don't preselect first match

You want to modify `completion.completeopt`. For this to work write all the defaults and then add `noselect`. Then make sure "preselect mode" is set to `none`. Like this. 

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

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

Using the `sources` option you can specify the priority of each source by changing the order. You could also include new ones. Check out `nvim-cmp`'s documentation to know what are the possibilities.

Here is an example that recreates the default configuration for sources.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.setup_nvim_cmp({
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp', keyword_length = 3},
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
local lsp = require('lsp-zero')
lsp.preset('recommended')

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

We can change that too. There's the `documentation` option. Is the same as `nvim-cmp`'s `window.documentation` option. And these are the defaults.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

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
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.setup_nvim_cmp({
  documentation = false
})

lsp.setup()
```

### Changing the keybindings

The option you want is `mapping`. The trickiest. Here you are going to find yourself in an all or nothing situation, if you choose to use it then **you** are in charge of all mappings, all the defaults will disappear. But don't worry, you can access those defaults with the function `lsp.defaults.cmp_mappings()`.

Here is an example that adds `<C-Space>` to trigger completion and makes `<C-e>` cancel the completion instead of toggling.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

local cmp = require('cmp')
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>'] = cmp.mapping.abort(),
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.setup()
```

Want to know how much fun you can have creating your own mappings? Check out the wiki section [Under the hood](https://github.com/VonHeikemen/lsp-zero.nvim/wiki/Under-the-hood) and scroll down all the way where it says `Autocompletion`.

### I just want to use vim default keybindings for autocomplete

You can use the preset that comes with `nvim-cmp`.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

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

You can disable any default keymap by overriding the `mapping` property in `nvim-cmp`. Use `lsp.defaults.cmp_mappings()` to expose the default keybindings then "delete" the one you want. Let's make an example with `Tab`.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

local cmp_mapping = lsp.defaults.cmp_mappings()

-- "unmap" <Tab>
cmp_mapping['<Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mapping
})

lsp.setup()
```

### Adding a source

You can extend the sources by overriding the `sources` property. Use `lsp.defaults.cmp_sources()` to expose the default sources and then insert the new source.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

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
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.setup_nvim_cmp({
  completion = {autocomplete = false}
})

lsp.setup()
```

### The current api is not enough?

Welp, that's interesting. Maybe this is a good time to setup `nvim-cmp` yourself. If you are using the `recommended` preset, change it to `lsp-compe` and then use the function `lsp.defaults.cmp_config()` to extend or change the default configuration table.

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

Finally, in case no one has told you this today... you should read `nvim-cmp`'s documentation. You are awesome. Have a nice day.

