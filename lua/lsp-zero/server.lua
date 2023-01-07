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

  M.skip_server(name)

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

  state.map_ctrlk = vim.fn.mapcheck('<C-k>', 'n') == ''

  s.set_global_commands()

  s.call_once = function() end
end

M.extend_lspconfig = function(opts)
  local defaults_opts = {
    set_lsp_keymaps = true,
    capabilities = {},
    on_attach = nil,
  }

  local ok, lspconfig = pcall(require, 'lspconfig')

  if not ok then
    local msg = "[lsp-zero] Could not find the module lspconfig. Please make sure 'nvim-lspconfig' is installed."
    vim.notify(msg, vim.log.levels.ERROR)
    return
  end

  opts = vim.tbl_deep_extend('force', defaults_opts, opts or {})

  local lsp_defaults = lspconfig.util.default_config

  -- Set client capabilities
  local ok_cmp = pcall(require, 'cmp')
  local ok_lsp_source, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
  local cmp_default_capabilities = {}

  if ok_lsp_source then
     cmp_default_capabilities = cmp_lsp.default_capabilities()
  end

  if ok_cmp then
    lsp_defaults.capabilities = vim.tbl_deep_extend(
      'force',
      lsp_defaults.capabilities,
      cmp_default_capabilities,
      opts.capabilities or {}
    )
  end

  -- Set on_attach hook
  local util = lspconfig.util
  local lsp_attach = function(client, bufnr)
    if opts.set_lsp_keymaps then
      s.set_keymaps(bufnr, {
        set_lsp_keymaps = opts.set_lsp_keymaps,
        configure_diagnostics = true,
        map_ctrlk = true,
      })
    end

    s.set_buf_commands()

    if opts.on_attach then
      opts.on_attach(client, bufnr)
    end
  end

  util.on_setup = util.add_hook_after(util.on_setup, function(config)
    config.on_attach = util.add_hook_before(config.on_attach, lsp_attach)
  end)

  s.set_global_commands()
end

s.on_attach = function(_, bufnr)
  if global_config.set_lsp_keymaps then
    s.set_keymaps(bufnr, {
      set_lsp_keymaps = global_config.set_lsp_keymaps,
      configure_diagnostics = global_config.configure_diagnostics,
      map_ctrlk = state.map_ctrlk,
    })
  end

  s.set_buf_commands()
end

s.set_buf_commands = function()
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

s.set_global_commands = function()
  local fmt = string.format
  local command = function(name, str)
    vim.cmd(fmt('command! %s lua %s', name, str))
  end

  command('LspZeroWorkspaceAdd', 'vim.lsp.buf.add_workspace_folder()')
  command('LspZeroWorkspaceList', 'vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))')
end

M.diagnostics_config = function()
  return {
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
  }
end

M.setup_diagnostics = function()
  local icon = global_config.sign_icons

  if vim.tbl_isempty(icon) == false then
    M.set_sign_icons(icon)
  end

  vim.diagnostic.config(M.diagnostics_config())
end

M.set_sign_icons = function(icon)
  local sign = function(opts)
    if type(opts.text) ~= 'string' then
      return
    end

    vim.fn.sign_define(opts.name, {
      texthl = opts.name,
      text = opts.text,
      numhl = ''
    })
  end

  sign({name = 'DiagnosticSignError', text = icon.error})
  sign({name = 'DiagnosticSignWarn', text = icon.warn})
  sign({name = 'DiagnosticSignHint', text = icon.hint})
  sign({name = 'DiagnosticSignInfo', text = icon.info})
end

s.set_keymaps = function(bufnr, opts)
  local fmt = function(cmd) return function(str) return cmd:format(str) end end

  local lsp = fmt('<cmd>lua vim.lsp.%s<cr>')
  local diagnostic = fmt('<cmd>lua vim.diagnostic.%s<cr>')
  local omit = {}

  if type(opts.set_lsp_keymaps) == 'table' then
    local keys = opts.set_lsp_keymaps.omit or {}
    for _, key in ipairs(keys) do
      omit[key] = true
    end
  end

  local map = function(m, lhs, rhs)
    if omit[lhs] then
      return
    end

    local key_opts = {noremap = true, silent = true}
    vim.api.nvim_buf_set_keymap(bufnr, m, lhs, rhs, key_opts)
  end

  map('n', 'K', lsp 'buf.hover()')
  map('n', 'gd', lsp 'buf.definition()')
  map('n', 'gD', lsp 'buf.declaration()')
  map('n', 'gi', lsp 'buf.implementation()')
  map('n', 'go', lsp 'buf.type_definition()')
  map('n', 'gr', lsp 'buf.references()')
  map('n', '<F2>', lsp 'buf.rename()')
  map('n', '<F4>', lsp 'buf.code_action()')
  map('x', '<F4>', lsp 'buf.range_code_action()')

  if opts.map_ctrlk then
    map('n', '<C-k>', lsp 'buf.signature_help()')
  end

  if opts.configure_diagnostics then
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
      local msg = "[lsp-zero] Could not find cmp_nvim_lsp. Please install cmp_nvim_lsp or set the option cmp_capabilities to false (use set_preferences)."
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

  local has_filetype = vim.bo.filetype ~= ''

  if autostart and lsp.manager and has_filetype then
    lsp.manager.try_add_wrapper()
  end
end

M.setup_servers = function(list)
  local opts = list.opts
  local here = list.root_dir == true

  if opts == nil and here then
    opts = {root_dir = true}
  end

  for _, server in ipairs(list) do
    M.setup(server, opts)
  end
end

M.skip_server = function(name)
  state.exclude[name] = true
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
      local msg = "[lsp-zero] Synchronous formatting doesn't support ranges"
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

