# Autocompletion

## How does it work?

The plugin responsable for autocompletion is [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). This plugin is designed to be unopinionated and modular. What this means for us (the users) is that we have to assemble various pieces to get the behavior we want.

lsp-zero will configure the basic features for you. This config will include a "completion source" to get data from your LSP servers. It will create keybindings to control the completion menu (following Neovim's default whenever possible). Setup a snippet engine ([luasnip](https://github.com/L3MON4D3/LuaSnip)) to expand the snippet that come from your LSP server.

This is the "backup" configuration lsp-zero will run for you if you don't configure nvim-cmp yourself.

```lua
local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = {
    ['<C-y>'] = cmp.mapping.confirm({select = false}),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Up>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
    ['<Down>'] = cmp.mapping.select_next_item({behavior = 'select'}),
    ['<C-p>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item({behavior = 'insert'})
      else
        cmp.complete()
      end
    end),
    ['<C-n>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item({behavior = 'insert'})
      else
        cmp.complete()
      end
    end),
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})
```

## Keybindings

These are the keybindings lsp-zero enables by default. They are meant to follow Neovim's default.

* `<Ctrl-y>`: Confirms selection.

* `<Ctrl-e>`: Cancel the completion.

* `<Down>`: Navigate to the next item on the list.

* `<Up>`: Navigate to previous item on the list.

* `<Ctrl-n>`: Go to the next item in the completion menu, or trigger completion menu.

* `<Ctrl-p>`: Go to the previous item in the completion menu, or trigger completion menu.

## Customizing nvim-cmp

You must use the module `cmp` to add any extra features you want. Like this.

```lua
local cmp = require('cmp')

cmp.setup({
  ---
  -- Add your own config here...
  ---
})
```

Is important to note lsp-zero's automatic configuration works as a backup. It will only configure the essential options¹ if you forget to set them up yourself.

¹ The essential options are `sources`, `mapping` and `snippet`.

### Adding a source

If you don't know, each source that you add to your configuration is a Neovim plugin that you need to install. The purpose of a source is to extract data and then pass it to nvim-cmp.

Let's say we want to use this source [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer). `cmp-buffer` will extract suggestions from the current file. This will allow nvim-cmp to show completions even when we don't have a language server active in the current buffer.

So the first thing we need to do is install the plugin [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer). Use your favorite plugin manager to do it.

Second step, figure out what is the name of the source. I don't mean the name of the plugin, this is different. Go to the github repo [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer) and look for configuration instructions.

Third step, add the sources you want to use to nvim-cmp's config. For this we need to call the setup function of the `cmp` module, add the `sources` options and list every source we have installed.

```lua
local cmp = require('cmp')
local cmp_format = require('lsp-zero').cmp_format()

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
    {name = 'buffer'},
  },
  --- (Optional) Show source name in completion menu
  formatting = cmp_format,
})
```

Notice we have two sources. The first source, `{name = 'nvim_lsp'}`, belongs to this plugin [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp). You installed that when you configured lsp-zero for the first time. We need to add it here because nvim-cmp will override previous value of the `sources` option. In other words, we need so we don't lose the LSP completions.

`{name = 'buffer'}` is the new plugin [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer). After adding this we can restart Neovim and test it.

### Custom mappings

To add your custom keybindings you must use the option `mapping` in nvim-cmp's settings. In this case is important to use nvim-cmp's preset so you don't lose the default keybindings.

Here is an example.

```lua
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- confirm completion
    ['<C-y>'] = cmp.mapping.confirm({select = true}),

    -- scroll up and down the documentation window
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),   
  })
})
```

### Add an external collection of snippets

By default luasnip is configured to expand snippets, and the only snippets you get will come from your LSP server. If you want to load **custom snippets** into the completion menu you need add [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) as a source in nvim-cmp (if you are not familiar with the concept of source, see the previous section ["Adding a source"](#adding-a-source)).

We don't need to write our own snippets, we can download a collection like [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) and then parse them using a luasnip loader.

Here is the code you would need to load `friendly-snippets` into nvim-cmp.

```lua
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
local cmp_format = require('lsp-zero').cmp_format()

require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
    {name = 'luasnip'},
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
  })
  --- (Optional) Show source name in completion menu
  formatting = cmp_format,
})
```

If you want to use [honza/vim-snippets](https://github.com/honza/vim-snippets), you'll have to call a different loader.

```lua
require('luasnip.loaders.from_snipmate').lazy_load()
```

### Use Enter to confirm completion

You'll want to add an entry to the `mapping` option of nvim-cmp. You can assign `<CR>` to the function `cmp.mapping.confirm`.

```lua
local cmp = require('cmp')

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({select = false}),
  })
})
```

In that example `Enter` will only confirm the selected item. You need to select the item before pressing enter.

If you want to confirm without selecting the item, use this.

```lua
['<CR>'] = cmp.mapping.confirm({select = true}),
```

### Preselect first item

Make the first item in completion menu always be selected.

```lua
local cmp = require('cmp')

cmp.setup({
  preselect = 'item',
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
})
```

### Basic completions for Neovim's lua api

You can install and configure [cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua) to get completions based on Neovim's lua api. If you don't know what is a source in nvim-cmp, see the section "[Adding a source](#adding-a-source)" for more details.

```lua
local cmp = require('cmp')
local cmp_format = require('lsp-zero').cmp_format()

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
    {name = 'nvim_lua'},
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
  })
  --- (Optional) Show source name in completion menu
  formatting = cmp_format,
})
```

### Enable "Super Tab"

If the completion menu is visible it will navigate to the next item in the list. If the cursor is on top of a "snippet trigger" it'll expand it. If the cursor can jump to a snippet placeholder, it moves to it. If the cursor is in the middle of a word it displays the completion menu. Else, it acts like a regular `Tab` key.

```lua
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp_action.luasnip_supertab(),
    ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
  })
})
```

### Regular tab complete

Trigger the completion menu when the cursor is inside a word. If the completion menu is visible it will navigate to the next item in the list. If the line is empty it acts like a regular `Tab` key.

```lua
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp_action.tab_complete(),
    ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
  })
})
```

### Invoke completion menu manually

For this you'll have to disable the `completion.autocomplete` option in nvim-cmp. Then, setup a keybinding to trigger the completion menu.

Here is an example that uses `Ctrl + Space` to trigger completions.

```lua
local cmp = require('cmp')

cmp.setup({
  completion = {
    autocomplete = false
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
  })
})
```

### Adding borders to completion menu

Most people just use the preset nvim-cmp offers. You'll need to configure the `window` option. Inside this window property, you can add borders to the completion menu and also the documentation window. Here is the code.

```lua
local cmp = require('cmp')

cmp.setup({
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  }
})
```

### Change formatting of completion item

There is an option called `formatting`, that's the one you want. With this option you can change the order of the "elements" inside a completion item, and you can also add a function that changes the text of each element.

Customizing the format requires some knowledge about lua, 'cause you have to implement the behavior you want. Or you can use a plugin like [lsp-kind](#lsp-kind).

Here is a basic example that adds icons based on the name of the source.

```lua
local cmp = require('cmp')

cmp.setup({
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
```

### lsp-kind

[lspkind.nvim](https://github.com/onsails/lspkind.nvim) should work.

```lua
local cmp = require('cmp')

cmp.setup({
  formatting = {
    fields = {'abbr', 'kind', 'menu'},
    format = require('lspkind').cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50, -- prevent the popup from showing more than provided characters
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
    })
  }
})
```

