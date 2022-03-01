# Advance usage

## Changing sign icons

After setting the preset you are allowed to override the icons shown in the gutter for diagnostics.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.set_preferences({
  sign_icons = {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = ''
  }
})
```

## Yes, you can override the settings of a preset

Be careful though. If you are going to override a preset do it right after calling `.preset()`.

I say it's safe to play around with these settings after you declare a preset.

* `set_lsp_keymaps`

* `configure_diagnostics`

* `sign_icons`

The rest? Well... I just hope you know what you are doing. If you have any questions you can stop by the [discussions](https://github.com/VonHeikemen/lsp-zero.nvim/discussions) page.

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
    debounce_text_changes = 500,
  },
  on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
  end
})

-- the function below will be executed whenever
-- a language server is attached to a buffer
lsp.on_attach(function(client, bufnr)
  local noremap = {noremap = true}
  local map = function(...) vim.api.nvim_buf_set_keymap(0, ...) end

  map('n', 'Q', ':lua print("hello")<cr>', noremap)
end)

-- setup must be the last function
-- this one does all the things
lsp.setup()
```

## Customizing nvim-cmp

Using `setup_nvim_cmp` will allow you to override some options of `nvim-cmp`. Here's a few useful things you can do.

### Setting up sources

Using the `sources` option you can specify the priority of each source by changing the order. You could also include new ones. Basically, do whatever you want. Check out `nvim-cmp`'s documentation to know what are the possibilities.

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

We can change that too. There's the `documentation` option. Is the same as `nvim-cmp`. And these are the defaults.

```lua
local lsp = require('lsp-zero')
lsp.preset('recommended')

lsp.setup_nvim_cmp({
  -- change any of it to whatever you like
  documentation = {
    maxheight = 15,
    maxwidth = 50,
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
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

The option you want is `mapping`. The trickiest. Here you are going to find yourself in an all or nothing situation, if you choose to use it then **you** are in charge of all mappings, all the defaults will disappear.

Want to know how much fun you can have creating your own mappings? Check out the wiki section [Under the hood](https://github.com/VonHeikemen/lsp-zero.nvim/wiki/Under-the-hood) and scroll down all the way where it says `Autocompletion`.

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

Finally, in case no one has told you this today... you should read `nvim-cmp`'s documentation. You are awesome. Have a nice day.

