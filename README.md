# LSP Zero

A collection of [functions](https://lsp-zero.netlify.app/docs/reference/lua-api.html) for Neovim's LSP client.

<details>

<summary>Expand: showcase</summary>

```lua
-- WARNING: This is not a snippet you want to copy/paste blindly

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
  lsp_zero.buffer_autoformat()
end)

-- Enable a simple tab complete
lsp_zero.omnifunc.setup({
  trigger = '<C-Space>',
  tabcomplete = true,
  use_fallback = true,
  update_on_delete = true,
})

-- For this to work you need to install this:
-- https://github.com/LuaLS/lua-language-server
lsp_zero.new_client({
  cmd = {'lua-language-server'},
  filetypes = {'lua'},
  on_init = function(client)
    lsp_zero.nvim_lua_settings(client, {})
  end,
  root_dir = function(bufnr)
    -- You need Neovim v0.10 to use vim.fs.root
    -- Note: include a .git folder in the root of your Neovim config
    return vim.fs.root(bufnr, {'.git', '.luarc.json', '.luarc.jsonc'})
  end,
})
```

</details>

## Project status

The development of this plugin will stop. And the [documentation site](https://lsp-zero.netlify.app/docs/getting-started.html) is now a wiki that will teach you how to setup Neovim's LSP client. The only section that mentions lsp-zero is the API reference. I'll move this documentation to some other place in the future.

It seems like future versions of Neovim will address (most of) the issues that led to the creation of this plugin. In the current nightly version of Neovim (`v0.11`) is possible to have a [good experience without installing extra plugins](https://lsp-zero.netlify.app/blog/lsp-in-3-steps.html). And even today with Neovim `v0.10` you can have all the features that you need with just 3 plugins (and no, lsp-zero is not one of them), see the example in the [quickstart section](#quickstart-for-the-impatient).

## Documentation

You can browse the documentation here: [lsp-zero.netlify.app/docs](https://lsp-zero.netlify.app/docs/introduction.html)

* [Tutorial for beginners](https://lsp-zero.netlify.app/docs/tutorial.html)
* [Installation and Basic Usage](https://lsp-zero.netlify.app/docs/getting-started.html)
* [LSP Configuration](https://lsp-zero.netlify.app/docs/language-server-configuration.html)
* [Autocomplete](https://lsp-zero.netlify.app/docs/autocomplete.html)

### Migration guides

* [from v3.x](https://lsp-zero.netlify.app/docs/guide/migrate-from-v3-branch.html)
* [from v2.x](https://lsp-zero.netlify.app/docs/guide/migrate-from-v2-branch.html)
* [from v1.x](https://lsp-zero.netlify.app/docs/guide/migrate-from-v1-branch.html)

## Quickstart (for the impatient)

For detailed instructions visit the [getting started](https://lsp-zero.netlify.app/docs/getting-started.html) page or the [tutorial for beginners](https://lsp-zero.netlify.app/docs/tutorial.html).

Make sure you have all these plugins installed.

* [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
* [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
* [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)

The following piece of code should be enough to get a basic setup:

```lua
-- NOTE: to make any of this work you need a language server.
-- If you don't know what that is, watch this 5 min video:
-- https://www.youtube.com/watch?v=LaS32vctfOY

-- Reserve a space in the gutter
vim.opt.signcolumn = 'yes'

-- Add cmp_nvim_lsp capabilities settings to lspconfig
-- This should be executed before you configure any language server
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

-- This is where you enable features that only work
-- if there is a language server active in the file
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

-- You'll find a list of language servers here:
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
-- These are example language servers. 
require('lspconfig').gleam.setup({})
require('lspconfig').ocamllsp.setup({})

local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  snippet = {
    expand = function(args)
      -- You need Neovim v0.10 to use vim.snippet
      vim.snippet.expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({}),
})
```

## Support

If you find this useful and want to support my efforts, you can donate in [ko-fi.com/vonheikemen](https://ko-fi.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1726766343/gzu1l1mx3ou7jmp0tkvt.webp)](https://ko-fi.com/vonheikemen)

