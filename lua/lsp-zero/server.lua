local M = {
  default_config = false,
  common_attach = nil,
  enable_keymaps = false,
}

local s = {}

local state = {
  exclude = {},
  capabilities = nil,
  run_installer = false,
  omit_keys = {n = {}, i = {}, x = {}},
}

function M.extend_lspconfig()
  M.set_global_commands()

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
        local id = vim.tbl_get(event, 'data', 'client_id')
        local client = {}

        if id then
          client = vim.lsp.get_client_by_id(id)
        end

        M.common_attach(client, bufnr)
      end
    end
  })

  local lsp_txt = vim.api.nvim_get_runtime_file('doc/lspconfig.txt', 1) or {}

  if #lsp_txt == 0 then
    return
  end

  local util = require('lspconfig.util')

  util.default_config.capabilities = s.set_capabilities()

  util.on_setup = util.add_hook_after(util.on_setup, function(config, user_config)
    -- looks like some lsp servers can override the capabilities option
    -- during "config definition". so, now we have to do this.
    s.ensure_capabilities(config, user_config)

    if type(M.default_config) == 'table' then
      s.apply_global_config(config, user_config, M.default_config)
    end
  end)
end

function M.setup(name, opts)
  if type(name) ~= 'string' or state.exclude[name] then
    return
  end

  if type(opts) ~= 'table' then
    opts = {}
  end

  M.skip_server(name)

  local lsp = require('lspconfig')[name]

  if lsp.manager then
    return
  end

  local ok = pcall(lsp.setup, opts)

  if not ok then
    local msg = '[lsp-zero] Failed to setup %s.\n\n'
      .. 'Configure this server manually using lspconfig to get the full error message.\n'
      .. 'Or use the function .skip_server_setup() to disable the server.'

    vim.notify(msg:format(name), vim.log.levels.WARN)
  end
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
  local buffer = opts.buffer or 0
  local keep_defaults = true
  local omit = {}

  if type(opts.preserve_mappings) == 'boolean' then
    keep_defaults = opts.preserve_mappings
  end

  if type(opts.omit) == 'table' then
    omit = opts.omit
  end

  local map = function(m, lhs, rhs)
    if vim.tbl_contains(omit, lhs) then
      return
    end

    if keep_defaults and s.map_check(m, lhs) then
      return
    end

    local key_opts = {buffer = buffer}
    vim.keymap.set(m, lhs, rhs, key_opts)
  end

  s.supported_keymaps(map)

  map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
  map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
  map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')
  map('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')
  map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')
  map('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')
  map('n', '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>')
  map('x', '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>')
  map('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
end

function M.set_sign_icons(opts)
  opts = opts or {}

  if vim.diagnostic.count then
    local ds = vim.diagnostic.severity
    local levels = {
      [ds.ERROR] = 'error',
      [ds.WARN] = 'warn',
      [ds.INFO] = 'info',
      [ds.HINT] = 'hint'
    }

    local text = {}

    for i, l in pairs(levels) do
      if type(opts[l]) == 'string' then
        text[i] = opts[l]
      end
    end

    vim.diagnostic.config({signs = {text = text}})
    return
  end

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
  if state.capabilities == nil then
    return s.set_capabilities()
  end

  return state.capabilities
end

function s.set_buf_commands(bufnr)
  local bufcmd = vim.api.nvim_buf_create_user_command
  local format = function(input)
    if #input.fargs > 2 then
      vim.notify('Too many arguments for LspZeroFormat', vim.log.levels.ERROR)
      return
    end

    local server = input.fargs[1]
    local timeout = input.fargs[2]

    if timeout and timeout:find('timeout=') then
      timeout = timeout:gsub('timeout=', '')
      timeout = tonumber(timeout)
    end

    if server and server:find('timeout=') then
      timeout = server:gsub('timeout=', '')
      timeout = tonumber(timeout)
      server = input.fargs[2]
    end

    vim.lsp.buf.format({
      async = input.bang,
      timeout_ms = timeout,
      name = server,
    })
  end

  bufcmd(bufnr, 'LspZeroFormat', format, {range = true, bang = true, nargs = '*'})

  bufcmd(
    bufnr,
    'LspZeroWorkspaceRemove',
    'lua vim.lsp.buf.remove_workspace_folder()',
    {}
  )
end

function M.skip_server(name)
  if type(name) == 'string' then
    state.exclude[name] = true
  end
end

function M.setup_installer()
  if state.run_installer then
    return
  end

  state.run_installer = true

  local installer = require('lsp-zero.installer')
  local config = require('lsp-zero.settings').get()

  if config.call_servers == 'local' and installer.state == 'init' then
    installer.setup()
  end
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

  local autocmd = vim.api.nvim_create_autocmd
  local augroup = vim.api.nvim_create_augroup('lsp_zero_highlight_symbol', {clear = false})

  vim.api.nvim_clear_autocmds({buffer = bufnr, group = augroup})

  autocmd({'CursorHold', 'CursorHoldI'}, {
    group = augroup,
    buffer = bufnr,
    callback = vim.lsp.buf.document_highlight,
  })

  autocmd({'CursorMoved', 'CursorMovedI'}, {
    group = augroup,
    buffer = bufnr,
    callback = vim.lsp.buf.clear_references,
  })
end

function s.set_capabilities(current)
  if state.capabilities == nil then
    local cmp_txt = vim.api.nvim_get_runtime_file('doc/cmp.txt', 1)
    local ok_lsp_source, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
    local cmp_default_capabilities = {}
    local base = nil

    local ok_lspconfig, lspconfig = pcall(require, 'lspconfig')
    if ok_lspconfig then
      base = lspconfig.util.default_config.capabilities
    end

    if base == nil then
      base = vim.lsp.protocol.make_client_capabilities()
    end

    if #cmp_txt > 0 and ok_lsp_source then
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

function s.ensure_capabilities(server_config, user_config)
  local config_def = require('lspconfig.configs')[server_config.name]

  if type(config_def) ~= 'table' then
    return
  end

  local get_completion = function(val)
    return vim.tbl_get(val, 'capabilities', 'textDocument', 'completion')
  end

  local defaults = vim.tbl_get(config_def, 'document_config', 'default_config')
  local default_opts = get_completion(defaults or {})

  if defaults == nil or default_opts == nil then
    return
  end

  local user_opts = get_completion(user_config) or {}
  local plugin_opts = s.set_capabilities().textDocument.completion

  local completion_opts = vim.tbl_deep_extend(
    'force',
    default_opts,
    plugin_opts,
    user_opts
  )

  server_config.capabilities.textDocument.completion = completion_opts
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

function s.apply_global_config(config, user_config, defaults)
  local new_config = vim.deepcopy(defaults)
  s.tbl_merge(new_config, user_config)

  for key, val in pairs(new_config) do
    if s.is_keyval(val) and s.is_keyval(config[key]) then
      s.tbl_merge(config[key], val)
    elseif (
      key == 'on_new_config'
      and config[key]
      and config[key] ~= new_config[key]
    ) then
      local cb = config[key]
      config[key] = s.compose_fn(cb, new_config[key])
    else
      config[key] = val
    end
  end
end

function s.compose_fn(config_callback, user_callback)
  return function(...)
    config_callback(...)
    user_callback(...)
  end
end

function s.is_keyval(v)
  return type(v) == 'table' and not vim.tbl_islist(v)
end

function s.tbl_merge(old_val, new_val)
  for k, v in pairs(new_val) do
    if s.is_keyval(old_val[k]) and s.is_keyval(v) then
      s.tbl_merge(old_val[k], v)
    else
      old_val[k] = v
    end
  end
end

s.supports_method = function(client, method)
  return client.supports_method(method)
end

s.supported_keymaps = function(map)
  map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
  map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
  map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
  map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
  map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
  map('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')
end

if vim.fn.has('nvim-0.11') == 1 then
  s.supports_method = function(client, method)
    return client:supports_method(method)
  end
  s.supported_keymaps = function(map)
    map('n', 'K', '<cmd>lua vim.lsp.buf.hover({border = vim.g.lsp_zero_border_style})<cr>')
    map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help({border = vim.g.lsp_zero_border_style})<cr>')
    map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
    map('x', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
  end
elseif vim.fn.has('nvim-0.9') == 1 then
  s.supported_keymaps = function(map)
    map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
    map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
    map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
    map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
    map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
    map('x', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
  end
end

return M

