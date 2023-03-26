local M = {}
local timeout_ms = 10000
local format_group = 'lsp_zero_format'
local autocmd = [[
  augroup %s
    autocmd! * <buffer>
    autocmd %s %s 
  augroup END
]]

local autoformat_config = {
  timeout_ms = timeout_ms,
  formatting_options = nil,
}

local buffer_default = {
  timeout_ms = timeout_ms,
  formatting_options = nil,
}

local buffer_config = {}

M.format_on_save = function(opts)
  local fmt = string.format
  local setup_id = 'lsp_zero_format_setup'

  opts = opts or {}
  local list = opts.servers or {}
  local format_opts = opts.format_opts or {}

  if type(format_opts.timeout_ms) == 'number' then
    autoformat_config.timeout_ms = format_opts.timeout_ms
  end

  if type(format_opts.formatting_options) == 'table' then
    autoformat_config.formatting_options = format_opts.formatting_options
  end

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
    fmt('lua require("lsp-zero.format").use(%q, false, "on_save")', server)
  ))
end

M.buffer_autoformat = function(client, buffer, opts)
  opts = opts or {}
  local fmt = string.format
  vim.b.lsp_zero_enable_autoformat = 1

  if buffer == nil then
    buffer = vim.api.nvim_get_current_buf()
  end

  local event = fmt('BufWritePre <buffer=%d>', buffer)

  if client == nil then
    if type(opts.timeout_ms) == 'number' then
      vim.b[buffer].lsp_zero_format_timeout = opts.timeout_ms
    end

    if type(opts.formatting_options) == 'table' then
      vim.b[buffer].lsp_zero_formatting_options = opts.formatting_options
    end

    vim.cmd(autocmd:format(
      format_group,
      event,
      'lua require("lsp-zero.format").format_buffer()'
    ))
    return
  end

  local config = {
    timeout_ms = buffer_default.timeout_ms
  }

  if type(opts.timeout_ms) == 'number' then
    config.timeout_ms = opts.timeout_ms
  end

  if type(opts.formatting_options) == 'table' then
    config.formatting_options = opts.formatting_options
  end

  buffer_config[client.name] = config

  vim.cmd(autocmd:format(
    format_group,
    event,
    fmt('lua require("lsp-zero.format").use(%q, false, "buffer")', client.name)
  ))
end

M.apply_format = function(server, buffer, opts)
  local active = vim.lsp.get_active_clients({bufnr = buffer, name = server})[1]

  if active == nil then
    return
  end

  opts = opts or {}
  local config = {
    async = false,
    timeout_ms = timeout_ms,
    id = active.id,
    bufnr = buffer
  }

  if opts.timeout_ms then
    config.timeout_ms = opts.timeout_ms
  end

  if opts.formatting_options then
    config.formatting_options = opts.formatting_options
  end

  vim.lsp.buf.format(config)
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
  local format_opts = opts.format_opts or {}

  if vim.tbl_isempty(list) then
    return
  end

  local filetype_setup = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    local files = list[client.name]

    if type(files) == 'string' then
      files = {list[client.name]}
    end

    if files == nil or not vim.tbl_contains(files, vim.bo.filetype) then
      return
    end

    local config = {
      async = false,
      timeout_ms = timeout_ms,
      id = client.id,
      bufnr = event.buf
    }

    if format_opts.async then
      config.async = format_opts.async
    end

    if format_opts.timeout_ms then
      config.timeout_ms = format_opts.timeout_ms
    end

    if format_opts.formatting_options then
      config.formatting_options = format_opts.formatting_options
    end

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
  local cmd = 'LspZeroFormatBind'

  local keymap = {
    n = 'nnoremap <buffer> %s <cmd>%s %s<cr>',
    x = 'xnoremap <buffer> %s :%s %s<cr>',
    s = "snoremap <buffer> %s <Esc><cmd>'<,'>%s %s <cr>",
    v = "vnoremap <buffer> %s <Esc><cmd>'<,'>%s %s<cr>",
    i = 'inoremap <buffer> %s <cmd>%s %s<cr>',
  }

  local list = opts.servers or {}
  local mode = opts.mode or {'n', 'x'}
  local format_opts = opts.format_opts or {}

  M.setup_format_bind(cmd, format_opts)

  vim.cmd(string.format('augroup %s', group))

  for server, files in pairs(list) do
    local pattern

    if type(files) == 'table' then
      pattern = table.concat(files, ',')
    elseif type(files) == 'string' then
      pattern = files
    end

    for _, m in ipairs(mode) do
      local mapping = keymap[m]
      if mapping then
        local exec = mapping:format(key, cmd, server)
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


  if not client.supports_method('textDocument/formatting') and verbose then
    local msg = '[lsp-zero] %s does not support textDocument/formatting method'
    vim.notify(msg:format(server), vim.log.levels.WARN)
    return false, -1
  end

  return client, buffer
end

local ensure_enabled = function(fn)
  return function(...)
    local autoformat = vim.b.lsp_zero_enable_autoformat
    local enable = autoformat == 1 or autoformat == true
    if not enable then
      return
    end
    fn(...)
  end
end

M.apply_fallback = function(client, buffer, opts)
  opts = opts or {}
  local timeout = opts.timeout_ms or timeout_ms

  local params = vim.lsp.util.make_formatting_params(opts.formatting_options)
  local response = client.request_sync(
    'textDocument/formatting',
    params,
    timeout,
    buffer
  )

  if response and response.result then
    vim.lsp.util.apply_text_edits(response.result, buffer, client.offset_encoding)
  end
end

M.apply_range_fallback = function(client, buffer, opts)
  opts = opts or {}
  local timeout = opts.timeout_ms or timeout_ms
  local config = opts.formatting_options

  local params = vim.lsp.util.make_given_range_params()
  params.options = vim.lsp.util.make_formatting_params(config).options

  local response = client.request_sync(
    'textDocument/rangeFormatting',
    params,
    timeout,
    buffer
  )

  if response and response.result then
    vim.lsp.util.apply_text_edits(response.result, buffer, client.offset_encoding)
  end
end

M.apply_async_fallback = function(client, buffer, opts)
  opts = opts or {}
  local params = vim.lsp.util.make_formatting_params(opts.formatting_options)
  client.request('textDocument/formatting', params, nil, buffer)
end

M.apply_async_range_fallback = function(client, buffer, opts)
  opts = opts or {}
  local config = opts.formatting_options
  local params = vim.lsp.util.make_given_range_params()
  params.options = vim.lsp.util.make_formatting_params(config).options

  client.request('textDocument/rangeFormatting', params, nil, buffer)
end

M.setup_format_bind = function(name, opts)
  opts = opts or {}
  local command = function(name, attr, str)
    vim.cmd(string.format('command! -buffer %s %s lua %s', attr, name, str))
  end

  M.bind_opts = {
    async = false,
    timeout_ms = timeout_ms,
    formatting_options = {}
  }

  if type(opts.formatting_options) == 'table' then
    M.bind_opts.formatting_options = opts.formatting_options
  end

  if opts.async then
    M.bind_opts.async = opts.async
  end

  if opts.timeout_ms then
    M.bind_opts.timeout_ms = opts.timeout_ms
  end

  command(
    name,
    '-range -bang -nargs=1',
    "require('lsp-zero.format').format_bind(<line1>, <line2>, <count>, {<f-args>})"
  )
end

M.format_bind = function(line1, line2, count, args)
  local server = args[1]
  local active = vim.lsp.get_active_clients()
  local client = vim.tbl_filter(function(c)
    return c.name == server
  end, active)[1]

  if client == nil then
    return
  end

  local has_range = line2 == count
  local async = M.bind_opts.async
  local timeout = M.bind_opts.timeout_ms
  local config = M.bind_opts.formatting_options
  local buffer = vim.api.nvim_get_current_buf()

  local execute = M.apply_fallback

  if has_range then
    execute = M.apply_range_fallback
  end

  if async then
    if has_range then
      execute = M.apply_async_range_fallback
    else
      execute = M.apply_async_fallback
    end
  end

  local opts = {timeout_ms = timeout, formatting_options = config}
  execute(client, buffer, opts)
end

M.check = function(server)
  ensure_client(server, true)
end

if vim.lsp.buf.format then
  M.format_mapping = M.keymap_action

  M.use = ensure_enabled(function(server, verbose, context)
    local client, buffer = ensure_client(server, verbose)
    if not client then
      return
    end

    local opts = {}

    if context == 'on_save' then
      opts = autoformat_config
    elseif context == 'buffer' then
      opts = buffer_config[client.name] or buffer_default
    end

    M.apply_format(client, buffer, opts)
  end)

  M.format_buffer = ensure_enabled(function()
    local config = {async = false, timeout_ms = timeout_ms}
    local timeout_ms = vim.b.lsp_zero_format_timeout
    local format_opts = vim.b.lsp_zero_formatting_options

    if timeout then
      config.timeout_ms = timeout_ms
    end

    if format_opts then
      config.formatting_options = format_opts
    end

    vim.lsp.buf.format(config)
  end)

else
  M.format_mapping = M.keymap_fallback

  M.use = ensure_enabled(function(server, verbose, context)
    local client, buffer = ensure_client(server, verbose)
    if not client then
      return
    end

    local opts = {}

    if context == 'on_save' then
      opts = autoformat_config
    elseif context == 'buffer' then
      opts = buffer_config[client.name] or buffer_default
    end

    M.apply_fallback(client, buffer, opts)
  end)

  M.format_buffer = ensure_enabled(function()
    local config = {timeout_ms = timeout_ms}
    local timeout_ms = vim.b.lsp_zero_format_timeout
    local format_opts = vim.b.lsp_zero_formatting_options

    if timeout then
      config.timeout_ms = timeout_ms
    end

    if format_opts then
      config.formatting_options = format_opts
    end

    vim.lsp.buf.formatting_seq_sync(
      config.formatting_options,
      config.timeout_ms
    )
  end)
end

return M

