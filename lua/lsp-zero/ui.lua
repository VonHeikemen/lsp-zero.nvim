local M = {}

function M.setup(opts)
  local set_signcolumn = opts.set_signcolumn or true
  local border = opts.border or 'rounded'

  if set_signcolumn and vim.o.signcolumn == 'auto' then
    vim.opt.signcolumn = 'yes'
  end

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    {border = border}
  )

  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {border = border}
  )

  vim.diagnostic.config({
    float = {border = border}
  })
end

return M

