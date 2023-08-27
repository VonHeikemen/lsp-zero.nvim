local M = {}

function M.setup(opts)
  local set_signcolumn = opts.set_signcolumn
  local border = opts.border

  if set_signcolumn then
    vim.opt.signcolumn = 'yes'
  end

  if border == nil then
    return
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

