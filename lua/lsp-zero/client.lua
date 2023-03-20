local M = {}
local clients = {}
local count = 0
local setup_id = 'lsp_zero_server_%d'
local can_reuse = type(vim.lsp.start) == 'function'

M.setup = function(opts)
  count = count + 1
  local ft = [[
    augroup %s
      autocmd!
      autocmd FileType %s lua require('lsp-zero.client').start(%d)
    augroup END
  ]]

  local valid = opts and type(opts.filetypes) == 'table'
  if not valid then
    return
  end

  opts.id = nil
  clients[count] = {config = M.config(opts, count)}
  local files = table.concat(opts.filetypes, ',')

  vim.cmd(ft:format(setup_id:format(count), files, count))
end

M.start = function(idx)
  local current = clients[idx]

  if current == nil then
    return
  end

  if current.id then
    M.attach(current)
    return
  end

  local get_root = current.config.root_dir
  if type(get_root) == 'function' then
    current.root_dir = get_root
    current.config.root_dir = get_root()
  elseif type(get_root) == 'string' then
    current.root_dir = function()
      return get_root
    end
  else
    clients[idx] = nil
    return
  end

  if current.config.root_dir == nil then
    return
  end

  local id = vim.lsp.start_client(current.config)
  if id == nil then
    return
  end

  current.id = id
  vim.lsp.buf_attach_client(0, id)
end

M.attach_client = function(current)
  local new = current.root_dir()

  if current.config.root_dir == new then
    vim.lsp.buf_attach_client(0, current.id)
    return
  end

  if new then
    current.config.root_dir = new
    vim.lsp.start(current.config)
  end
end

M.attach_fallback = function(current)
  local new = current.root_dir()

  if new == nil then
    return
  end

  ---
  -- reuse current
  ---
  if current.config.root_dir == new then
    vim.lsp.buf_attach_client(0, current.id)
    return
  end

  ---
  -- reuse another client
  ---
  local active = vim.lsp.get_active_clients()
  local filetype = vim.bo.filetype

  local active_client = vim.tbl_filter(function(c)
    return c.config.root_dir == new
      and vim.tbl_contains(c.config.filetypes, filetype)
  end, active)[1]

  if active_client then
    current.config.root_dir = new
    vim.lsp.buf_attach_client(0, active_client.id)
    return
  end

  ---
  -- create new client
  ---
  count = count + 1
  current.config.root_dir = new

  local id = vim.lsp.start_client(current.config)
  if id then
    vim.lsp.buf_attach_client(0, id)
  end
end

M.config = function(opts, idx)
  local defaults = {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    on_exit = vim.schedule_wrap(function()
      clients[idx] = nil
      local augroup = setup_id:format(idx)
      local reset = [[
        if exists('#%s')
          autocmd! %s
          augroup! %s
        endif
      ]]
      vim.cmd(reset:format(augroup, augroup, augroup))
    end),
  }

  if can_reuse == false then
    defaults.flags = {debounce_text_changes = 150}
    defaults.on_init = function(client, results)
      if results.offsetEncoding then
        client.offset_encoding = results.offsetEncoding
      end

      if client.config.settings then
        client.notify('workspace/didChangeConfiguration', {
          settings = client.config.settings
        })
      end
    end
  end

  if type(opts) ~= 'table' then
    return defaults
  end

  local config = vim.tbl_deep_extend('force', defaults, opts)

  if opts.on_init and defaults.on_init then
    local send_settings = defaults.on_init
    local user_init = opts.on_init
    config.on_init = function(...)
      send_settings(...)
      user_init(...)
    end
  end

  if opts.on_exit then
    local cleanup = defaults.on_exit
    local cb = opts.on_exit
    config.on_exit = function(...)
      cleanup()
      cb(...)
    end
  end

  return config
end

M.attach = can_reuse and M.attach_client or M.attach_fallback

return M

