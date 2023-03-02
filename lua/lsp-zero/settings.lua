local M = {}

M.current = require('lsp-zero.preset').defaults()

function M.set(opts)
  if type(opts) == 'table' then
    M.current = vim.tbl_deep_extend('force', M.current, opts)
  end
end

function M.get()
  return M.current
end

return M

