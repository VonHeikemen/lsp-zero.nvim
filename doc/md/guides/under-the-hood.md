I realize some people would want to know what happens under the hood when they use the recommended configuration.

Okay, so this thing.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup_servers({'tsserver', 'rust_analyzer'})

lsp.extend_cmp()
```

Will turn into something very close to this.

```lua
---
-- LSP Support
---

local lspconfig = require('lspconfig')
local lsp_defaults = lspconfig.util.default_config

lsp_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lsp_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local map = function(m, lhs, rhs)
      local opts = {buffer = bufnr}
      vim.keymap.set(m, lhs, rhs, opts)
    end

    local buf_command = vim.api.nvim_buf_create_user_command

    buf_command(bufnr, 'LspFormat', function()
      vim.lsp.buf.format()
    end, {desc = 'Format buffer with language server'})

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

local function lsp_settings()
  vim.diagnostic.config({
    severity_sort = true,
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


lsp_settings()

require('lspconfig').tsserver.setup({})
require('lspconfig').rust_analyzer.setup({})


---
-- Autocompletion
---

local cmp = require('cmp')
local cmp_select_opts = {behavior = cmp.SelectBehavior.Select}

local cmp_config = {
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = {
    -- confirm selection
    ['<C-y>'] = cmp.mapping.confirm({select = true}),

    -- cancel completion
    ['<C-e>'] = cmp.mapping.abort(),

    -- scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-5),
    ['<C-d>'] = cmp.mapping.scroll_docs(5),

    -- navigate items on the list
    ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
    ['<Down>'] = cmp.mapping.select_next_item(select_opts),

    -- if completion menu is visible, go to the previous item
    -- else, trigger completion menu
    ['<C-p>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item(select_opts)
      else
        cmp.complete()
      end
    end),

    -- if completion menu is visible, go to the next item
    -- else, trigger completion menu
    ['<C-n>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item(select_opts)
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
}

cmp.setup(cmp_config)
```

