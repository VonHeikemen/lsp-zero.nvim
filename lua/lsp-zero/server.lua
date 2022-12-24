local M = {common_on_attach = function(arg) return arg end, default_config = {}}
local s = {}

local state = {
  capabilities = nil,
  exclude = {},
  map_ctrlk = false,
}

local global_config = require('lsp-zero.settings')

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
  state.exclude[name] = true

  s.call_once()

  opts = vim.tbl_deep_extend('force', {}, M.default_config, opts)
  local custom_attach = opts.on_attach

  if opts.root_dir == true then
    opts.root_dir = function() return vim.fn.getcwd() end
  end

  if global_config.cmp_capabilities then
    opts.capabilities = s.use_cmp(opts.capabilities)
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

  local installer = require('lsp-zero.installer')
  installer.choose()
  installer.fn.setup()

  if global_config.configure_diagnostics then
    s.diagnostics()
  end

  state.map_ctrlk = vim.fn.mapcheck('<C-k>', 'n') == ''

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
  local command = function(name, attr, str)
    vim.cmd(fmt('command! -buffer %s %s lua %s', attr, name, str))
  end

  command(
    'LspZeroFormat',
    '-range -bang',
    "require('lsp-zero.server').format_cmd(<line1>, <line2>, <count>, '<bang>' == '!')"
  )
  command('LspZeroWorkspaceRemove', '', 'vim.lsp.buf.remove_workspace_folder()')
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
  map('n', '<F2>', lsp 'buf.rename()')
  map('n', '<F4>', lsp 'buf.code_action()')
  map('x', '<F4>', lsp 'buf.range_code_action()')

  if state.map_ctrlk then
    map('n', '<C-k>', lsp 'buf.signature_help()')
  end

  if global_config.configure_diagnostics then
    map('n', 'gl', diagnostic 'open_float()')
    map('n', '[d', diagnostic 'goto_prev()')
    map('n', ']d', diagnostic 'goto_next()')
  end
end

s.use_cmp = function(current)
  if state.capabilities == nil then
    local ok, source = pcall(require, 'cmp_nvim_lsp')
    local cmp_lsp = {}

    if ok then
      cmp_lsp = source.default_capabilities()
    else
      local msg = "Could not find cmp_nvim_lsp. Please install cmp_nvim_lsp or set the option cmp_capabilities to false (use set_preferences)."
      vim.notify(msg, vim.log.levels.WARN)
    end

    state.capabilities = vim.tbl_deep_extend(
      'force',
      vim.lsp.protocol.make_client_capabilities(),
      cmp_lsp,
      M.default_config.capabilities or {}
    )
  end

  if current == nil then
    return state.capabilities
  end

  return vim.tbl_deep_extend('force', {}, state.capabilities, current)
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
  local installer = require('lsp-zero.installer')
  installer.choose()
  installer.fn.install(list)
end

M.format_cmd = function(line1, line2, count, bang)
  local execute = vim.lsp.buf.format

  if execute then
    execute({async = bang})
    return
  end

  local has_range = line2 == count
  execute = vim.lsp.buf.formatting

  if bang then
    if has_range then
      local msg = "Synchronous formatting doesn't support ranges"
      vim.notify(msg, vim.log.levels.ERROR)
      return
    end
    execute = vim.lsp.buf.formatting_sync
  end

  if has_range then
    execute = vim.lsp.buf.range_formatting
  end

  execute()
end

return M

