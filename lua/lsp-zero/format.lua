---@class lsp_zero.config.FormatOnSave
---@inlinedoc
---
---Key/value pair list. On the left hand side you specify the name of
--language server. On the right hand side you provide a list of filetypes.
---@field servers table<string, string|string[]>
---
---Configuration that will passed to the formatting function.
---@field format_opts? lsp_zero.config.BufFormatOpts

---@class lsp_zero.config.BufFormatOpts
---@inlinedoc
---
---If true the method won't block the editor.
---@field async? boolean
---
---Can be used to specify FormattingOptions send to the language server.
---@field formatting_options? table
---
---Time in milliseconds to block for formatting requests.
---@field timeout_ms? integer

---@class lsp_zero.config.FormatOpts
---@inlinedoc
---
---Can be used to specify FormattingOptions send to the language server.
---@field formatting_options? table
---
---Time in milliseconds to block for formatting requests.
---@field timeout_ms? integer

local M = {}
local s = {}
local uv = vim.uv or vim.loop
local format_group = 'lsp_zero_format'
local timeout_ms = 10000

---@param opts lsp_zero.config.FormatOnSave
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

  local filetype_setup = function(event)
    local client_id = vim.tbl_get(event, 'data', 'client_id')
    local client = client_id and vim.lsp.get_client_by_id(client_id)

    if client == nil then
      -- I don't know how this would happen
      -- but apparently it can happen
      return
    end

    local files = list[client.name] or {}

    if type(files) == 'string' then
      files = {files}
    end

    if files == nil or vim.tbl_contains(files, vim.bo.filetype) == false then
      return
    end

    vim.api.nvim_clear_autocmds({group = format_group, buffer = event.buf})

    local config = {
      async = false,
      id = client.id,
      bufnr = event.buf,
      timeout_ms = format_opts.timeout_ms or timeout_ms,
      formatting_options = format_opts.formatting_options,
    }

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

---@param client? lsp_zero.api.Client
---@param bufnr? integer
---@param opts? lsp_zero.config.FormatOpts
function M.buffer_autoformat(client, bufnr, opts)
  local autocmd = vim.api.nvim_create_autocmd
  local augroup = vim.api.nvim_create_augroup
  local format_id = augroup(format_group, {clear = false})

  opts = opts or {}
  client = client or {}
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  vim.api.nvim_clear_autocmds({group = format_group, buffer = bufnr})

  if vim.b.lsp_zero_enable_autoformat == nil then
    vim.b.lsp_zero_enable_autoformat = 1
  end

  local config = {
    async = false,
    id = client.id,
    name = client.name,
    bufnr = bufnr,
    timeout_ms = opts.timeout_ms or timeout_ms,
    formatting_options = opts.formatting_options,
  }

  local apply_format = function()
    local autoformat = vim.b.lsp_zero_enable_autoformat
    local enabled = (autoformat == 1 or autoformat == true)
    if not enabled then
      return
    end

    vim.lsp.buf.format(config)
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

---@param client? lsp_zero.api.Client
---@param bufnr? integer
---@param opts? lsp_zero.config.FormatOpts
function M.async_autoformat(client, bufnr, opts)
  if type(client) ~= 'table' or client.id == nil then
    return
  end

  if s.supports_formatting(client) == false then
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

  local fmt_opts = opts.formatting_options or {}
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

  local filetype_setup = function(event)
    local client_id = vim.tbl_get(event, 'data', 'client_id')
    local client = client_id and vim.lsp.get_client_by_id(client_id)

    if client == nil then
      -- I don't know how this would happen
      -- but apparently it can happen
      return
    end

    local files = list[client.name]

    if type(files) == 'string' then
      files = {list[client.name]}
    end

    if files == nil or vim.tbl_contains(files, vim.bo.filetype) == false then
      return
    end

    local config = {
      id = client.id,
      bufnr = event.buf,
      async = format_opts.async == true or false,
      timeout_ms = format_opts.timeout_ms or timeout_ms,
      formatting_options = format_opts.formatting_options,
    }

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
  local get_client = vim.lsp.get_clients

  if get_client == nil then
    ---@diagnostic disable-next-line: deprecated
    get_client = vim.lsp.get_active_clients
  end

  local client = get_client({bufnr = buffer, name = server})[1]

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

  if s.supports_formatting(client) == false then
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
    local client = client_id and vim.lsp.get_client_by_id(client_id)

    if client == nil then
      -- I don't know how this would happen
      -- but apparently it can happen
      return
    end

    local files = opts.servers[client.name] or {}

    if type(files) == 'string' then
      files = {opts.servers[client.name]}
    end

    if files == nil or vim.tbl_contains(files, vim.bo.filetype) == false then
      return
    end

    if s.supports_formatting(client) == false then
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
        s.request_format(client_id, e.buf, opts.format_opts, opts.timeout_ms)
      end,
    })
  end

  autocmd('LspAttach', {
    group = opts.setup_augroup,
    desc = 'Setup non-blocking format on save',
    callback = filetype_setup,
  })
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
  local timer = uv.new_timer()

  local client = vim.lsp.get_client_by_id(client_id)
  if client == nil then
    return
  end
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
  s.make_request(client, params, handler, buffer)
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

function s.supports_formatting(client)
  return client.supports_method('textDocument/formatting')
end

function s.make_request(client, params, handler, buffer)
  client.request('textDocument/formatting', params, handler, buffer)
end

if vim.fn.has('nvim-0.11') == 1 then
  function s.supports_formatting(client)
    return client:supports_method('textDocument/formatting')
  end

  function s.make_request(client, params, handler, buffer)
    client:request('textDocument/formatting', params, handler, buffer)
  end
end

return M

