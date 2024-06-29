local M = {
  setup_done = false,
  common_attach = nil,
  default_config = false,
  cache_capabilities = nil,
}

local state = {
  exclude = {},
  omit_keys = {n = {}, x = {}},
}

local s = {}

---@diagnostic disable-next-line: deprecated
s.islist = vim.islist or vim.tbl_islist

function M.extend_lspconfig()
  if M.setup_done then
    return
  end

  if M.has_configs() then
    local msg = '[lsp-zero] Some language servers have been configured before\n'
     .. 'you called the function .extend_lspconfig().'

     vim.notify(msg, vim.log.levels.WARN)
   end

  local util = require('lspconfig.util')

  util.on_setup = util.add_hook_after(util.on_setup, function(config, user_config)
    if type(M.default_config) == 'table' then
      s.apply_global_config(config, user_config, M.default_config)
    end
  end)

  M.setup_done = true
end

function M.set_buf_commands(bufnr)
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

function M.default_keymaps(opts)
  local buffer = opts.buffer
  local keep_defaults = true
  local exclude = {}

  if type(opts.preserve_mappings) == 'boolean' then
    keep_defaults = opts.preserve_mappings
  end

  if type(opts.exclude) == 'table' then
    exclude = opts.exclude
  end

  local map = function(m, lhs, rhs, desc)
    if vim.tbl_contains(exclude, lhs) then
      return
    end

    if keep_defaults and s.map_check(m, lhs) then
      return
    end

    local key_opts = {buffer = buffer, desc = desc, nowait = true}
    vim.keymap.set(m, lhs, rhs, key_opts)
  end

  map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', 'Hover documentation')
  map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', 'Go to definition')
  map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', 'Go to declaration')
  map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', 'Go to implementation')
  map('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', 'Go to type definition')
  map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', 'Go to reference')
  map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', 'Show function signature')
  map('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', 'Rename symbol')
  map('n', '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', 'Format file')
  map('x', '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', 'Format selection')
  map('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', 'Execute code action')
end

function M.client_capabilities()
  local user_defaults = vim.tbl_get(M, 'default_config', 'capabilities')
  local lsp_capabilities = nil

  if M.setup_done then
    lsp_capabilities = vim.tbl_deep_extend(
      'force',
      vim.lsp.protocol.make_client_capabilities(),
      require('lspconfig.util').default_config.capabilities
    )
  end

  if user_defaults and lsp_capabilities then
    return vim.tbl_deep_extend('force', lsp_capabilities, user_defaults)
  end

  if user_defaults == nil and lsp_capabilities == nil then
    return vim.lsp.protocol.make_client_capabilities()
  end

  if lsp_capabilities == nil then
    local base = vim.lsp.protocol.make_client_capabilities()
    return vim.tbl_deep_extend('force', base, user_defaults)
  end

  if user_defaults == nil then
    return lsp_capabilities
  end

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

function M.setup(name, opts)
  if type(name) ~= 'string' or state.exclude[name] then
    return false
  end

  if type(opts) ~= 'table' then
    opts = {}
  end

  local lsp = require('lspconfig')[name]

  if lsp.manager then
    return false
  end

  local ok = pcall(lsp.setup, opts)

  if not ok then
    local msg = '[lsp-zero] Failed to setup %s.\n'
      .. 'Configure this server using lspconfig to get the full error message.'

    vim.notify(msg:format(name), vim.log.levels.WARN)
    return false
  end

  state.exclude[name] = true
  return true
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
            vim.env.VIMRUNTIME,
            '${3rd}/luv/library'
          }
        }
      }
    }
  }

  return vim.tbl_deep_extend('force', config, opts or {})
end

function M.nvim_lua_settings(client, opts)
  if type(client) ~= 'table' then
    local msg = '[lsp-zero] Must provide an instance of LSP client to .nvim_lua_init()'
    vim.notify(msg, vim.log.levels.WARN)
    return
  end

  local path = vim.tbl_get(client, 'workspace_folders', 1, 'name')

  if path == nil then
    return
  end

  local uv = vim.uv or vim.loop

  -- Don't do anything if there is project local config
  if uv.fs_stat(path .. '/.luarc.json')
    or uv.fs_stat(path .. '/.luarc.jsonc')
  then
    return
  end

  -- Apply neovim specific settings
  if type(opts) ~= 'table' then
    opts = {}
  end

  local lua_opts = M.nvim_workspace({
    settings = {Lua = opts}
  })

  if client.config.settings == nil then
    client.config.settings = lua_opts.settings
    return
  end

  client.config.settings = vim.tbl_deep_extend(
    'force',
    client.config.settings,
    lua_opts.settings
  )
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

function M.set_sign_icons(opts)
  opts = opts or {}

  if vim.fn.has('nvim-0.10') == 1 then
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

function s.tbl_merge(old_val, new_val)
  for k, v in pairs(new_val) do
    if s.is_keyval(old_val[k]) and s.is_keyval(v) then
      s.tbl_merge(old_val[k], v)
    else
      old_val[k] = v
    end
  end
end

function s.is_keyval(v)
  return type(v) == 'table' and not s.islist(v)
end

function s.compose_fn(config_callback, user_callback)
  return function(...)
    config_callback(...)
    user_callback(...)
  end
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

return M

