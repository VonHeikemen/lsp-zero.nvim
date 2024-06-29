local M = {}

---@class lsp_zero.CmpFormatOpts
---@inlinedoc
---
---Maximum width the text content of the suggestion can have.
---@field max_width? integer
---
---Show extra information about completion item.
---(default: false)
---@field details? boolean

---@param opts lsp_zero.CmpFormatOpts
---@return cmp.FormattingConfig
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

---Contains functions that can be use as mappings in nvim-cmp.
function M.action()
  return require('lsp-zero.cmp-mapping')
end

---@class lsp_zero.CmpExtendOpts
---@inlinedoc
---
---Add cmp_nvim_lsp? as a source. (default: true)
---@field set_lsp_source? boolean
---
---Setup default keymaps.
---(default: true)
---@field set_mappings? boolean 
---
---Setup luasnip to expand snippets.
---(default: true)
---@field use_luasnip? boolean

---Adds the essential configuration options to nvim-cmp.
---@param opts lsp_zero.CmpExtendOpts
function M.extend(opts)
  local defaults = {
    set_lsp_source = true,
    set_mappings = true,
  }

  ---@type lsp_zero.CmpExtendOpts
  opts = vim.tbl_deep_extend('force', defaults, opts or {})
  local cmp = require('cmp')

  local base = {
    sources = {{name = 'nvim_lsp'}},
    mapping = cmp.mapping.preset.insert({})
  }

  ---@type cmp.ConfigSchema
  local config = {}

  if opts.set_lsp_source then
    config.sources = base.sources
  end

  if opts.set_mappings then
    config.mapping = base.mapping
  end

  cmp.setup(config)
end

return M

