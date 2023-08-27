local M = {}
local s = {}

local select_opts = {behavior = 'select'}
local setup_complete = false

function M.extend(opts)
  if setup_complete then
    return
  end

  local defaults = {
    set_lsp_source = true,
    set_mappings = true,
    use_luasnip = true,
    set_format = true,
    documentation_window = true,
  }

  opts = vim.tbl_deep_extend('force', defaults, opts or {})

  local base = M.base_config()
  local extra = M.extra_config()
  local config = {window = {}}

  if opts.set_lsp_source then
    config.sources = base.sources
  end

  if opts.set_mappings then
    config.mapping = base.mapping
  end

  if opts.use_luasnip then
    config.snippet = base.snippet
  end

  if opts.set_format then
    config.formatting = extra.formatting
  end

  if opts.documentation_window then
    config.window.documentation = extra.window.documentation
  end

  require('cmp').setup(config)

  setup_complete = true
end

function M.base_config()
  return {
    mapping = M.basic_mappings(),
    sources = {{name = 'nvim_lsp'}},
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
  }
end

function M.extra_config()
  return {
    formatting = M.formatting(),
    window = {
      documentation = {
        max_height = 15,
        max_width = 60,
      }
    },
  }
end

function M.basic_mappings()
  local cmp = require('cmp')

  return {
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-y>'] = cmp.mapping.confirm({select = true}),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
    ['<Down>'] = cmp.mapping.select_next_item(select_opts),
    ['<C-p>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item(select_opts)
      else
        cmp.complete()
      end
    end),
    ['<C-n>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item(select_opts)
      else
        cmp.complete()
      end
    end),
  }
end

function M.formatting()
  return {
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
  }
end

function M.action()
  return require('lsp-zero.cmp-mapping')
end

function s.merge(a, b)
  return vim.tbl_deep_extend('force', {}, a, b)
end

function s.check_back_space()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

return M

