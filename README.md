## Project status

Dead.

It took about 3 years but finally Neovim has solved all the issues that led to the creation of this plugin. Neovim v0.11 can provide [everything you need without installing extra plugins](https://lsp-zero.netlify.app/blog/lsp-config-overview.html).

For those of you that still use Neovim v0.9 or v0.10, the [documentation site](https://lsp-zero.netlify.app/docs/getting-started.html) will teach you about Neovim's LSP client and the plugins that were popular between 2022 and 2024. Do note that the ecosystem is changing and I have no interest in keeping that up to date with the new trends.

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

