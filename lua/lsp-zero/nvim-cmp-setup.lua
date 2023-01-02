local M = {}
local s = {}

local ok_cmp, cmp = pcall(require, 'cmp')
local ok_luasnip, luasnip = pcall(require, 'luasnip')
local global_config = require('lsp-zero.settings')
local select_opts = {}

if not ok_cmp then
  local msg = "[lsp-zero] Could not find nvim-cmp. Please install nvim-cmp or set the option `manage_nvim_cmp` to false."
  vim.notify(msg, vim.log.levels.WARN)
else
  select_opts = {behavior = cmp.SelectBehavior.Select}
end

local merge = function(a, b)
  return vim.tbl_deep_extend('force', {}, a, b)
end

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
    ['<CR>'] = cmp.mapping.confirm({select = false}),
    ['<C-y>'] = cmp.mapping.confirm({select = false}),

    -- navigate items on the list
    ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
    ['<Down>'] = cmp.mapping.select_next_item(select_opts),
    ['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
    ['<C-n>'] = cmp.mapping.select_next_item(select_opts),

    -- scroll up and down in the completion documentation
    ['<C-f>'] = cmp.mapping.scroll_docs(5),
    ['<C-u>'] = cmp.mapping.scroll_docs(-5),

    -- toggle completion
    ['<C-e>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.abort()
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

M.cmp_config = function()
  return {
    sources = M.sources(),
    preselect = cmp.PreselectMode.Item,
    mapping = M.default_mappings(),
    completion = {
      completeopt = 'menu,menuone,noinsert'
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    window = {
      documentation = merge(
        cmp.config.window.bordered(),
        {
          max_height = 15,
          max_width = 60,
        }
      )
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
end

M.call_setup = function(opts)
  if not ok_cmp then
    return
  end

  opts = opts or {}

  if type(opts.select_behavior) == 'string' then
    select_opts = {behavior = opts.select_behavior}
  end

  local config = M.cmp_config()

  if not ok_luasnip then
    config.snippet = nil
    if global_config[1] == 'recommended' then
      local msg = "[lsp-zero] Could not find luasnip. Snippet expansion will not work if luasnip is not installed."
      vim.notify(msg, vim.log.levels.WARN)
    end
  end

  global_config.cmp_capabilities = true

  -- Apparently this can fail
  pcall(function()
    vim.opt.completeopt:append('menu')
    vim.opt.completeopt:append('menuone')
    vim.opt.completeopt:append('noselect')
  end)

  if type(opts.sources) == 'table' then
    config.sources = opts.sources
  end

  if type(opts.mapping) == 'table' then
    config.mapping = opts.mapping
  end

  if type(opts.documentation) == 'table' then
    config.window.documentation = merge(
      config.window.documentation,
      opts.documentation
    )
  elseif opts.documentation == false then
    config.window.documentation = cmp.config.disable
  end

  if type(opts.completion) == 'table' then
    config.completion = merge(config.completion, opts.completion)
  end

  if type(opts.formatting) == 'table' then
    config.formatting = merge(config.formatting, opts.formatting)
  end

  if opts.preselect ~= nil then
    config.preselect = opts.preselect
  end

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

