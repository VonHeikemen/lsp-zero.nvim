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
    fmt('lua require("lsp-zero.format").use(%q, false)', server)
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
    fmt('lua require("lsp-zero.format").use(%q, false)', client.name)
  ))
end

M.apply_format = function(server)
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

M.keymap_action = function(key, opts)
  if opts == nil or key == nil then
    return
  end

  local autocmd = vim.api.nvim_create_autocmd
  local augroup = vim.api.nvim_create_augroup
  local format_id = augroup('lsp_zero_format_mapping', {clear = true})

  local list = opts.servers or {}
  local mode = opts.mode or {'n', 'x'}

  if vim.tbl_isempty(list) then
    return
  end

  local filetype_setup = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local files = list[client.name]

    if files == nil or not vim.tbl_contains(files, vim.bo.filetype) then
      return
    end

    local config = {
      async = false,
      timeout_ms = timeout_ms,
      id = client.id,
      bufnr = event.buf
    }

    local exec = function() vim.lsp.buf.format(config) end
    local mapping = '<Plug>(lsp-zero-format)'
    vim.keymap.set({'n', 'x', 'i', 's'}, mapping, exec, {buffer = event.buf})

    local exec = {
      n = 'nnoremap <buffer> %s %s',
      x = 'xnoremap <buffer> %s %s',
      s = 'snoremap <buffer> %s <C-g>%s',
      v = 'vnoremap <buffer> %s %s',
      i = 'inoremap <buffer> %s %s',
    }

    local desc = string.format('Format buffer with %s', client.name)

    for _, m in pairs(mode) do
      if exec[m] then
        vim.cmd(exec[m]:format(key, mapping))
      end
    end

  end

  autocmd('LspAttach', {
    group = format_id,
    desc = string.format('Format buffer with %s', key),
    callback = filetype_setup,
  })
end

M.keymap_fallback = function(key, opts)
  local group = 'lsp_zero_format_mapping'
  local autocmd = 'autocmd %s FileType %s %s'
  local list = opts.servers or {}
  local mode = opts.mode or {'n', 'x'}

  local keymap = {
    n = 'nnoremap <buffer> %s <cmd>LspZeroFormat %s<cr>',
    x = 'xnoremap <buffer> %s :LspZeroFormat %s<cr>',
    s = "snoremap <buffer> %s <Esc><cmd>'<,'>LspZeroFormat %s<cr>",
    v = "vnoremap <buffer> %s <Esc><cmd>'<,'>LspZeroFormat %s<cr>",
    i = 'inoremap <buffer> %s <cmd>LspZeroFormat %s<cr>',
  }

  vim.cmd('augroup ' .. group)

  for server, files in pairs(list) do
    local pattern = table.concat(files, ',')

    for _, m in ipairs(mode) do
      local mapping = keymap[m]
      if mapping then
        local exec = mapping:format(key, server)
        vim.cmd(autocmd:format(group, pattern, exec))
      end
    end
  end

  vim.cmd('augroup END')
end

local ensure_client = function(server, verbose)
  local active = vim.lsp.get_active_clients()
  local buffer = vim.api.nvim_get_current_buf()
  
  local client = vim.tbl_filter(function(c)
    return c.name == server
  end, active)[1]

  if client == nil then
    if verbose then
      local msg = '[lsp-zero] %s is not active'
      vim.notify(msg:format(server), vim.log.levels.WARN)
    end
    return false, -1
  end

  if vim.lsp.buf_is_attached(buffer, client.id) == false then
    if verbose then
      local msg = '[lsp-zero] %s is not active in the current buffer'
      vim.notify(msg:format(server), vim.log.levels.WARN)
    end
    return false, -1
  end

  return client, buffer
end

local ensure_enabled = function(fn)
  return function(...)
    if vim.b.lsp_zero_enable_autoformat ~= 1 then
      return
    end
    fn(...)
  end
end

M.apply_fallback = function(client, buffer)
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

M.apply_range_fallback = function(client, buffer)
  local params = vim.lsp.util.make_given_range_params()
  params.options = vim.lsp.util.make_formatting_params().options

  local response = client.request_sync(
    'textDocument/rangeFormatting',
    params,
    timeout_ms,
    buffer
  )

  if response and response.result then
    vim.lsp.util.apply_text_edits(response.result, buffer, client.offset_encoding)
  end
end

M.apply_async_fallback = function(client, buffer)
  local params = vim.lsp.util.make_formatting_params({})
  client.request('textDocument/formatting', params, nil, buffer)
end

M.apply_async_range_fallback = function(client, buffer)
  local params = vim.lsp.util.make_given_range_params()
  params.options = vim.lsp.util.make_formatting_params().options

  client.request('textDocument/rangeFormatting', params, nil, buffer)
end

if vim.lsp.buf.format then
  M.format_mapping = M.keymap_action

  M.use = ensure_enabled(function(...)
    local client, buffer = ensure_client(...)
    if client then M.apply_format(client, buffer) end
  end)

  M.format_buffer = ensure_enabled(function()
    vim.lsp.buf.format({async = false, timeout_ms = timeout_ms})
  end)

else
  M.format_mapping = M.keymap_fallback

  M.use = ensure_enabled(function(...)
    local client, buffer = ensure_client(...)
    if client then M.apply_fallback(client, buffer) end
  end)

  M.format_buffer = ensure_enabled(function()
    vim.lsp.buf.formatting_seq_sync(nil, timeout_ms)
  end)
end

return M

