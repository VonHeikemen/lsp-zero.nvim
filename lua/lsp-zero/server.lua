local M = {common_on_attach = function(arg) return arg end, default_config = {}}
local s = {}

local state = {
  capabilities = nil,
  exclude = {},
  map_ctrlk = false,
  omit_keys = {n = {}, i = {}, x = {}},
}

local global_config = require('lsp-zero.settings')

M.setup = function(server_name, user_opts)
  if state.exclude[server_name] then return end

  local opts = M.build_options(server_name, user_opts)

  local lspconfig = require('lspconfig')
  local lsp = lspconfig[server_name]
  lsp.setup(opts)

  if vim.v.vim_did_enter == 1 then
    pcall(s.autostart, lsp, opts.autostart)
  end
end

M.build_options = function(name, opts)
  opts = opts or {}

  M.skip_server(name)

  s.call_once()

  opts = vim.tbl_deep_extend('force', {}, M.default_config, opts)

  if opts.root_dir == true then
    opts.root_dir = function() return vim.fn.getcwd() end
  end

  opts.capabilities = s.set_capabilities(opts.capabilities)

  local custom_attach = opts.on_attach
  opts.on_attach = function(...)
    s.on_attach(...)
    if M.common_on_attach then M.common_on_attach(...) end
    if custom_attach then custom_attach(...) end
  end

  return opts
end

s.call_once = function()
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

  -- Set client capabilities
  local ok_cmp = pcall(require, 'cmp')
  local ok_lsp_source, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
  local cmp_default_capabilities = {}

  if ok_cmp and ok_lsp_source then
     cmp_default_capabilities = cmp_lsp.default_capabilities()
  end

  lspconfig.util.default_config.capabilities = vim.tbl_deep_extend(
    'force',
    lspconfig.util.default_config.capabilities,
    cmp_default_capabilities,
    opts.capabilities or {}
  )

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
    '-range -bang -nargs=*',
    "require('lsp-zero.server').format_cmd(<line1>, <line2>, <count>, '<bang>' == '!', {<f-args>})"
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

  local config = M.diagnostics_config()

  if vim.diagnostic == nil then
    return
  end

  vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
    float = config.float
  })
end

M.setup_handlers = function()
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    {border = 'rounded'}
  )

  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {border = 'rounded'}
  )
end

M.set_sign_icons = function(icon)
  icon = icon or {}

  if vim.diagnostic and vim.diagnostic.count then
    local ds = vim.diagnostic.severity
    local levels = {
      [ds.ERROR] = 'error',
      [ds.WARN] = 'warn',
      [ds.INFO] = 'info',
      [ds.HINT] = 'hint'
    }

    local text = {}

    for i, l in pairs(levels) do
      if type(icon[l]) == 'string' then
        text[i] = icon[l]
      end
    end

    vim.diagnostic.config({signs = {text = text}})
    return
  end

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

M.default_keymaps = function(opts)
  local defaults = {buffer = 0, preserve_mappings = true}
  opts = vim.tbl_deep_extend('force', defaults, opts or {})

  s.set_keymaps(opts.buffer, opts)
end

M.buffer_commands = function()
  local command = function(name, attr, str)
    vim.cmd(string.format('command! -buffer %s %s lua %s', attr, name, str))
  end

  command('LspZeroWorkspaceAdd', '', 'vim.lsp.buf.add_workspace_folder()')
  command('LspZeroWorkspaceList', '','vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))')

  s.set_buf_commands()
end

s.set_keymaps = function(bufnr, opts)
  local omit = {}
  local keep_defaults = true

  if type(opts.set_lsp_keymaps) == 'table' then
    local keys = opts.set_lsp_keymaps.omit or {}
    for _, key in ipairs(keys) do
      omit[key] = true
    end

    if type(opts.set_lsp_keymaps.preserve_mappings) == 'boolean' then
      keep_defaults = opts.set_lsp_keymaps.preserve_mappings
    end
  end

  local map = function(m, lhs, rhs)
    if omit[lhs] then
      return
    end

    if keep_defaults and s.map_check(m, lhs) then
      return
    end

    local key_opts = {noremap = true, silent = true}
    vim.api.nvim_buf_set_keymap(bufnr, m, lhs, rhs, key_opts)
  end

  s.supported_keymaps(map)

  map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
  map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
  map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')
  map('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')
  map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')
  map('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')
  map('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
end

s.map_check = function(mode, lhs)
  local cache = state.omit_keys[mode][lhs]
  if cache == nil then
    local available = vim.fn.mapcheck(lhs, mode) == ''
    state.omit_keys[mode][lhs] = not available

    return not available
  end

  return cache
end

function M.highlight_symbol(client, bufnr)
  if client == nil 
    or s.supports_method(client, 'textDocument/documentHighlight') == false
  then
    return
  end

  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local autocmd = [[
    augroup lsp_zero_highlight_symbol
      autocmd! * <buffer=%d>
      autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
      autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
    augroup END
  ]]

  vim.cmd(autocmd:format(bufnr))
end

s.set_capabilities = function(current)
  if state.capabilities == nil then
    local cmp_lsp = {}

    if global_config.cmp_capabilities then
      local ok, source = pcall(require, 'cmp_nvim_lsp')

      if ok then
        cmp_lsp = source.default_capabilities()
      else
        local msg = "[lsp-zero] Could not find cmp_nvim_lsp. Please install cmp_nvim_lsp or set the option cmp_capabilities to false."
        vim.notify(msg, vim.log.levels.WARN)
      end
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
    autostart = s.if_nil(lsp.autostart, true)
  end

  local has_filetype = vim.bo.filetype ~= ''

  if autostart and lsp.manager and has_filetype then
    lsp.manager:try_add_wrapper(vim.api.nvim_get_current_buf())
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

M.format_cmd = function(line1, line2, count, bang, list)
  local execute = vim.lsp.buf.format
  local async = bang
  local server = list[1]
  local timeout = list[2]

  if #list > 2 then
    vim.notify('Too many arguments for LspZeroFormat', vim.log.levels.ERROR)
    return
  end

  if timeout and timeout:find('timeout=') then
    timeout = timeout:gsub('timeout=', '')
    timeout = tonumber(timeout)
  end

  if server and server:find('timeout=') then
    timeout = server:gsub('timeout=', '')
    timeout = tonumber(timeout)
    server = list[2]
  end

  if execute then
    execute({async = async, name = server, timeout_ms = timeout})
    return
  end

  local has_range = line2 == count

  if server then
    s.format_with(server, has_range, async, timeout)
    return
  end

  execute = vim.lsp.buf.formatting

  if has_range then
    execute = vim.lsp.buf.range_formatting
  end

  if not async then
    if has_range then
      execute = function()
        s.format_range_fallback(timeout)
      end
    else
      execute = function()
        vim.lsp.buf.formatting_sync(nil, timeout)
      end
    end
  end

  execute()
end

s.format_with = function(server, has_range, async, timeout)
  local active = vim.lsp.get_active_clients()
  local buffer = vim.api.nvim_get_current_buf()
  
  local client = vim.tbl_filter(function(c)
    return c.name == server
  end, active)[1]

  if client == nil then
    return
  end

  local lsp_format = require('lsp-zero.format')
  local execute = lsp_format.apply_fallback

  if has_range then
    execute = lsp_format.apply_range_fallback
  end

  if async then
    if has_range then
      execute = lsp_format.apply_async_range_fallback
    else
      execute = lsp_format.apply_async_fallback
    end
  end

  local config = {timeout_ms = timeout}

  execute(client, buffer, config)
end

s.format_range_fallback = function(timeout)
  local lsp_format = require('lsp-zero.format')
  local buffer = vim.api.nvim_get_current_buf()
  local config = {
    timeout_ms = timeout
  }

  for _, c in ipairs(vim.lsp.get_active_clients()) do
    if vim.lsp.buf_is_attached(buffer, c.id)
      and s.supports_method(c, 'textDocument/rangeFormatting')
    then
      lsp_format.apply_range_fallback(c, buffer, config)
    end
  end
end

s.supported_keymaps = function(map)
  map('n', 'gl', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>')
  map('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>')
  map('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>')

  map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
  map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
  map('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')
end

s.supports_method = function(client, method)
  return client.supports_method(method)
end

s.if_nil = function(val, fallback)
  if val ~= nil then
    return val
  end

  return fallback
end

if vim.fn.has('nvim-0.11') == 1 then
  s.supported_keymaps = function(map)
    map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
    map('n', 'K', '<cmd>lua vim.lsp.buf.hover({border = "rounded"})<cr>')
    map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help({border = "rounded"})<cr>')
  end
  s.supports_method = function(client, method)
    return client:supports_method(method)
  end
elseif vim.fn.has('nvim-0.9') == 1 then
  s.supported_keymaps = function(map)
    map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
    map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
    map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

    map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
    map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
    map('x', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
  end
elseif vim.fn.has('nvim-0.6') == 1 then
  s.supported_keymaps = function(map)
    map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
    map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
    map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

    map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
    map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
    map('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')
  end
end

return M

