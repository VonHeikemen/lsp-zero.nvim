local M = {}

local settings = require('lsp-zero.settings')
local util = require('lsp-zero.utils')
local state = {ok = false}

local get_defaults = function()
  return {
    ok = true,

    -- filetypes to ignore by default
    filetypes = {
      ['lsp-installer'] = true,
      ['mason.nvim'] = true,
      ['null-ls-info'] = true,
      help = true,
      nofile = true,
      qf = true,
      quickfix = true,
      netrw = true,
      lspinfo = true,
      man = true,
      harpoon = true
    },

    -- cache server history
    previously_installed_servers = {}
  }
end

local defaults = get_defaults()

local supported_filetypes = util.get_supported_filetypes

M.sync = function()
  local installer = require('lsp-zero.installer')
  installer.choose()

  local get_installed_servers = installer.fn.get_servers

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

  for _, name in ipairs(servers) do
    local fts = supported_filetypes(name)
    new_state.previously_installed_servers[name] = true

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

M.check_server = function(name)
  if not state.ok then
    return
  end

  if state.previously_installed_servers[name] then
    return
  end

  state.previously_installed_servers[name] = true

  local fts = supported_filetypes(name)
  state.previously_installed_servers[name] = true

  for _, ft in ipairs(fts) do
    state.filetypes[ft] = true
  end

  util.write_file(settings.state_file, vim.json.encode(state))
end

M.reset = function()
  state = get_defaults()
  util.write_file(settings.state_file, vim.json.encode(state))
end

M.get = function()
  return state
end

return M

