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

return M

