# Lazy loading with lazy.nvim

Lots of you really like this lazy loading business. Let me show you how to defer everything in lsp-zero using [lazy.nvim](https://github.com/folke/lazy.nvim).

<details>
<summary>Expand manual setup of LSP servers: </summary>

```lua
{
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'dev-v3',
    lazy = true,
    config = false,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {'L3MON4D3/LuaSnip'},
    },
    config = function()
      -- Here is where you configure the autocompletion settings.
      require('lsp-zero').extend_cmp()

      -- And you can configure cmp even more, if you want to.
      local cmp = require('cmp')
      local cmp_action = require('lsp-zero.cmp').action() 

      cmp.setup({
        mapping = {
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        }
      })
    end
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    cmd = 'LspInfo',
    event = {'BufReadPre', 'BufNewFile'},
    dependencies = {
      {'hrsh7th/cmp-nvim-lsp'},
    },
    config = function()
      -- This is where all the LSP shenanigans will live

      local lsp = require('lsp-zero').preset({})

      lsp.on_attach(function(client, bufnr)
        lsp.default_keymaps({buffer = bufnr})
      end)

      -- (Optional) Configure lua language server for neovim
      require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

      -- Replace the language servers listed here
      -- with the ones installed in your system
      lsp.setup_servers({'tsserver', 'rust_analyzer'})
    end
  }
}
```

</details>

<details>
<summary>Expand automatic setup of LSP servers: </summary>

```lua
{
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'dev-v3',
    lazy = true,
    config = false,
  },
  {
    'williamboman/mason.nvim',
    cmd = {'Mason', 'MasonInstall', 'MasonUpdate'},
    lazy = true,
    config = true,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {'L3MON4D3/LuaSnip'},
    },
    config = function()
      -- Here is where you configure the autocompletion settings.
      require('lsp-zero').extend_cmp()

      -- And you can configure cmp even more, if you want to.
      local cmp = require('cmp')
      local cmp_action = require('lsp-zero.cmp').action() 

      cmp.setup({
        mapping = {
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
        }
      })
    end
  },

  -- LSP
  {
    'williamboman/mason-lspconfig.nvim',
    cmd = {'LspInfo', 'LspInstall', 'LspStart'},
    event = {'BufReadPre', 'BufNewFile'},
    dependencies = {
      {'neovim/nvim-lspconfig'},
      {'hrsh7th/cmp-nvim-lsp'},
    },
    config = function()
      -- This is where all the LSP shenanigans will live

      local lsp = require('lsp-zero').preset({})

      lsp.on_attach(function(client, bufnr)
        lsp.default_keymaps({buffer = bufnr})
      end)

      require('mason-lspconfig').setup({
        ensure_installed = {'lua_ls'},
        handlers = {
          lsp.default_setup,
          lua_ls = function()
            -- (Optional) Configure lua language server for neovim
            require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
          end,
        }
      })
    end
  }
}
```

</details>
