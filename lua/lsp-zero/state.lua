local M = {}

local settings = require('lsp-zero.settings')
local util = require('lsp-zero.utils')
local get_installed_servers = require('nvim-lsp-installer').get_installed_servers
local state = {ok = false}

local defaults = {
  ok = true,

  -- filetypes to ignore by default
  filetypes = {
    ['lsp-installer'] = true,
    help = true,
    nofile = true,
    qf = true,
    quickfix = true,
  },

  -- cache server history
  previously_installed_servers = {}
}

M.sync = function()
  local path = settings.state_file
  local new_state = {}

  if vim.fn.filereadable(path) == 0 then
    util.write_file(path, vim.json.encode(defaults))
    new_state = defaults
  else
    state = vim.json.decode(util.read_file(path))
    return
  end

  local servers = get_installed_servers()

  for _, server in ipairs(servers) do
    local fts = server:get_supported_filetypes()
    new_state.previously_installed_servers[server.name] = true

    for _, ft in ipairs(fts) do
      new_state.filetypes[ft] = true
    end
  end

  util.write_file(path, vim.json.encode(new_state))

  state = new_state
end

M.save_filetype = function(ft)
  local path = settings.state_file

  if not state.ok then
    state = vim.json.decode(util.read_file(path))
  end

  state.filetypes[ft] = true

  util.write_file(path, vim.json.encode(state))
end

M.check_server = function(server)
  if not state.ok then
    return
  end

  if state.previously_installed_servers[server.name] then
    return
  end

  state.previously_installed_servers[server.name] = true

  local fts = server:get_supported_filetypes()
  state.previously_installed_servers[server.name] = true

  for _, ft in ipairs(fts) do
    state.filetypes[ft] = true
  end

  util.write_file(settings.state_file, vim.json.encode(state))
end

M.get = function()
  return state
end

return M

