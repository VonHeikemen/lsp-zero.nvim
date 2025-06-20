local M = {}

M.enabled = false
M.current = 'mason.nvim'
M.state = 'init'

function M.setup()
  if M.state ~= 'init' then
    return M.enabled
  end

  local mason, mason_mod = M.load_module('mason')
  local lspconfig, lspconfig_mod = M.load_module('mason-lspconfig')

  if mason == 'loaded' then
    local setup = mason_mod.setup
    if type(setup) == 'function' then
      setup()
    end
  end

  if lspconfig == 'loaded' then
    local setup = lspconfig_mod.setup
    local mason_v2 = lspconfig_mod.setup_handlers == nil

    if type(setup) == 'function' then
      if mason_v2 then
        setup({automatic_enable = false})
      else
        setup()
      end
    end
  end

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
    return 'loaded', {}
  end

  local ok, mod = pcall(require, name)

  if not ok then
    return 'failed', {}
  end

  return 'loaded', mod
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
  local ok, ensure_installed = pcall(require, 'mason-lspconfig.ensure_installed')

  if ok then
    ensure_installed()
    return
  end

  local ok_mason, mason_install = pcall(require, 'mason-lspconfig.features.ensure_installed')
  if ok_mason then
    mason_install()
  end
end

return M

