local M = {}
local timeout_ms = 10000
local format_group = 'lsp_zero_format'
local autocmd = [[
  augroup %s
    autocmd! * <buffer>
    autocmd %s %s 
  augroup END
]]

M.format_on_save = function(opts)
  local fmt = string.format
  local setup_id = 'lsp_zero_format_setup'

  opts = opts or {}
  local list = opts.servers or {}

  for server, files in pairs(list) do
    if type(files) == 'table' then
      files = table.concat(files, ',')
    end

    vim.cmd(autocmd:format(
      setup_id,
      fmt('FileType %s', files),
      fmt('lua require("lsp-zero.format").filetype_setup(%q)', server)
    ))
  end
end

M.filetype_setup = function(server)
  local fmt = string.format
  vim.b.lsp_zero_enable_autoformat = 1
  vim.cmd(autocmd:format(
    format_group,
    'BufWritePre <buffer>',
    fmt('lua require("lsp-zero.format").use(%q)', server)
  ))
end

M.buffer_autoformat = function(client, buffer)
  local fmt = string.format
  vim.b.lsp_zero_enable_autoformat = 1

  if buffer == nil then
    buffer = vim.api.nvim_get_current_buf()
  end

  local event = fmt('BufWritePre <buffer=%d>', buffer)

  if client == nil then
    vim.cmd(autocmd:format(
      format_group,
      event,
      'lua require("lsp-zero.format").format_buffer()'
    ))
    return
  end 

  vim.cmd(autocmd:format(
    format_group,
    event,
    fmt('lua require("lsp-zero.format").use(%q)', client.name)
  ))
end

M.apply_format = function(server)
  if vim.b.lsp_zero_enable_autoformat ~= 1 then
    return
  end

  local buffer = vim.api.nvim_get_current_buf()
  local active = vim.lsp.get_active_clients({bufnr = buffer, name = server})[1]

  if active == nil then
    return
  end

  vim.lsp.buf.format({
    async = false,
    timeout_ms = timeout_ms,
    id = active.id,
    bufnr = buffer
  })
end

M.apply_fallback = function(server)
  if vim.b.lsp_zero_enable_autoformat ~= 1 then
    return
  end

  local active = vim.lsp.get_active_clients()
  local buffer = vim.api.nvim_get_current_buf()
  
  local client = vim.tbl_filter(function(c)
    return c.name == server
  end, active)[1]

  if client == nil then
    return
  end

  if vim.lsp.buf_is_attached(buffer, client.id) == false then
    return
  end

  local params = vim.lsp.util.make_formatting_params({})
  local response = client.request_sync(
    'textDocument/formatting',
    params,
    timeout_ms,
    buffer
  )

  if response and response.result then
    vim.lsp.util.apply_text_edits(response.result, buffer, client.offset_encoding)
  end
end

if vim.lsp.buf.format then
  M.use = M.apply_format
  M.format_buffer = function()
    if vim.b.lsp_zero_enable_autoformat ~= 1 then
      return
    end
    vim.lsp.buf.format({async = false, timeout_ms = timeout_ms})
  end
else
  M.use = M.apply_fallback
  M.format_buffer = function()
    if vim.b.lsp_zero_enable_autoformat ~= 1 then
      return
    end
    vim.lsp.buf.formatting_seq_sync(nil, timeout_ms)
  end
end

return M

