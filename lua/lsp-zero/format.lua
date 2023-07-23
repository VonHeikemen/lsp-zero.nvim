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

  if format_opts.async then
    s.setup_async_format({
      servers = list,
      format_opts = format_opts.formatting_options,
      setup_augroup = setup_id,
      format_augroup = format_id,
      timeout_ms = format_opts.timeout_ms or timeout_ms
    })
    return
  end

  local filetype_setup = function(name, event)
    vim.api.nvim_clear_autocmds({group = format_group, buffer = event.buf})

    local config = vim.tbl_deep_extend(
      'force',
      {
        timeout_ms = timeout_ms,
        formatting_options = {},
      },
      format_opts,
      {
        name = name,
        verbose = false,
      }
    )

    local apply_format = function(e)
      local autoformat = vim.b.lsp_zero_enable_autoformat
      local enabled = (autoformat == nil or autoformat == 1 or autoformat == true)
      if not enabled then
        return
      end

      M.apply_sync(e.buf, config)
    end

    local desc = string.format('Format buffer with %s', name)

    autocmd('BufWritePre', {
      group = format_id,
      buffer = event.buf,
      desc = desc,
      callback = apply_format,
    })
  end

  for name, files in pairs(list) do
    autocmd('FileType', {
      pattern = files,
      group = setup_id,
      desc = 'Enable format on save',
      callback = function(e) filetype_setup(name, e) end,
    })
  end
end

function M.buffer_autoformat(client, bufnr, opts)
  local autocmd = vim.api.nvim_create_autocmd
  local augroup = vim.api.nvim_create_augroup
  local format_id = augroup(format_group, {clear = false})

  opts = opts or {}
  client = client or {}
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local format_opts = opts.format_opts or {}

  vim.api.nvim_clear_autocmds({group = format_group, buffer = bufnr})

  if vim.b.lsp_zero_enable_autoformat == nil then
    vim.b.lsp_zero_enable_autoformat = 1
  end

  local config = vim.tbl_deep_extend(
    'force',
    {
      timeout_ms = timeout_ms,
      formatting_options = {},
    },
    format_opts,
    {
      name = client.name,
      verbose = false
    }
  )

  local apply_format = function(e)
    local autoformat = vim.b.lsp_zero_enable_autoformat
    local enabled = (autoformat == 1 or autoformat == true)
    if not enabled then
      return
    end

    if config.name == nil then
      vim.lsp.buf.formatting_sync(config.formatting_options)
    else
      M.apply_sync(e.buf, config)
    end
  end

  local desc = 'Format current buffer'

  if client.name then
    desc = string.format('Format buffer with %s', client.name)
  end

  autocmd('BufWritePre', {
    group = format_id,
    buffer = bufnr,
    desc = desc,
    callback = apply_format
  })
end

function M.async_autoformat(client, bufnr, opts)
  if type(client) ~= 'table' or client.id == nil then
    return
  end

  if client.supports_method('textDocument/formatting') == false then
    return
  end

  opts = opts or {}
  local autocmd = vim.api.nvim_create_autocmd
  local augroup = vim.api.nvim_create_augroup

  if vim.b.lsp_zero_enable_autoformat == nil then
    vim.b.lsp_zero_enable_autoformat = 1
  end

  local format_id = augroup(format_group, {clear = false})
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local fmt_opts = {}

  if type(opts) == 'table' then
    fmt_opts = opts.formatting_options
  end

  local timeout = opts.timeout_ms or timeout_ms

  vim.api.nvim_clear_autocmds({group = format_group, buffer = bufnr})

  local desc = 'Request format to %s'
  local client_name = client.name or string.format('Client %s', client.id)

  autocmd('BufWritePost', {
    group = format_id,
    desc = desc:format(client_name),
    buffer = bufnr,
    callback = function(e)
      s.request_format(client.id, e.buf, fmt_opts, timeout)
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

  local filetype_setup = function(name, event)
    local config = vim.tbl_deep_extend(
      'force',
      {
        async = false,
        formatting_options = {},
        timeout_ms = timeout_ms,
      },
      format_opts,
      {
        name = name,
        verbose = false
      }
    )

    local exec = function()
      if config.async then
        M.apply_async(event.buf, config)
      else
        M.apply_sync(event.buf, config)
      end
    end

    local desc = string.format('Format buffer with %s', config.name)

    vim.keymap.set(mode, key, exec, {buffer = event.buf, desc = desc})
  end


  for name, files in pairs(list) do
    local desc = string.format('Setup buffer format with %s', name)

    autocmd('FileType', {
      pattern = files,
      group = format_id,
      desc = desc,
      callback = function(e) filetype_setup(name, e) end,
    })
  end
end

function M.check(server)
  local buffer = vim.api.nvim_get_current_buf()

  local client = vim.tbl_filter(
    function(c) return c.name == server end,
    vim.lsp.get_active_clients()
  )[1]

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

function M.apply_sync(bufnr, opts)
  local client = vim.tbl_filter(
    function(c) return c.name == opts.name end,
    vim.lsp.get_active_clients()
  )[1]

  if (
    client == nil or
    vim.lsp.buf_is_attached(bufnr, client.id) == false
  ) then
    local msg = 'Format request failed, no matching language servers'
    if opts.verbose then vim.notify(msg) end
    return
  end

  local params = vim.lsp.util.make_formatting_params(opts.formatting_options)
  local result = client.request_sync(
    'textDocument/formatting',
    params,
    opts.timeout_ms,
    bufnr
  )

  if result and result.result then
    vim.lsp.util.apply_text_edits(result.result, bufnr, client.offset_encoding)
  end
end

function M.apply_async(bufnr, opts)
  local client = vim.tbl_filter(
    function(c) return c.name == opts.name end,
    vim.lsp.get_active_clients()
  )[1]

  if (
    client == nil or
    vim.lsp.buf_is_attached(bufnr, client.id) == false
  ) then
    local msg = 'Format request failed, no matching language servers'
    if opts.verbose then vim.notify(msg) end
    return
  end

  local params = vim.lsp.util.make_formatting_params(opts.formatting_options)
  local timer = vim.loop.new_timer()

  local cleanup = function()
    timer:stop()
    timer:close()
    timer = nil
  end

  local timeout = opts.timeout_ms
  if timeout <= 0 then
    timeout = timeout_ms
  end

  timer:start(timeout, 0, cleanup)

  local encoding = client.offset_encoding
  local handler = function(err, result, ctx)
    if timer == nil or err ~= nil or result == nil  then
      return
    end

    timer:stop()
    timer:close()
    timer = nil

    if not vim.api.nvim_buf_is_loaded(ctx.bufnr) then
      vim.fn.bufload(ctx.bufnr)
    end

    vim.lsp.util.apply_text_edits(result, ctx.bufnr, encoding)
  end

  client.request('textDocument/formatting', params, handler, bufnr)
end

function M.apply_range(bufnr, opts)
  local client = vim.tbl_filter(
    function(c) return c.name == opts.name end,
    vim.lsp.get_active_clients()
  )[1]

  if (
    client == nil or
    vim.lsp.buf_is_attached(bufnr, client.id) == false
  ) then
    local msg = 'Format request failed, no matching language servers'
    if opts.verbose then vim.notify(msg) end
    return
  end

  local config = opts.formatting_options

  local params = vim.lsp.util.make_given_range_params()

  params.options = vim.lsp.util.make_formatting_params(config).options

  local resp = client.request_sync(
    'textDocument/rangeFormatting',
    params,
    opts.timeout_ms,
    bufnr
  )

  if resp and resp.result then
    vim.lsp.util.apply_text_edits(resp.result, bufnr, client.offset_encoding)
  end
end

function M.apply_async_range(bufnr, opts)
  local client = vim.tbl_filter(
    function(c) return c.name == opts.name end,
    vim.lsp.get_active_clients()
  )[1]

  if (
    client == nil or
    vim.lsp.buf_is_attached(bufnr, client.id) == false
  ) then
    local msg = 'Format request failed, no matching language servers'
    if opts.verbose then vim.notify(msg) end
    return
  end

  local params = vim.lsp.util.make_given_range_params()

  local config = opts.formatting_options
  params.options = vim.lsp.util.make_formatting_params(config).options

  local timer = vim.loop.new_timer()

  local cleanup = function()
    timer:stop()
    timer:close()
    timer = nil
  end

  local timeout = opts.timeout_ms
  if timeout <= 0 then
    timeout = timeout_ms
  end

  timer:start(timeout, 0, cleanup)

  local encoding = client.offset_encoding
  local handler = function(err, result, ctx)
    if timer == nil or err ~= nil or result == nil  then
      return
    end

    timer:stop()
    timer:close()
    timer = nil

    if not vim.api.nvim_buf_is_loaded(ctx.bufnr) then
      vim.fn.bufload(ctx.bufnr)
    end

    vim.lsp.util.apply_text_edits(result, ctx.bufnr, encoding)
  end

  client.request('textDocument/rangeFormatting', params, handler, bufnr)
end

function s.setup_async_format(opts)
  local autocmd = vim.api.nvim_create_autocmd

  local filetype_setup = function(name, event)
    vim.api.nvim_clear_autocmds({group = format_group, buffer = event.buf})

    if vim.b.lsp_zero_enable_autoformat == nil then
      vim.b.lsp_zero_enable_autoformat = 1
    end

    autocmd('BufWritePost', {
      group = opts.format_augroup,
      desc = string.format('Request format to %s', name),
      buffer = event.buf,
      callback = function(e)
        local client = vim.tbl_filter(
          function(c) return c.name == name end,
          vim.lsp.get_active_clients()
        )[1]

        if (
          client == nil or
          vim.lsp.buf_is_attached(e.buf, client.id) == false
        ) then
          return
        end


        s.request_format(client.id, e.buf, opts.format_opts, opts.timeout_ms)
      end,
    })
  end

  for name, files in pairs(opts.servers) do
    autocmd('FileType', {
      pattern = files,
      group = opts.setup_augroup,
      desc = 'Setup non-blocking format on save',
      callback = function(e) filetype_setup(name, e) end,
    })
  end
end

function s.request_format(client_id, buffer, format_opts, timeout)
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

  if timeout <= 0 then
    timeout = timeout_ms
  end

  vim.b.lsp_zero_changedtick = vim.b.changedtick
  vim.b.lsp_zero_format_progress = 1
  local timer = vim.loop.new_timer()

  local client = vim.lsp.get_client_by_id(client_id)
  local encoding = client.offset_encoding
  local client_name = client.name
    or string.format('Client %s', client.id)

  local cleanup = vim.schedule_wrap(function()
    timer:stop()
    timer:close()
    timer = nil
    s.format_cleanup(buffer, client_name)
  end)

  timer:start(timeout, 0, cleanup)

  local handler = function(err, result, ctx)
    if timer == nil or timer:get_due_in() == 0 then
      return
    end

    timer:stop()
    timer:close()
    timer = nil

    ctx.userdata = {
      client_name = client_name,
      encoding = encoding,
    }

    s.format_handler(err, result, ctx)
  end

  local params = vim.lsp.util.make_formatting_params(format_opts)
  client.request('textDocument/formatting', params, handler, buffer)
end

function s.format_handler(err, result, ctx)
  -- handler based on the implementation of lsp-format.nvim
  -- see: https://github.com/lukas-reineke/lsp-format.nvim

  local buf_get = vim.api.nvim_buf_get_var
  local buf_set = vim.api.nvim_buf_set_var

  local fmt_var = 'lsp_zero_format_progress'
  local tick_var = 'lsp_zero_changedtick'
  local buffer = ctx.bufnr

  if vim.fn.bufexists(buffer) == 0 then
    return
  end

  if err ~= nil then
    vim.notify('[lsp-zero] Format request failed.', vim.log.levels.WARN)
    buf_set(buffer, fmt_var, 0)
    return
  end

  if result == nil then
    local msg = '[lsp-zero] %s could not format file.'

    vim.notify(msg:format(ctx.userdata.client_name), vim.log.levels.WARN)
    buf_set(buffer, fmt_var, 0)
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
    buf_set(buffer, fmt_var, 0)
    return
  end

  vim.lsp.util.apply_text_edits(result, buffer, ctx.userdata.encoding)
  buf_set(buffer, fmt_var, 0)

  if buffer == vim.api.nvim_get_current_buf() then
    pcall(vim.api.nvim_command, 'noautocmd update')
    buf_set(buffer, tick_var, vim.b.changedtick)
  end
end

function s.format_cleanup(buffer, client_name)
  if vim.fn.bufexists(buffer) == 0 then
    return
  end

  local buf_get = vim.api.nvim_buf_get_var
  local buf_set = vim.api.nvim_buf_set_var

  buf_set(buffer, 'lsp_zero_format_progress', 0)

  local msg = '[lsp-zero] Format request timeout. %s is taking too long to respond.'

  vim.notify(msg:format(client_name), vim.log.levels.WARN)

  local changedtick = buf_get(buffer, 'lsp_zero_changedtick')
  local current_changedtick = buf_get(buffer, 'changedtick')

  if changedtick  == current_changedtick then
    buf_set(buffer, 'lsp_zero_changedtick', changedtick - 1)
  end
end

return M

