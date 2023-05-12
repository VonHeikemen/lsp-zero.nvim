local M = {}
local s = {}
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

  if opts.format_opts.async then
    s.setup_async_format({
      servers = list,
      format_opts = format_opts.formatting_options,
      setup_augroup = setup_id,
      format_augroup = format_id,
    })
    return
  end

  local filetype_setup = function(event)
    local client_id = vim.tbl_get(event, 'data', 'client_id')
    if client_id == nil then
      -- I don't know how this would happen
      -- but apparently it can happen
      return
    end

    local client = vim.lsp.get_client_by_id(client_id)
    local files = list[client.name] or {}

    if type(files) == 'string' then
      files = {list[client.name]}
    end

    if files == nil or vim.tbl_contains(files, vim.bo.filetype) == false then
      return
    end

    vim.api.nvim_clear_autocmds({group = format_group, buffer = event.buf})

    local config = vim.tbl_deep_extend(
      'force',
      {timeout_ms = timeout_ms},
      format_opts,
      {
        async = false,
        id = client.id,
        bufnr = event.buf,
      }
    )

    local apply_format = function()
      local autoformat = vim.b.lsp_zero_enable_autoformat
      local enabled = (autoformat == nil or autoformat == 1 or autoformat == true)
      if not enabled then
        return
      end

      vim.lsp.buf.format(config)
    end

    local desc = string.format('Format buffer with %s', client.name)

    autocmd('BufWritePre', {
      group = format_id,
      buffer = event.buf,
      desc = desc,
      callback = apply_format,
    })
  end

  autocmd('LspAttach', {
    group = setup_id,
    desc = 'Enable format on save',
    callback = filetype_setup,
  })
end

function M.buffer_autoformat(client, bufnr, format_opts)
  local autocmd = vim.api.nvim_create_autocmd
  local augroup = vim.api.nvim_create_augroup
  local format_id = augroup(format_group, {clear = false})

  client = client or {}
  format_opts = format_opts or {}
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  vim.api.nvim_clear_autocmds({group = format_group, buffer = bufnr})

  vim.b.lsp_zero_enable_autoformat = 1

  local config = vim.tbl_deep_extend(
    'force',
    {timeout_ms = timeout_ms},
    format_opts,
    {
      async = false,
      name = client.name,
      bufnr = bufnr,
    }
  )

  local apply_format = function()
    local autoformat = vim.b.lsp_zero_enable_autoformat
    local enabled = (autoformat == 1 or autoformat == true)
    if not enabled then
      return
    end

    vim.lsp.buf.format(config)
  end

  autocmd('BufWritePre', {
    group = format_id,
    buffer = bufnr,
    desc = 'Format current buffer',
    callback = apply_format
  })
end

function M.async_autoformat(client, bufnr, format_opts)
  if type(client) ~= 'table' or client.id == nil then
    return
  end

  if client.supports_method('textDocument/formatting') == false then
    return
  end

  local autocmd = vim.api.nvim_create_autocmd
  local augroup = vim.api.nvim_create_augroup

  if vim.b.lsp_zero_enable_autoformat == nil then
    vim.b.lsp_zero_enable_autoformat = 1
  end

  local format_id = augroup(format_group, {clear = false})
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local fmt_opts = {}

  if type(format_opts) == 'table' then
    fmt_opts = format_opts
  end

  vim.api.nvim_clear_autocmds({group = format_group, buffer = bufnr})

  local desc = 'Format buffer using %s'

  autocmd('BufWritePost', {
    group = format_id,
    desc = desc:format(client.name or client.id),
    buffer = bufnr,
    callback = function(e)
      s.request_format(client.id, e.buf, fmt_opts)
    end,
  })
end

function M.format_mapping(key, opts)
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
    local client_id = vim.tbl_get(event, 'data', 'client_id')
    if client_id == nil then
      -- I don't know how this would happen
      -- but apparently it can happen
      return
    end

    local client = vim.lsp.get_client_by_id(client_id)
    local files = list[client.name]

    if type(files) == 'string' then
      files = {list[client.name]}
    end

    if files == nil or vim.tbl_contains(files, vim.bo.filetype) == false then
      return
    end

    local config = vim.tbl_deep_extend(
      'force',
      {async = false, timeout_ms = timeout_ms},
      format_opts,
      {id = client.id, bufnr = event.buf}
    )

    local exec = function() vim.lsp.buf.format(config) end
    local desc = string.format('Format buffer with %s', client.name)

    vim.keymap.set(mode, key, exec, {buffer = event.buf, desc = desc})
  end

  local desc = string.format('Format buffer with %s', key)

  autocmd('LspAttach', {
    group = format_id,
    desc = desc,
    callback = filetype_setup,
  })
end

function M.check(server)
  local buffer = vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_active_clients({bufnr = buffer, name = server})[1]

  if client == nil then
    local msg = '[lsp-zero] %s is not active'
    vim.notify(msg:format(server), vim.log.levels.WARN)
    return
  end

  if vim.lsp.buf_is_attached(buffer, client.id) == false then
    local msg = '[lsp-zero] %s is not active in the current buffer'
    vim.notify(msg:format(server), vim.log.levels.WARN)
    return
  end

  if client.supports_method('textDocument/formatting') == false then
    local msg = '[lsp-zero] %s does not support textDocument/formatting method'
    vim.notify(msg:format(server), vim.log.levels.WARN)
    return
  end

  local msg = '[lsp-zero] %s has formatting capabilities'
  vim.notify(msg:format(server))
end

function s.setup_async_format(opts)
  local autocmd = vim.api.nvim_create_autocmd

  local filetype_setup = function(event)
    local client_id = vim.tbl_get(event, 'data', 'client_id')
    if client_id == nil then
      -- I don't know how this would happen
      -- but apparently it can happen
      return
    end

    local client = vim.lsp.get_client_by_id(client_id)
    local files = opts.servers[client.name] or {}

    if type(files) == 'string' then
      files = {opts.servers[client.name]}
    end

    if files == nil or vim.tbl_contains(files, vim.bo.filetype) == false then
      return
    end

    if client.supports_method('textDocument/formatting') == false then
      return
    end

    vim.api.nvim_clear_autocmds({group = format_group, buffer = event.buf})

    if vim.b.lsp_zero_enable_autoformat == nil then
      vim.b.lsp_zero_enable_autoformat = 1
    end

    autocmd('BufWritePost', {
      group = opts.format_augroup,
      desc = string.format('Request format to %s', client.name),
      buffer = event.buf,
      callback = function(e)
        s.request_format(client_id, e.buf, opts.format_opts)
      end,
    })
  end

  autocmd('LspAttach', {
    group = opts.setup_augroup,
    desc = 'Setup non-blocking format on save',
    callback = filetype_setup,
  })
end

function s.request_format(client_id, buffer, format_opts)
  if vim.b.lsp_zero_format_progress == 1 then
    local msg = '[lsp-zero] A formatting request is already in progress.'
    vim.notify(msg, vim.log.levels.WARN)
    return
  end

  local autoformat = vim.b.lsp_zero_enable_autoformat
  local enabled = (autoformat == 1 or autoformat == true)
  if not enabled then
    return
  end

  if vim.b.lsp_zero_changedtick == vim.b.changedtick then
    return
  end

  vim.b.lsp_zero_changedtick = vim.b.changedtick
  vim.b.lsp_zero_format_progress = 0

  local params = vim.lsp.util.make_formatting_params(format_opts)
  local client = vim.lsp.get_client_by_id(client_id)
  client.request('textDocument/formatting', params, s.format_handler, buffer)
end

function s.format_handler(err, result, ctx)
  -- handler based on the implementation of lsp-format.nvim
  -- see: https://github.com/lukas-reineke/lsp-format.nvim

  local buf_get = vim.api.nvim_buf_get_var
  local buf_set = vim.api.nvim_buf_set_var

  if err ~= nil then
    vim.notify('[lsp-zero] Format request failed', vim.log.levels.WARN)
    return
  end

  local fmt_var = 'lsp_zero_format_progress'
  local tick_var = 'lsp_zero_changedtick'
  local buffer = ctx.bufnr

  if result == nil or vim.fn.bufexists(buffer) == 0 then
    return
  end

  local current_changedtick = buf_get(buffer, 'changedtick')

  if not vim.api.nvim_buf_is_loaded(buffer) then
    vim.fn.bufload(buffer)
    buf_set(buffer, tick_var, current_changedtick)
  end

  local buf_changedtick = buf_get(buffer, tick_var)

  if current_changedtick ~= buf_changedtick then
    local msg = '[lsp-zero] Format canceled. Buffer was modified after request.'
    vim.notify(msg, vim.log.levels.WARN)
    return
  end

  vim.lsp.util.apply_text_edits(result, buffer, 'utf-16')
  buf_set(buffer, fmt_var, 0)

  if buffer == vim.api.nvim_get_current_buf() then
    pcall(vim.api.nvim_command, 'noautocmd update')
    buf_set(buffer, tick_var, vim.b.changedtick)
  end
end

return M

