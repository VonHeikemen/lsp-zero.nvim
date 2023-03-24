local M = {}
local format_group = 'lsp_zero_format'
local timeout_ms = 10000

function M.format_on_save(opts)
  local autocmd = vim.api.nvim_create_autocmd
  local augroup = vim.api.nvim_create_augroup
  local format_id = augroup(format_group, {clear = true})
  local setup_id = augroup('lsp_zero_format_setup', {clear = true})

  opts = opts or {}
  local list = opts.servers or {}
  local format_opts = opts.format_opts or {}

  local filetype_setup = function(event)
    local autoformat = vim.b.lsp_zero_enable_autoformat
    local enabled = (autoformat == 1 or autoformat == nil or autoformat == true)
    if not enabled then
      return
    end

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local files = list[client.name] or {}

    if not vim.tbl_contains(files, vim.bo.filetype) then
      return
    end

    local config = vim.tbl_deep_extend(
      'force',
      {async = false, timeout_ms = timeout_ms},
      format_opts,
      {id = client.id, bufnr = event.buf}
    )

    vim.api.nvim_clear_autocmds({group = format_group, buffer = event.buf})

    autocmd('BufWritePre', {
      group = format_id,
      buffer = event.buf,
      desc = 'Apply format in current buffer',
      callback = function() vim.lsp.buf.format(config)  end
    })
  end

  autocmd('LspAttach', {
    group = setup_id,
    desc = 'Enable format on save',
    callback = filetype_setup,
  })
end

function M.buffer_autoformat(client, bufnr)
  local autocmd = vim.api.nvim_create_autocmd
  local augroup = vim.api.nvim_create_augroup
  local format_id = augroup(format_group, {clear = false})

  client = client or {}
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  vim.api.nvim_clear_autocmds({group = format_group, buffer = bufnr})

  vim.b.lsp_zero_enable_autoformat = 1

  local format = function()
    local autoformat = vim.b.lsp_zero_enable_autoformat
    local enabled = (autoformat == 1 or autoformat == nil or autoformat == true)
    if not enabled then
      return
    end

    vim.lsp.buf.format({
      async = false,
      timeout_ms = timeout_ms,
      name = client.name,
      bufnr = bufnr
    })
  end

  autocmd('BufWritePre', {
    group = format_id,
    buffer = bufnr,
    desc = 'Format current buffer',
    callback = format
  })
end

return M

