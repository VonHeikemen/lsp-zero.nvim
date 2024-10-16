# LSP Zero

Collection of [functions](https://lsp-zero.netlify.app/docs/reference/lua-api.html) and a [documentation site](https://lsp-zero.netlify.app/docs/getting-started.html) that will help you use Neovim's LSP client.

> [!IMPORTANT]
> `v4.x` became the default branch on `August 2024`. If you are here because of a youtube video or some other tutorial, there is a good chance the configuration they show is outdated. The [quickstart section](#quickstart-for-the-impatient) has a example config.

## Demo

In the past most people used lsp-zero to help them setup [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig). This use case doesn't require you to have lsp-zero installed anymore. The steps to make this work are covered in the [getting started](https://lsp-zero.netlify.app/docs/getting-started.html) page.

> See [demo in asciinema](https://asciinema.org/a/636643)

[![php code being edited in neovim](https://github.com/user-attachments/assets/6d414988-d912-4bf0-812a-3c2dad92a472)](https://asciinema.org/a/636643) 

## Documentation

You can browse the documentation here: [lsp-zero.netlify.app/docs](https://lsp-zero.netlify.app/docs/introduction.html)

* [Tutorial for beginners](https://lsp-zero.netlify.app/docs/tutorial.html)
* [Installation and Basic Usage](https://lsp-zero.netlify.app/docs/getting-started.html)
* [LSP Configuration](https://lsp-zero.netlify.app/docs/language-server-configuration.html)
* [Autocomplete](https://lsp-zero.netlify.app/docs/autocomplete.html)

### Upgrade guides

* [from v3.x to v4.x](https://lsp-zero.netlify.app/docs/guide/migrate-from-v3-branch.html)
* [from v2.x to v4.x](https://lsp-zero.netlify.app/docs/guide/migrate-from-v2-branch.html)
* [from v1.x to v4.x](https://lsp-zero.netlify.app/docs/guide/migrate-from-v1-branch.html)

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

### Why is lsp-zero not used there?

Because lsp-zero is not the plugin it used to be back in 2022. And its clear to me now that adding even a tiny layer of abstraction on top of this setup can cause a huge amount of confusion. If you want to know what lsp-zero can do, there is a list of features in the [final section of getting started page](https://lsp-zero.netlify.app/docs/getting-started.html#plot-twist).

For better or worse the documentation is the most valuable thing of lsp-zero. The docs will teach you how to use all the moving pieces of a typical "LSP setup" in Neovim.

## Support

If you find this useful and want to support my efforts, consider leave a tip in [ko-fi.com ☕](https://ko-fi.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1726766343/gzu1l1mx3ou7jmp0tkvt.webp)](https://ko-fi.com/vonheikemen)

