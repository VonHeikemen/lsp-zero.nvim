local M = {}
local format_group = 'lsp_zero_format'

M.format_on_save = function(opts)
  local setup_id = 'lsp_zero_format_setup'

  opts = opts or {}
  local list = opts.servers or {}

  for server, files in pairs(list) do
    local ft = [[
      augroup %s
        autocmd! * <buffer>
        autocmd FileType %s lua require('lsp-zero.format').filetype_setup(%q)
      augroup END
    ]]
    
    if type(files) == 'table' then
      files = table.concat(files, ',')
    end

    vim.cmd(ft:format(setup_id, files, server))
  end
end

M.filetype_setup = function(server)
  vim.b.lsp_zero_enable_autoformat = 1

  local bw = [[
    augroup %s
      autocmd! * <buffer>
      autocmd BufWritePre <buffer> lua require("lsp-zero.format").apply(%q)
    augroup END
  ]]

  vim.cmd(bw:format(format_group, server))
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

  vim.lsp.buf.format({async = false, id = active.id, bufnr = buffer})
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
    10000, -- 10 seconds
    buffer
  )

  if response and response.result then
    vim.lsp.util.apply_text_edits(response.result, buffer, client.offset_encoding)
  end
end

M.apply = vim.lsp.buf.format and M.apply_format or M.apply_fallback

return M

