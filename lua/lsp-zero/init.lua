local Setup = require('lsp-zero.setup')

if Setup.ok then
  Setup.extend_plugins()
end

local M = require('lsp-zero.api')

---
-- Handle removed functions
---

local function notify(msg)
  if vim.g.lsp_zero_api_warnings == 0 then
    return
  end

  vim.notify(msg, vim.log.levels.WARN)
end

M.setup = M.noop
M.set_preferences = M.noop

M.defaults = {}

function M.defaults.cmp_config(opts)
  local defaults = require('lsp-zero.cmp').base_config()
  return vim.tbl_deep_extend('force', defaults, opts or {})
end

function M.defaults.cmp_mappings(opts)
  local defaults = require('lsp-zero.cmp').basic_mappings()
  return vim.tbl_deep_extend('force', defaults, opts or {})
end

function M.preset(opts)
  return M
end

function M.ensure_installed()
  local msg = '[lsp-zero] The function .ensure_installed() has been removed.\n'
    .. 'Use the module mason-lspconfig to install your LSP servers.\n'
    .. 'See :help lsp-zero-guide:integrate-with-mason-nvim\n\n'
  notify(msg)
end

function M.setup_nvim_cmp()
  local msg = '[lsp-zero] The function .setup_nvim_cmp() has been removed.\n'
    .. 'Learn how to customize nvim-cmp reading the guide in the help page\n'
    .. ':help lsp-zero-guide:customize-nvim-cmp\n\n'
  notify(msg)
end

function M.skip_server_setup()
  local msg = '[lsp-zero] The function .skip_server_setup() has been removed.\n\n'
  notify(msg)
end

function M.nvim_workspace()
  local msg = '[lsp-zero] The function .nvim_workspace() has been removed.\n'
    .. 'Learn how to configure lua_ls reading the guide in the help page\n'
    .. ':help lsp-zero-guide:lua-lsp-for-neovim\n\n'
  notify(msg)
end

function M.new_server(opts)
  local msg = '[lsp-zero] The function .new_server() has been renamed to .new_client().'
  
  if opts.name then
    msg = msg .. '\nUse .new_client() to configure ' .. opts.name
  end

  notify(msg)
end

return M

