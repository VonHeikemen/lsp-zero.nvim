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

  local format = function(config)
    if vim.b.lsp_zero_enable_autoformat == 1 then
      vim.lsp.buf.format(config)
    end
  end

  local filetype_setup = function(server, event)
    local opts = vim.tbl_deep_extend(
      'force',
      {async = false},
      format_opts,
      {
        name = server,
        bufnr = event.buf,
        timeout_ms = timeout_ms,
      }
    )

    vim.api.nvim_clear_autocmds({group = format_group, buffer = event.buf})

    autocmd('BufWritePre', {
      group = format_id,
      buffer = event.buf,
      desc = 'Format current buffer',
      callback = function() format(opts) end
    })
  end

  autocmd('LspAttach', {
    group = setup_id,
    desc = 'Enable format on save',
    callback = function() vim.b.lsp_zero_enable_autoformat = 1 end,
  })

  for server, files in pairs(list) do
    autocmd('FileType', {
      group = setup_id,
      pattern = files,
      desc = 'Setup format on save',
      callback = function(ev) filetype_setup(server, ev) end
    })
  end
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
    if vim.b.lsp_zero_enable_autoformat ~= 1 then
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

