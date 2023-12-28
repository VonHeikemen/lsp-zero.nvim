# You might not need lsp-zero

Before we start, let me just say this: if you are willing to make an effort, you don't need any plugins at all. You can use [Neovim's LSP client without plugins](https://vonheikemen.github.io/devlog/tools/neovim-lsp-client-guide/).

But if you do want to have nice things, like automatic setup of language servers, keep reading.

You are going to need these plugins:

* [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) 
* [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim)
* [williamboman/mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)
* [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) 
* [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) 
* [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) 

And then put the pieces together. So the code I'm about to show does the following: Setup some default keybindings. Use mason.nvim and mason-lspconfig.nvim to manage all the language servers. And finally setup nvim-cmp, which is the autocompletion plugin.

```lua
-- note: diagnostics are not exclusive to lsp servers
-- so these can be global keybindings
vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>') 

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}

    -- these will be buffer-local keybindings
    -- because they only work if you have an active language server

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
  end
})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

local default_setup = function(server)
  require('lspconfig')[server].setup({
    capabilities = lsp_capabilities,
  })
end

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {},
  handlers = {
    default_setup,
  },
})

local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({
    -- Enter key confirms completion item
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl + space triggers completion menu
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})
```

If you need a custom config for a language server, add a handler to `mason-lspconfig`. Like this.

```lua
require('mason-lspconfig').setup({
  ensure_installed = {},
  handlers = {
    default_setup,
    lua_ls = function()
      require('lspconfig').lua_ls.setup({
        capabilities = lsp_capabilities,
        ---
        -- This is where you place
        -- your custom config
        ---
      })
    end,
  },
})
```

Here a "handler" is a lua function that we add to the `handlers` option. Notice the name of the handler is `lua_ls`, that is the name of the language server we want to configure. Inside this new lua function we can do whatever we want... but in this particular case what we need to do is use the `lspconfig` to configure `lua_ls`.

Inside the `{}` of `lua_ls.setup()` is where you configure the language server. Some options are apply to all language servers, these are documented in the help page of lspconfig, see `:help lspconfig-setup`. Some options are unique to each language server, these live under a property called `settings`. To know what settings are available, you will need to visit the documentation of the language server you are using.

Here an example using `lua_ls`. This config is specific to Neovim, so that you don't get annoying warnings in your code.

```lua
require('lspconfig').lua_ls.setup({
  capabilities = lsp_capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT'
      },
      diagnostics = {
        globals = {'vim'},
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
        }
      }
    }
  }
})
```

