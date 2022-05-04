local M = {common_on_attach = function(arg) return arg end}
local s = {}

local state = {
  capabilities = nil,
  exclude = {}
}

local global_config = require('lsp-zero.settings')
local util = require('lsp-zero.utils')

M.setup = function(server_name, user_opts)
  if state.exclude[server_name] then return end

  local opts = M.build_options(server_name, user_opts)

  local lspconfig = require('lspconfig')
  local lsp = lspconfig[server_name]
  lsp.setup(opts)

  if vim.v.vim_did_enter == 1 then
    s.autostart(lsp, opts.autostart)
  end
end

M.build_options = function(name, opts)
  opts = opts or {}
  local custom_attach = opts.on_attach
  state.exclude[name] = true

  s.call_once()

  if opts.root_dir == true then
    opts.root_dir = function() return vim.fn.getcwd() end
  end

  if opts.capabilities == nil and global_config.cmp_capabilities then
    opts.capabilities = s.use_cmp()
  end

  opts.on_attach = function(...)
    s.on_attach(...)
    if M.common_on_attach then M.common_on_attach(...) end
    if custom_attach then custom_attach(...) end
  end

  return opts
end

s.call_once = function()
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    {
      border = 'rounded',
    }
  )

  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {
      border = 'rounded',
    }
  )

  if global_config.call_servers == 'local' then
    util.setup_lsp_installer()
  end

  if global_config.configure_diagnostics then
    s.diagnostics()
  end

  local fmt = string.format
  local command = function(name, str)
    vim.cmd(fmt('command! %s lua %s', name, str))
  end

  command('LspZeroWorkspaceAdd', 'vim.lsp.buf.add_workspace_folder()')
  command('LspZeroWorkspaceList', 'vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))')

  s.call_once = function() end
end

s.on_attach = function(_, bufnr)
  if global_config.set_lsp_keymaps then
    s.set_keymaps(bufnr)
  end

  local fmt = string.format
  local command = function(name, str)
    vim.cmd(fmt('command! -buffer %s lua %s', name, str))
  end

  command('LspZeroFormat', 'vim.lsp.buf.formatting()')
  command('LspZeroWorkspaceRemove', 'vim.lsp.buf.remove_workspace_folder()')
end

s.diagnostics = function()
  local sign = function(opts)
    vim.fn.sign_define(opts.name, {
      texthl = opts.name,
      text = opts.text,
      numhl = ''
    })
  end

  local icon = global_config.sign_icons

  sign({name = 'DiagnosticSignError', text = icon.error})
  sign({name = 'DiagnosticSignWarn', text = icon.warn})
  sign({name = 'DiagnosticSignHint', text = icon.hint})
  sign({name = 'DiagnosticSignInfo', text = icon.info})

  vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = 'minimal',
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = '',
    },
  })
end

s.set_keymaps = function(bufnr)
  local fmt = function(cmd) return function(str) return cmd:format(str) end end

  local map = function(m, lhs, rhs)
    local opts = {noremap = true, silent = true}
    vim.api.nvim_buf_set_keymap(bufnr, m, lhs, rhs, opts)
  end

  local lsp = fmt('<cmd>lua vim.lsp.%s<cr>')
  local diagnostic = fmt('<cmd>lua vim.diagnostic.%s<cr>')

  map('n', 'K', lsp 'buf.hover()')
  map('n', 'gd', lsp 'buf.definition()')
  map('n', 'gD', lsp 'buf.declaration()')
  map('n', 'gi', lsp 'buf.implementation()')
  map('n', 'go', lsp 'buf.type_definition()')
  map('n', 'gr', lsp 'buf.references()')
  map('n', '<C-k>', lsp 'buf.signature_help()')
  map('n', '<F2>', lsp 'buf.rename()')
  map('n', '<F4>', lsp 'buf.code_action()')
  map('x', '<F4>', lsp 'buf.range_code_action()')

  if global_config.configure_diagnostics then
    map('n', 'gl', diagnostic 'open_float()')
    map('n', '[d', diagnostic 'goto_prev()')
    map('n', ']d', diagnostic 'goto_next()')
  end
end

s.use_cmp = function()
  if state.capabilities then return state.capabilities end

  local ok, source = pcall(require, 'cmp_nvim_lsp')
  if not ok then
    local msg = "Could not find cmp_nvim_lsp. Please install cmp_nvim_lsp or set the option cmp_capabilities to false (use set_preferences)."
    vim.notify(msg, vim.log.levels.WARN)
    return {}
  end

  state.capabilities = source.update_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  )

  return state.capabilities
end

s.autostart = function(lsp, autostart)
  if autostart == nil then
    autostart = vim.F.if_nil(lsp.autostart, true)
  end

  if autostart and lsp.manager then
    lsp.manager.try_add_wrapper()
  end
end

M.setup_servers = function(list)
  local opts = list.opts
  local here = list.root_dir == true

  if opts == nil and here then
    opts = {root_dir = true}
  end

  for _, server in pairs(list) do
    M.setup(server, opts)
  end
end

M.ensure_installed = function(list)
  local get_server = require('nvim-lsp-installer.servers').get_server
  local installed = false

  util.setup_lsp_installer()

  for _, name in pairs(list) do
    local ok, server = get_server(name)
    if ok and not server:is_installed() then
      installed = true
      vim.notify('[lsp-zero] Installing ' .. name, vim.log.levels.INFO)
      server:install()

      if global_config.suggest_lsp_servers then
        require('lsp-zero.state').check_server(server)
      end
    end
  end

  if installed then
    local msg = '[lsp-zero] Execute the command :LspInstallInfo to track the process of installation.\n'
      .. 'And, restart neovim when finished to initialize language servers properly.'

    vim.notify(msg, vim.log.levels.INFO)
  end
end

return M

