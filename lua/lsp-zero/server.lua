local M = {
  default_config = {},
  common_attach = nil,
  enable_keymaps = false,
}

local s = {}

local state = {
  exclude = {},
  capabilities = nil,
  omit_keys = {n = {}, i = {}, x = {}},
}

function M.extend_lspconfig(opts)
  local ok, lspconfig = pcall(require, 'lspconfig')
  if not ok then
    return
  end

  opts = opts or {}
  local util = lspconfig.util

  -- Set client capabilities
  M.set_default_capabilities(opts.capabilities)

  -- Set on_attach hook
  local lsp_cmds = vim.api.nvim_create_augroup('lsp_zero_attach', {clear = true})
  vim.api.nvim_create_autocmd('LspAttach', {
    group = lsp_cmds,
    desc = 'lsp-zero on_attach',
    callback = function(event)
      local bufnr = event.buf

      if type(M.enable_keymaps) == 'table' then
        M.default_keymaps({
          buffer = bufnr,
          preserve_mappings = M.enable_keymaps.preserve_mappings,
          omit = M.enable_keymaps.omit,
        })
      end

      s.set_buf_commands(bufnr)

      if M.common_attach then
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        M.common_attach(client, bufnr)
      end
    end
  })
end

function M.setup(name, opts, autostart)
  if state.exclude[name] then
    return
  end

  s.skip_server(name)
  opts = opts or {}

  local lsp = require('lspconfig')[name]
  lsp.setup(vim.tbl_deep_extend('force', M.default_config, opts))

  if autostart and lsp.manager and vim.bo.filetype ~= '' then
    lsp.manager.try_add_wrapper()
  end
end

function M.setup_servers(list, opts)
  for name, _ in pairs(opts.ignore) do
    s.skip_server(name)
  end

  for server, config in pairs(list) do
    M.setup(server, config, false)
  end
end

function M.setup_installed(list, opts)
  for name, _ in pairs(opts.ignore) do
    s.skip_server(name)
  end

  local mason = require('mason-lspconfig')

  local servers = mason.get_installed_servers()
  vim.list_extend(servers, vim.tbl_keys(list))

  for _, name in pairs(servers) do
    local config = list[name] or {}
    M.setup(name, config, false)
  end

  mason.setup_handlers({
    function(name)
      local config = list[name] or {}
      M.setup(name, config, true)
    end
  })
end

function M.ensure_installed(list)
  if require('lsp-zero.installer').enabled == false then
    return
  end

  require('mason-lspconfig.settings').set({ensure_installed = list})
  require('mason-lspconfig.ensure_installed')()
end

function M.track_servers()
  local util = require('lspconfig').util
  util.on_setup = util.add_hook_after(util.on_setup, function(config)
    s.setup_installer()
    s.skip_server(config.name)
  end)
end

function M.set_default_capabilities(opts)
  local defaults = require('lspconfig').util.default_config
  defaults.capabilities = s.set_capabilities(opts)
end

function M.set_global_commands()
  local command = vim.api.nvim_create_user_command

  command('LspZeroWorkspaceAdd', 'lua vim.lsp.buf.add_workspace_folder()', {})

  command(
    'LspZeroWorkspaceList',
    'lua vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))',
    {}
  )
end

function M.diagnostics_config()
  return {severity_sort = true}
end

function M.default_keymaps(opts)
  local fmt = function(cmd) return function(str) return cmd:format(str) end end

  local buffer = opts.buffer or 0
  local keep_defaults = true
  local omit = {}

  if type(opts.preserve_mappings) == 'boolean' then
    keep_defaults = opts.preserve_mappings
  end

  if type(opts.omit) == 'table' then
    omit = opts.omit
  end

  local lsp = fmt('<cmd>lua vim.lsp.%s<cr>')
  local diagnostic = fmt('<cmd>lua vim.diagnostic.%s<cr>')

  local map = function(m, lhs, rhs)
    if vim.tbl_contains(omit, lhs) then
      return
    end

    if keep_defaults and s.map_check(m, lhs) then
      return
    end

    local key_opts = {buffer = bufnr}
    vim.keymap.set(m, lhs, rhs, key_opts)
  end

  map('n', 'K', lsp 'buf.hover()')
  map('n', 'gd', lsp 'buf.definition()')
  map('n', 'gD', lsp 'buf.declaration()')
  map('n', 'gi', lsp 'buf.implementation()')
  map('n', 'go', lsp 'buf.type_definition()')
  map('n', 'gr', lsp 'buf.references()')
  map('n', 'gs', lsp 'buf.signature_help()')
  map('n', '<F2>', lsp 'buf.rename()')
  map('n', '<F3>', lsp 'buf.format()')
  map('n', '<F4>', lsp 'buf.code_action()')
  map('x', '<F4>', lsp 'buf.range_code_action()')

  map('n', 'gl', diagnostic 'open_float()')
  map('n', '[d', diagnostic 'goto_prev()')
  map('n', ']d', diagnostic 'goto_next()')
end

function M.set_sign_icons(opts)
  opts = opts or {}

  local sign = function(args)
    if opts[args.name] == nil then
      return
    end

    vim.fn.sign_define(args.hl, {
      texthl = args.hl,
      text = opts[args.name],
      numhl = ''
    })
  end

  sign({name = 'error', hl = 'DiagnosticSignError'})
  sign({name = 'warn', hl = 'DiagnosticSignWarn'})
  sign({name = 'hint', hl = 'DiagnosticSignHint'})
  sign({name = 'info', hl = 'DiagnosticSignInfo'})
end

function M.nvim_workspace(opts)
  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')

  local config = {
    settings = {
      Lua = {
        -- Disable telemetry
        telemetry = {enable = false},
        runtime = {
          -- Tell the language server which version of Lua you're using
          -- (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
          path = runtime_path,
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {'vim'}
        },
        workspace = {
          checkThirdParty = false,
          library = {
            -- Make the server aware of Neovim runtime files
            vim.fn.expand('$VIMRUNTIME/lua'),
            vim.fn.stdpath('config') .. '/lua'
          }
        }
      }
    }
  }

  return vim.tbl_deep_extend('force', config, opts or {})
end

function M.client_capabilities()
  return state.capabilities
end

function s.set_buf_commands(bufnr)
  local bufcmd = vim.api.nvim_buf_create_user_command

  bufcmd(
    bufnr,
    'LspZeroFormat',
    'lua vim.lsp.buf.format({async = <bang> == "!"})',
    {range = true, bang = true}
  )

  bufcmd(
    bufnr,
    'LspZeroWorkspaceRemove',
    'lua vim.lsp.buf.remove_workspace_folder()',
    {}
  )
end

function s.skip_server(name)
  if type(name) == 'string' then
    state.exclude[name] = true
  end
end

function s.set_capabilities(current)
  if state.capabilities == nil then
    local ok_cmp = pcall(require, 'cmp')
    local ok_lsp_source, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
    local cmp_default_capabilities = {}
    local base = {}

    local ok_lspconfig, lspconfig = pcall(require, 'lspconfig')

    if ok_lspconfig then
      base = lspconfig.util.default_config.capabilities
    else
      base = vim.lsp.protocol.make_client_capabilities()
    end

    if ok_cmp and ok_lsp_source then
       cmp_default_capabilities = cmp_lsp.default_capabilities()
    end

    state.capabilities = vim.tbl_deep_extend(
      'force',
      base,
      cmp_default_capabilities,
      current or {}
    )

    return state.capabilities
  end

  if current == nil then
    return state.capabilities
  end

  return vim.tbl_deep_extend('force', state.capabilities, current)
end

function s.map_check(mode, lhs)
  local cache = state.omit_keys[mode][lhs]
  if cache == nil then
    local available = vim.fn.mapcheck(lhs, mode) == ''
    state.omit_keys[mode][lhs] = not available

    return not available
  end

  return cache
end

function s.setup_installer()
  local installer = require('lsp-zero.installer')
  local config = require('lsp-zero.settings').get()

  if config.call_servers == 'local' and installer.state == 'init' then
    installer.setup()
  end

  s.setup_installer = function() return true end
end

return M

