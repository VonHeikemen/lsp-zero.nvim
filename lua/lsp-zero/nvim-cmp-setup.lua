local M = {}
local s = {}

local cmp = require('cmp')
local luasnip = require('luasnip')
local global_config = require('lsp-zero.settings')

local merge = function(a, b)
  return vim.tbl_deep_extend('force', {}, a, b)
end

local select_opts = {behavior = cmp.SelectBehavior.Select}

M.sources = function()
  return {
    {name = 'path'},
    {name = 'nvim_lsp', keyword_length = 3},
    {name = 'buffer', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
  }
end

M.default_mappings = function()
  return {
    -- confirm selection
    ['<CR>'] = cmp.mapping.confirm({select = true}),

    -- navigate items on the list
    ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
    ['<Down>'] = cmp.mapping.select_next_item(select_opts),

    -- scroll up and down in the completion documentation
    ['<C-f>'] = cmp.mapping.scroll_docs(5),
    ['<C-u>'] = cmp.mapping.scroll_docs(-5),

    -- toggle completion
    ['<C-e>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.close()
        fallback()
      else
        cmp.complete()
      end
    end),

    -- go to next placeholder in the snippet
    ['<C-d>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, {'i', 's'}),

    -- go to previous placeholder in the snippet
    ['<C-b>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {'i', 's'}),

    -- when menu is visible, navigate to next item
    -- when line is empty, insert a tab character
    -- else, activate completion
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item(select_opts)
      elseif s.check_back_space() then
        fallback()
      else
        cmp.complete()
      end
    end, {'i', 's'}),

    -- when menu is visible, navigate to previous item on list
    -- else, revert to default behavior
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item(select_opts)
      else
        fallback()
      end
    end, {'i', 's'}),
  }
end

M.call_setup = function(opts)
  opts = opts or {}

  require('lsp-zero.snippets')

  global_config.cmp_capabilities = true

  vim.opt.completeopt:append('menu')
  vim.opt.completeopt:append('menuone')
  vim.opt.completeopt:append('noselect')

  local config = {
    completion = {
      completeopt = 'menu,menuone,noinsert'
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
  }

  if type(opts.sources) == 'table' then
    config.sources = opts.sources
  else
    config.sources = M.sources()
  end

  if type(opts.mapping) == 'table' then
    config.mapping = opts.mapping
  else
    config.mapping = M.default_mappings()
  end

  config.documentation = {
    maxheight = 15,
    maxwidth = 50,
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
  }

  if type(opts.documentation) == 'table' then
    config.documentation = merge(
      config.documentation,
      opts.documentation or {}
    )
  elseif opts.documentation == false then
    config.documentation = opts.documentation
  end

  config.formatting = merge(
    {
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
    opts.formatting or {}
  )

  cmp.setup(config)
end

s.check_back_space = function()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

return M

