local M = {}
local installer = require('lsp-zero.installer')

function M.run(name)
  local report = 'LSP server: ' .. name
  local concat = function(msg) return string.format('%s\n%s', report, msg) end

  if installer.enabled then
    local result = M.installed(name)
    local msg = '- was not installed with ' .. installer.current
    if result then
      msg = '+ was installed with ' .. installer.current
    end
    report = concat(msg)
  end

  do
    local result = M.configured(name)
    local msg = "- hasn't been configured with lspconfig"
    if result then
      msg = '+ was configured using lspconfig'
    end
    report = concat(msg)
  end

  do
    local result = M.is_executable(name)

    if result == false then
      print(report)
      return
    end

    local msg = string.format('- "%s" was not found.', result.cmd)

    if result.result then
      msg = string.format('+ "%s" is executable', result.cmd)
    end
    report = concat(msg)
  end

  do
    local util = require('lspconfig.util')
    local client = util.get_active_client_by_name(0, name)
    if client then
      report = concat('+ is active in the current buffer')
    end
  end

  print(report)
end

function M.installed(name)
  if installer.enabled == false then
    print("lsp-zero can only verify LSP servers installed with " .. installer.current)
    return false
  end

  local servers = installer.get_servers()
  return vim.tbl_contains(servers, name)
end

function M.configured(name)
  local util = require('lspconfig.util')
  local servers = util.available_servers()

  return vim.tbl_contains(servers, name)
end

function M.is_executable(name)
  local configs = require('lspconfig.configs')
  local lsp = configs[name]

  if lsp == nil then
    return false
  end

  local cmd = lsp.cmd[1]

  if cmd == 'cmd.exe' and lsp.cmd[2] == '/C' then
    cmd = lsp.cmd[3]
  end

  return {cmd = cmd, result = vim.fn.executable(cmd)}
end

function M.inspect_settings(name)
  local util = require('lspconfig.util')
  local client = util.get_active_client_by_name(0, name)

  if client == nil then
    local msg = '* "%s" is not active in the current buffer'
    print(msg:format(name))
    return
  end

  print(vim.inspect(client.config.settings))
end

function M.inspect_server_config(name)
  local util = require('lspconfig.util')
  local client = util.get_active_client_by_name(0, name)

  if client == nil then
    local msg = '* "%s" is not active in the current buffer'
    print(msg:format(name))
    return
  end

  print(vim.inspect(client.config))
end

return M

