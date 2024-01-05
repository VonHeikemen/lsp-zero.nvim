local M = {
  setup_done = false,
  common_attach = nil,
  has_lspconfig = false,
  default_config = false,
}

local s = {}

local state = {
  exclude = {},
  autocmd = false,
  capabilities = nil,
  set_omnifunc = false,
  extend_lspconfig = false,
  omit_keys = {n = {}, i = {}, x = {}},
}

function M.attach(client, bufnr)
  if client == nil then
    return
  end

  local prev_clients = vim.b.lsp_zero_clients or {}

  if vim.tbl_contains(prev_clients, client.id) then
    return
  else
    table.insert(prev_clients, client.id)
    vim.b.lsp_zero_clients = prev_clients
  end

  s.set_buf_commands(bufnr)

  if state.set_omnifunc then
    require('lsp-zero.omnifunc').enable(bufnr)
  end

  if M.common_attach then
    M.common_attach(client, bufnr)
  end
end

function M.extend_lspconfig()
  if M.setup_done then
    return
  end

  local util = require('lspconfig.util')

  util.default_config.capabilities = s.set_capabilities()
  util.default_config.on_attach = M.attach

  util.on_setup = util.add_hook_after(util.on_setup, function(config, user_config)
    -- looks like some lsp servers can override the capabilities option
    -- during "config definition". so, now we have to do this.
    s.ensure_capabilities(config, user_config)

    if type(M.default_config) == 'table' then
      s.apply_global_config(config, user_config, M.default_config)
    end

    if user_config.on_attach then
      config.on_attach = util.add_hook_before(config.on_attach, M.attach)
    end
  end)

  M.setup_done = true
end

function M.setup(name, opts)
  if type(name) ~= 'string' or state.exclude[name] then
    return false
  end

  if type(opts) ~= 'table' then
    opts = {}
  end

  M.skip_setup(name)

  local lsp = require('lspconfig')[name]

  if lsp.manager then
    return false
  end

  local ok = pcall(lsp.setup, opts)

  if not ok then
    local msg = '[lsp-zero] Failed to setup %s.\n\n'
      .. 'Configure this server manually using lspconfig to get the full error message.\n'
      .. 'Or use the function .skip_server_setup() to disable the server.'

    vim.notify(msg:format(name), vim.log.levels.WARN)
    return false
  end

  return true
end

function M.default_keymaps(opts)
  local buffer = opts.buffer or vim.api.nvim_get_current_buf()
  local keep_defaults = true
  local exclude = {}

  if type(opts.preserve_mappings) == 'boolean' then
    keep_defaults = opts.preserve_mappings
  end

  if type(opts.exclude) == 'table' then
    exclude = opts.exclude
  end

  local map = function(m, lhs, rhs)
    if vim.tbl_contains(exclude, lhs) then
      return
    end

    if keep_defaults and s.map_check(m, lhs) then
      return
    end

    local key_opts = {buffer = buffer}
    vim.keymap.set(m, lhs, rhs, key_opts)
  end

  map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
  map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
  map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
  map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')
  map('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')
  map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')
  map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')
  map('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

  if vim.lsp.buf.format then
    map('n', '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>')
    map('x', '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>')
  else
    map('n', '<F3>', '<cmd>lua vim.lsp.buf.formatting()<cr>')
    map('x', '<F3>', '<cmd>lua vim.lsp.buf.range_formatting()<cr>')
  end

  map('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')

  if vim.lsp.buf.range_code_action then
    map('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')
  else
    map('x', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
  end

  map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
  map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
  map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
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
    local ok = pcall(require, 'lspconfig')
    M.has_lspconfig = ok
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

    local async = input.bang
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

    local has_range = input.line2 == input.count

    local options = {
      async = async,
      name = server,
      verbose = true,
      range = has_range,
      formatting_options = {},
      timeout_ms = timeout or 10000,
    }

    if vim.lsp.buf.format then
      vim.lsp.buf.format({
        async = options.async,
        name = options.name,
        timeout_ms = options.timeout_ms
      })
      return
    end

    if server then
      s.apply_format(vim.api.nvim_get_current_buf(), options)
      return
    end

    if has_range then
      vim.lsp.buf.range_formatting()
      return
    end

    if async then
      vim.lsp.buf.formatting()
    else
      vim.lsp.buf.formatting_sync(nil, options.timeout_ms)
    end
  end

  bufcmd(bufnr, 'LspZeroFormat', format, {range = true, bang = true, nargs = '*'})

  bufcmd(
    bufnr,
    'LspZeroWorkspaceRemove',
    'lua vim.lsp.buf.remove_workspace_folder()',
    {}
  )
end

function M.skip_setup(name)
  if type(name) == 'string' then
    state.exclude[name] = true
  end
end

function M.enable_omnifunc()
  state.set_omnifunc = true
end

function M.has_configs()
  local configs = require('lspconfig.configs')

  for _, c in pairs(configs) do
    if c.manager then
      return true
    end
  end

  return false
end

function M.highlight_symbol(client, bufnr)
  if client == nil 
    or client.supports_method('textDocument/documentHighlight') == false
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
    local cmp_default_capabilities = {}
    local base = {}

    if M.has_lspconfig then
      base = require('lspconfig.util').default_config.capabilities
    else
      base = vim.lsp.protocol.make_client_capabilities()
    end

    local ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
    if ok then
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

function s.apply_format(bufnr, opts)
  local format = require('lsp-zero.format')

  if opts.range then
    if opts.async then
      format.apply_range_async(bufnr, opts)
    else
      format.apply_range(bufnr, opts)
    end

    return
  end

  if opts.async then
    format.apply_async(bufnr, opts)
  else
    format.apply_sync(bufnr, opts)
  end
end

return M

