local M = {}
local s = {}

local ok_cmp, cmp = pcall(require, 'cmp')
local select_opts = {behavior = 'select'}
local setup_complete = false

if ok_cmp then
  select_opts = {behavior = cmp.SelectBehavior.Select}
end

function M.extend(opts)
  local defaults = {
    set_lsp_source = true,
    set_mappings = true,
    use_luasnip = true,
    set_format = true,
    documentation_window = true,
  }

  opts = vim.tbl_deep_extend('force', defaults, opts or {})

  require('cmp').setup(M.get_config(opts))
end

function M.get_config(opts)
  local config = M.cmp_config()
  config.mapping = {}

  if opts.set_mappings then
    config.mapping = s.merge(config.mapping, M.basic_mappings())
  end

  if opts.set_lsp_source then
    config.sources = {{name = 'nvim_lsp'}}
  end

  if opts.use_luasnip == false then
    config.snippet = {}
  end

  if opts.set_format == false then
    config.formatting = {}
  end

  if opts.documentation_window == false then
    config.window.documentation = nil
  end

  return config
end

function M.basic_mappings()
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

function M.cmp_config()
  local result = {
    window = {
      documentation = {
        max_height = 15,
        max_width = 60,
      }
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
    }
  }

  local ok_luasnip, luasnip = pcall(require, 'luasnip')

  if ok_luasnip then
    result.snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    }
  end

  return result
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

