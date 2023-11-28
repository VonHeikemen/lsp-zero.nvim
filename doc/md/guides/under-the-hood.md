I realize some people would want to know what happens under the hood when they use the recommended configuration.

Okay, so this thing.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
  },
})
```

Will turn into something very close to this.

```lua
---
-- LSP Support
---

local lspconfig = require('lspconfig')

lspconfig.util.on_setup = lspconfig.util.add_hook_after(
  lspconfig.util.on_setup,
  function(config, user_config)
    config.capabilities = vim.tbl_deep_extend(
      'force',
      config.capabilities,
      require('cmp_nvim_lsp').default_capabilities(),
      vim.tbl_get(user_config, 'capabilities') or {}
    )
  end
)

local function lsp_settings()
  vim.diagnostic.config({
    float = {border = 'rounded'},
  })

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    {border = 'rounded'}
  )

  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {border = 'rounded'}
  )

  local command = vim.api.nvim_create_user_command

  command('LspWorkspaceAdd', function()
    vim.lsp.buf.add_workspace_folder()
  end, {desc = 'Add folder to workspace'})

  command('LspWorkspaceList', function()
    vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, {desc = 'List workspace folders'})

  command('LspWorkspaceRemove', function()
    vim.lsp.buf.remove_workspace_folder()
  end, {desc = 'Remove folder from workspace'})
end

local function lsp_format(input)
  local name
  local async = input.bang

  if input.args ~= '' then
    name = input.args
  end

  vim.lsp.buf.format({async = async, name = name})
end

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local bufnr = event.buf
    local map = function(m, lhs, rhs)
      local opts = {buffer = bufnr}
      vim.keymap.set(m, lhs, rhs, opts)
    end

    vim.api.nvim_buf_create_user_command(
      bufnr,
      'LspFormat',
      lsp_format,
      {
        bang = true,
        nargs = '?',
        desc = 'Format buffer with language server'
      }
    )

    -- LSP actions
    map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
    map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
    map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
    map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')
    map('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')
    map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')
    map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
    map('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')
    map({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>')
    map('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
    map('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')

    -- Diagnostics
    map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
    map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
    map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>') 
  end
})


lsp_settings()

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server)
      require('lspconfig')[server].setup({})
    end,
  },
})


---
-- Autocompletion
---

local cmp = require('cmp')

local cmp_config = {
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = {
    -- confirm selection
    ['<C-y>'] = cmp.mapping.confirm({select = false}),

    -- cancel completion
    ['<C-e>'] = cmp.mapping.abort(),

    -- navigate items on the list
    ['<Up>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
    ['<Down>'] = cmp.mapping.select_next_item({behavior = 'select'}),

    -- if completion menu is visible, go to the previous item
    -- else, trigger completion menu
    ['<C-p>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item({behavior = 'insert'})
      else
        cmp.complete()
      end
    end),

    -- if completion menu is visible, go to the next item
    -- else, trigger completion menu
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
      luasnip.lsp_expand(args.body)
    end,
  },
}

cmp.setup(cmp_config)
```

