local M = {}
local s = {}

function M.run(name)
  local report = 'LSP server: ' .. name
  local concat = function(msg) return string.format('%s\n%s', report, msg) end

  do
    local result = s.configured(name)
    local msg = "- hasn't been configured with lspconfig"
    if result then
      msg = '+ was configured using lspconfig'
    end
    report = concat(msg)
  end

  do
    local result = s.is_executable(name, true)

    if result.cmd == '' then
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

function M.executable(name)
  local header = 'LSP server: ' .. name
  local result = s.is_executable(name, false)

  if result.cmd == '' then
    local msg = '- "%s" is not supported by lspconfig'
    print(msg:format(name))
    return
  end

  local msg = string.format('- "%s" was not found.', result.cmd)

  if result.result then
    msg = string.format('+ "%s" is executable', result.cmd)
  end

  print(header)
  print(msg)
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

function s.configured(name)
  local util = require('lspconfig.util')
  local servers = util.available_servers()

  return vim.tbl_contains(servers, name)
end

function s.is_executable(name, check_available)
  local configs = require('lspconfig.configs')
  local lsp = configs[name]

  if lsp == nil and check_available then
    return {cmd = '', result = false}
  end

  if lsp == nil then
    local mod = string.format('lspconfig.server_configurations.%s', name)
    local ok, server = pcall(require, mod)
    if ok == false or not server.default_config then
      return {cmd = '', result = false}
    end

    lsp = server.default_config
  end

  local cmd = lsp.cmd[1]

  if cmd == 'cmd.exe' and lsp.cmd[2] == '/C' then
    cmd = lsp.cmd[3]
  end

  return {cmd = cmd, result = vim.fn.executable(cmd) == 1}
end

return M

