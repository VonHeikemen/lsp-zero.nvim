local M = {}

local base_setup = false
local setup_complete = false

function M.extend(opts)
  if setup_complete then
    return
  end

  local defaults = {
    set_lsp_source = true,
    set_mappings = true,
    use_luasnip = true,
  }

  opts = vim.tbl_deep_extend('force', defaults, opts or {})

  local base = M.base_config()
  local config = {}

  if opts.set_lsp_source then
    config.sources = base.sources
  end

  if opts.set_mappings then
    config.mapping = base.mapping
  end

  if opts.use_luasnip then
    config.snippet = base.snippet
  end

  require('cmp').setup(config)

  base_setup = true
  setup_complete = true
end

function M.apply_base()
  if base_setup then
    return
  end

  base_setup = true

  if package.loaded['cmp'] == nil then
    require('cmp').setup(M.base_config())
    return
  end

  local cmp = require('cmp')
  local cmp_config = cmp.get_config()
  local base_config = M.base_config()
  local new_config = {}

  if vim.tbl_isempty(cmp_config.sources) then
    new_config.sources = base_config.sources
  end

  if vim.tbl_isempty(cmp_config.mapping) then
    new_config.mapping = base_config.mapping
  end

  local current = cmp_config.snippet.expand
  local lsp_expand = base_config.snippet.expand

  new_config.snippet = {
    expand = function(args)
      local ok = pcall(current, args)
      if not ok then
        current = lsp_expand
        current(args)
      end
    end,
  }

  cmp.setup(new_config)
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

function M.basic_mappings()
  local cmp = require('cmp')

  return {
    ['<C-y>'] = cmp.mapping.confirm({select = false}),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Up>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
    ['<Down>'] = cmp.mapping.select_next_item({behavior = 'select'}),
    ['<C-p>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item({behavior = 'insert'})
      else
        cmp.complete()
      end
    end),
    ['<C-n>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item({behavior = 'insert'})
      else
        cmp.complete()
      end
    end),
  }
end

function M.format(opts)
  opts = opts or {}
  local maxwidth = opts.max_width or false

  local details = type(opts.details) == 'boolean' and opts.details or false

  local fields = details 
    and {'abbr', 'kind', 'menu'}
    or {'abbr', 'menu', 'kind'}

  return {
    fields = fields,
    format = function(entry, item)
      local n = entry.source.name
      local label = ''

      if n == 'nvim_lsp' then
        label = '[LSP]'
      elseif n == 'nvim_lua'  then
        label = '[nvim]'
      else
        label = string.format('[%s]', n)
      end

      if details and item.menu ~= nil then
        item.menu =  string.format('%s %s', label, item.menu)
      else
        item.menu = label
      end

      if maxwidth and #item.abbr > maxwidth then
        local last = item.kind == 'Snippet' and '~' or ''
        item.abbr = string.format(
          '%s %s',
          string.sub(item.abbr, 1, maxwidth),
          last
        )
      end

      return item
    end,
  }
end

function M.action()
  return require('lsp-zero.cmp-mapping')
end

return M

