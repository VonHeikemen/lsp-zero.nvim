local M = {}

function M.setup(opts)
  local desc = 'Attach LSP server'
  local defaults = {capabilities = vim.lsp.protocol.make_client_capabilities()}

  local config = vim.tbl_deep_extend('force', defaults, opts)

  if config.filetypes == nil then
    return
  end

  local get_root = opts.root_dir
  if type(get_root) == 'function' then
    config.root_dir = nil
  end

  if config.name then
    desc = string.format('Attach LSP: %s', config.name)
  end

  local start_client = function()
    if get_root then
      config.root_dir = get_root()
    end

    if config.root_dir then
      vim.lsp.start(config)
    end
  end

  vim.api.nvim_create_autocmd('FileType', {
    group = lsp_cmds,
    pattern = config.filetypes,
    desc = desc,
    callback = start_client
  })
end

return M

