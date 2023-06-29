# Autocompletion

## Introduction

The plugin responsable for autocompletion is [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). This plugin is designed to be unopinionated and modular. What this means for us (the users) is that we have to assemble various pieces to get a good experience.

When using a preset lsp-zero will configure nvim-cmp for you. This config will include a "completion source" to get data from your LSP servers. It will create keybindings to control the completion menu. Setup a snippet engine ([luasnip](https://github.com/L3MON4D3/LuaSnip)) to expand the snippet that come from your LSP server. And finally, it will change the "formatting" of the completion items, it'll add a label that tells the name of the source for that item.

Here is the code lsp-zero will setup for you.

```lua
local cmp = require('cmp')
local cmp_select_opts = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = {
    ['<C-y>'] = cmp.mapping.confirm({select = true}),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<Up>'] = cmp.mapping.select_prev_item(cmp_select_opts),
    ['<Down>'] = cmp.mapping.select_next_item(cmp_select_opts),
    ['<C-p>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item(cmp_select_opts)
      else
        cmp.complete()
      end
    end),
    ['<C-n>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item(cmp_select_opts)
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
  window = {
    documentation = {
      max_height = 15,
      max_width = 60,
    }
  },
  formatting = {
    fields = {'abbr', 'menu', 'kind'},
    format = function(entry, item)
      local short_name = {
        nvim_lsp = 'LSP',
        nvim_lua = 'nvim'
      }

      local menu_name = short_name[entry.source.name] or entry.source.name

      item.menu = string.format('[%s]', menu_name)
      return item
    end,
  },
})
```

## Preset settings

You can control what lsp-zero is going to do with nvim-cmp using a preset. For example, the [minimal](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#minimal) preset has the following settings:

```lua
manage_nvim_cmp = {
  set_sources = 'lsp',
  set_basic_mappings = true,
  set_extra_mappings = false,
  use_luasnip = true,
  set_format = true,
  documentation_window = true,
}
```

If you want to know the details of each property go to [the api reference](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#manage_nvim_cmp). But what this means is you can do stuff like this.

```lua
local lsp = require('lsp-zero').preset({
  manage_nvim_cmp = {
    set_sources = 'recommended'
  }
})
```

In this particular example I'm saying that I want to setup all the "recommended" sources for nvim-cmp.

## Recommended sources

In nvim-cmp a source is a plugin (a neovim plugin) that provides the actual data displayed in the completion menu. If you set `manage_nvim_cmp.set_sources` to the string `'recommended'`, lsp-zero will try to setup the following sources (if they are installed):

* [cmp-buffer](https://github.com/hrsh7th/cmp-buffer): provides suggestions based on the current file.

* [cmp-path](https://github.com/hrsh7th/cmp-path): gives completions based on the filesystem.

* [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip): it shows custom snippets in the suggestions.

* [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp): shows completions send by the language server.

## Keybindings

### Basic mappings

These are the keybindings you get when you enable `manage_nvim_cmp.set_basic_mappings`. They are meant to follow Neovim's default whenever possible.

* `<Ctrl-y>`: Confirms selection.

* `<Ctrl-e>`: Cancel the completion.

* `<Down>`: Navigate to the next item on the list.

* `<Up>`: Navigate to previous item on the list.

* `<Ctrl-n>`: Go to the next item in the completion menu, or trigger completion menu.

* `<Ctrl-p>`: Go to the previous item in the completion menu, or trigger completion menu.

* `<Ctrl-d>`: Scroll down in the item's documentation.

* `<Ctrl-u>`: Scroll up in the item's documentation.

### Extra mappings

These are the keybindings you get when you enable `manage_nvim_cmp.set_extra_mappings`. These enable tab completion and navigation between snippet placeholders.

* `<Ctrl-f>`: Go to the next placeholder in the snippet.

* `<Ctrl-b>`: Go to the previous placeholder in the snippet.

* `<Tab>`: Enables completion when the cursor is inside a word. If the completion menu is visible it will navigate to the next item in the list.

* `<Shift-Tab>`: When the completion menu is visible navigate to the previous item in the list.

## Customizing nvim-cmp

What I actually recommend is using `cmp` directly. Let lsp-zero do the "minimal" config, then use the module `cmp` to add any extra features you want.

Make sure you setup `cmp` after lsp-zero, so you can override every option properly. Like this.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()

local cmp = require('cmp')

cmp.setup({
  ---
  -- Add you own config here...
  ---
})
```

### Use Enter to confirm completion

You'll want to add an entry to the `mapping` option of nvim-cmp. You can assign `<CR>` to the function `cmp.mapping.confirm`.

```lua
-- Make sure you setup `cmp` after lsp-zero

local cmp = require('cmp')

cmp.setup({
  mapping = {
    ['<CR>'] = cmp.mapping.confirm({select = false}),
  }
})
```

In that example `Enter` will only confirm the selected item. You need to select the item before pressing enter.

If you want to confirm without selecting the item, use this.

```lua
['<CR>'] = cmp.mapping.confirm({select = true}),
```

### Adding a source

For this you'll need to configure the `sources` option in nvim-cmp. Is worth mention that each time you configure this option the previous values are lost. So make you sure you include the LSP source in your custom config.

`sources` must be a list of lua tables, and each source must have a `name` property. This name must be the "id" of the source (is not the plugin name). When in doubt search the instructions of the source you want to install.

I know there is an option in lsp-zero that configures `sources` for you, but I don't recommend that anymore (is only there for backwards compatibility with the `v1.x` branch). There is no good way to adjust its behavior so is better if you setup the sources manually.

Here is an example configuration using the [recommended sources](#recommended-sources).

```lua
-- Make sure you setup `cmp` after lsp-zero

local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  }
})
```

Once you have this you can adjust the priority by changing the order of the items in the list. You can delete sources or you can add more.

### Add an external collection of snippets

By default luasnip is configured to expand snippets, and the only snippets you get will come from your LSP server. If you want to load **custom snippets** into the completion menu you need add [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip) as a source in nvim-cmp.

We don't need to write our own snippets, we can download a collection like [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) and then parse them using a luasnip loader.

Here is the code you would need to load `friendly-snippets` into nvim-cmp.

```lua
-- Make sure you setup `cmp` after lsp-zero

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
    {name = 'luasnip'},
  },
  mapping = {
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
  }
})
```

If you want to use [honza/vim-snippets](https://github.com/honza/vim-snippets), you'll have to call a different loader.

```lua
require('luasnip.loaders.from_snipmate').lazy_load()
```
> Note: If you want to make changes to already downloaded language servers, here's how you edit them:

# Making changes to already existing language server snippets
How do you make a changes to already existing snippets?
# Find the language file
1. If you're using Packer, simply open packer_compiled.lua from your /.config/nvim/plugin ,
   and search for the directory of friendly-snippets
   (ex. /home/user/.local/share/nvim/site/pack/packer/start/friendly-snippets/snippets )
2. Once you have found it, cd into it and search for the json of your desired language ex:. html.json
3. Edit snippets or create new ones :)


### Preselect first item

Make the first item in completion menu always be selected.

```lua
-- Make sure you setup `cmp` after lsp-zero

local cmp = require('cmp')

cmp.setup({
  preselect = 'item',
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
})
```

### Basic completions for Neovim's lua api

You can install and configure [cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua) to get completions based on Neovim's lua api.

```lua
-- Make sure you setup `cmp` after lsp-zero

local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
    {name = 'nvim_lua'},
  },
  mapping = {
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
  }
})
```

### Enable "Super Tab"

If the completion menu is visible it will navigate to the next item in the list. If the cursor is on top of a "snippet trigger" it'll expand it. If the cursor can jump to a snippet placeholder, it moves to it. If the cursor is in the middle of a word it displays the completion menu. Else, it acts like a regular `Tab` key.

```lua
-- Make sure you setup `cmp` after lsp-zero

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = {
    ['<Tab>'] = cmp_action.luasnip_supertab(),
    ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
  }
})
```

### Regular tab complete

Trigger the completion menu when the cursor is inside a word. If the completion menu is visible it will navigate to the next item in the list. If the line is empty it acts like a regular `Tab` key.

```lua
-- Make sure you setup `cmp` after lsp-zero

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = {
    ['<Tab>'] = cmp_action.tab_complete(),
    ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
  }
})
```

### Invoke completion menu manually

For this you'll have to disable the `completion.autocomplete` option in nvim-cmp. Then, setup a keybinding to trigger the completion menu.

Here is an example that uses `Ctrl + Space` to trigger completions.

```lua
-- Make sure you setup `cmp` after lsp-zero

local cmp = require('cmp')

cmp.setup({
  completion = {
    autocomplete = false
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),
  }
})
```

### Adding borders to completion menu

Most people just use the preset nvim-cmp offers. You'll need to configure the `window` option. Inside this window property, you can add borders to the completion menu and also the documentation window. Here is the code.

```lua
-- Make sure you setup `cmp` after lsp-zero

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
-- Make sure you setup `cmp` after lsp-zero

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
-- Make sure you setup `cmp` after lsp-zero

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

