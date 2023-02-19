local M = {}
local installer = require('lsp-zero.installer')

M.run = function(name)
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
    local client = require('lspconfig.util').get_active_client_by_name(0, name)
    if client then
      report = concat('+ is active in the current buffer')
      print(report)
      return
    end

    local filetypes = require('lsp-zero.lsp-filetypes')[name]
    local ft = vim.bo.filetype

    if filetypes and ft ~= '' and filetypes[ft] then
      report = concat('- is not active in the current buffer')
    end
  end

  print(report)
end

M.installed = function(name)
  if installer.enabled == false then
    print("lsp-zero can only verify LSP servers installed with mason.nvim or nvim-lsp-installer")
    return false
  end

  local servers = installer.fn.get_servers()
  return vim.tbl_contains(servers, name)
end

M.configured = function(name)
  local util = require('lspconfig.util')
  local servers = util.available_servers()

  return vim.tbl_contains(servers, name)
end

M.is_executable = function(name)
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

M.inspect_settings = function(name)
  local util = require('lspconfig.util')
  local client = util.get_active_client_by_name(0, name)

  if client == nil then
    local msg = '* "%s" is not active in the current buffer'
    print(msg:format(name))
    return
  end

  print(vim.inspect(client.config.settings))
end

M.inspect_server_config = function(name)
  local util = require('lspconfig.util')
  local client = util.get_active_client_by_name(name)

  if client == nil then
    local msg = '* "%s" is not active in the current buffer'
    print(msg:format(name))
    return
  end

  print(vim.inspect(client.config))
end

return M

