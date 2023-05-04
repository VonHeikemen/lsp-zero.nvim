local M = {}

M.enabled = false
M.current = 'mason.nvim'
M.state = 'init'

function M.setup()
  if M.state ~= 'init' then
    return M.enabled
  end

  local mason = M.load_module('mason')
  local lspconfig = M.load_module('mason-lspconfig')

  if mason == 'failed' or lspconfig == 'failed' then
    M.enabled = false
    M.state = 'failed'
    return false
  end

  M.enabled = true
  M.state = 'ok'

  return true
end

function M.load_module(name)
  if package.loaded[name] ~= nil then
    return 'loaded'
  end

  local ok, mod = pcall(require, name)

  if not ok then
    return 'failed'
  end

  mod.setup()

  return 'loaded'
end

function M.get_servers()
  local mason = require('mason-lspconfig')
  return mason.get_installed_servers()
end

function M.ensure_installed(list)
  if M.enabled == false then
    return
  end

  require('mason-lspconfig.settings').set({ensure_installed = list})
  require('mason-lspconfig.ensure_installed')()
end

return M

