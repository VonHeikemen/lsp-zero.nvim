# Autocompletion

## About nvim-cmp

The plugin responsable for autocompletion is [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). nvim-cmp has a concept of "sources", these provide the actual data displayed in neovim. lsp-zero will configure the following sources if they are installed:

* [cmp-buffer](https://github.com/hrsh7th/cmp-buffer): provides suggestions based on the current file.

* [cmp-path](https://github.com/hrsh7th/cmp-path): gives completions based on the filesystem.

* [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip): it shows snippets in the suggestions.

* [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp): show data send by the language server.

* [cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua): provides completions based on neovim's lua api.

## Default keybindings

### Vim's defaults

* `<Ctrl-y>`: Confirms selection.

* `<Ctrl-e>`: Toggles the completion. (Okay, in vim the default just cancels the completion. I set it to toggle).

* `<Up>`: Navigate to previous item on the list.

* `<Down>`: Navigate to the next item on the list.

* `<Ctrl-p>`: Navigate to previous item on the list.

* `<Ctrl-n>`: Navigate to the next item on the list.

### Added mappings

* `<Enter>`: Confirms selection.

* `<Ctrl-u>`: Scroll up in the item's documentation.

* `<Ctrl-f>`: Scroll down in the item's documentation.

* `<Ctrl-d>`: Go to the next placeholder in the snippet.

* `<Ctrl-b>`: Go to the previous placeholder in the snippet.

* `<Tab>`: Enables completion when the cursor is inside a word. If the completion menu is visible it will navigate to the next item in the list.

* `<S-Tab>`: When the completion menu is visible navigate to the previous item in the list.

## Override keybindings

The easiest way to modify the keybindings is using the `mapping` option of [.setup_nvim_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#setup_nvim_cmpopts).

You can get more details about the `mapping` option using the command `:help cmp-mapping`. You can also browse [Under the hood](https://github.com/VonHeikemen/lsp-zero.nvim/wiki/Under-the-hood) section of lsp-zero's wiki.

### Start from scratch

If you want to start with neovim's default and then add your own, use nvim-cmp's preset. Like this:

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

### Change default mapping

If you want to add/change a mapping in lsp-zero's default, do this.

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
    ['<C-e>'] = cmp.mapping.abort(),
  })
})

lsp.setup()
```

### Disable a mapping

Just like before we are going to use [lsp.defaults.cmp_mappings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#defaultscmp_mappingsopts), but now to disable the mapping we use `vim.NIL`.

Here is an example that disables `tab` to autocomplete, and also disables `Enter` to confirm.

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
    ['<CR>'] = vim.NIL,
  })
})

lsp.setup()
```

## Snippets

[friendly-snippets](https://github.com/rafamadriz/friendly-snippets) is the plugin that provides the snippets. And [luasnip](https://github.com/L3MON4D3/LuaSnip/) is the "snippet engine", the thing that expands the snippet and allows you to navigate between snippet placeholders.

Both friendly-snippets and luasnip are optional. But nvim-cmp will give you a warning if you don't setup a snippet engine. If you don't use luasnip then configure a different snippet engine.

### How to disable snippets?

If you already have it all setup then uninstall friendly-snippets and also cmp_luasnip. 

### Change to snippets with snipmate syntax

Uninstall friendly-snippets if you have it. Use [onza/vim-snippets](https://github.com/honza/vim-snippets). Then add the luasnip loader somewhere in your config.

```lua
require('luasnip.loaders.from_snipmate').lazy_load()
```

## Common configurations

### Don't preselect first match

For those who want to use the `Enter` key freely.

```lua
lsp.setup_nvim_cmp({
  preselect = 'none',
  completion = {
    completeopt = 'menu,menuone,noinsert,noselect'
  },
})
```

### Configure a source

There is no good way to add/change/delete a source, there is an ugly way. What you need to do is use [.setup_nvim_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#setup_nvim_cmpopts) and paste the defaults right back in the `sources` option.

```lua
lsp.setup_nvim_cmp({
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp', keyword_length = 1},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  }
})
```

Once you have this in your config you can manipulate them in any way you see fit.

### Trigger completions menu manually

Set the `completion.autocomplete` option to false.

```lua
lsp.setup_nvim_cmp({
  completion = {autocomplete = false}
})
```

### Add borders to completion menu

For this you can't use [.setup_nvim_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#setup_nvim_cmpopts). You'll have to disable the setting `manage_nvim_cmp`. After that use [.defaults.cmp_config()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/api-reference.md#defaultscmp_configopts) to extend/change lsp-zero's default.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = false,
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

Why do I make you do this? I would like to get rid of `.setup_nvim_cmp()` in the future, so any chance I can get to make you stop using it I'll take it. But why? Y'all seem to enjoy customizing nvim-cmp, so the purpose I had for `.setup_nvim_cmp()` is now obsolete. Is okay because you can still use nvim-cmp directly and add lsp-zero's defaults if you want.
