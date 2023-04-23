local M = {}

local state_file = vim.fn.stdpath('data') .. '/lsp-zero.info.json'

function M.defaults()
  return {
    float_border = 'none',
    configure_diagnostics = false,
    call_servers = 'local',
    setup_servers_on_start = false,
    set_lsp_keymaps = false,
    manage_nvim_cmp = false,
    state_file = state_file,
  }
end

function M.set(opts)
  if type(opts) == 'table' then
    M.current = vim.tbl_deep_extend('force', M.current, opts)
  end
end

function M.get()
  return M.current
end

function M.preset(opts)
  local name = 'none'
  local user_config = {}
  local defaults = {}

  if opts == nil then
    opts = {name = 'minimal'}
  end

  if type(opts) == 'string' then
    name = opts
  end

  if type(opts) == 'table' then
    if type(opts.name) == 'string' then
      name = opts.name
    elseif opts.name == nil then
      name = 'minimal'
      opts.name = 'minimal'
    else
      name = 'defaults'
    end
    user_config = opts
  end

  if name == 'none' then
    return false
  end

  local preset = require('lsp-zero.preset')

  if preset[name] then
    defaults = preset[name]()
  else
    defaults = M.defaults()
  end

  local new_config = vim.tbl_deep_extend('force', defaults, user_config)

  if new_config.state_file == nil then
    new_config.state_file = state_file
  end

  M.current = new_config

  return true
end

M.current = M.defaults()

return M

