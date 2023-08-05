local noop = function() end

local M = {}
local s = {
  lsp_project_configs = {},
}

M.noop = noop

local function notify(msg)
  if vim.g.lsp_zero_api_warnings == 0 then
    return
  end

  vim.notify(msg, vim.log.levels.WARN)
end

function M.cmp_action()
  return require('lsp-zero.cmp-mapping')
end

function M.extend_cmp(opts)
  require('lsp-zero.cmp').extend(opts)
end

function M.extend_lspconfig()
  require('lsp-zero.server').extend_lspconfig()
end

function M.preset(opts)
  opts = opts or {}

  if type(opts) == 'string' then
    local msg = '[lsp-zero] named presets are not supported.\n'
      .. 'See the available options in the help page\n'
      .. ':help lsp-zero.preset()\n\n'
    notify(msg)
    opts = {}
  end

  if opts.extend_lspconfig == nil then
    opts.extend_lspconfig = true
  end

  require('lsp-zero.ui').setup({
    float_border = opts.float_border,
    set_signcolumn = opts.set_signcolumn,
  })

  local Server = require('lsp-zero.server')

  Server.setup_autocmd()

  if opts.extend_lspconfig then
    Server.extend_lspconfig()
  end

  return M
end

function M.setup_servers(list, opts)
  if type(list) ~= 'table' then
    return
  end

  opts = opts or {}

  local Server = require('lsp-zero.server')
  local exclude = opts.exclude or {}

  for _, name in ipairs(list) do
    if not vim.tbl_contains(exclude, name) then
      Server.setup(name, {}, false)
    end
  end
end

function M.configure(name, opts)
  local Server = require('lsp-zero.server')

  M.store_config(name, opts)
  Server.setup(name, opts, false)
end

function M.default_setup(name)
  require('lsp-zero.server').setup(name, {}, false)
end

function M.on_attach(fn)
  local Server = require('lsp-zero.server')
  Server.setup_autocmd()

  if type(fn) == 'function' then
    Server.common_attach = fn
  end
end

function M.set_server_config(opts)
  if type(opts) == 'table' then
    local Server = require('lsp-zero.server')
    Server.default_config = opts
  end
end

function M.build_options(name, opts)
  local Server = require('lsp-zero.server')

  Server.skip_setup(name)

  local defaults = {
    capabilities = Server.client_capabilities(),
    on_attach = function() end,
  }

  return vim.tbl_deep_extend(
    'force',
    defaults,
    Server.default_config or {},
    opts or {}
  )
end

function M.store_config(name, opts)
  if type(opts) == 'table' then
    s.lsp_project_configs[name] = opts
  end
end

function M.use(servers, opts)
  if type(servers) == 'string' then
    servers = {servers}
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local has_filetype = not (vim.bo.filetype == '')
  local buffer = vim.api.nvim_get_current_buf()
  local lspconfig = require('lspconfig')
  local user_opts = opts or {}

  for _, name in ipairs(servers) do
    local config = vim.tbl_deep_extend(
      'force',
      s.lsp_project_configs[name] or {},
      user_opts
    )

    local lsp = lspconfig[name]
    lsp.setup(config)

    if lsp.manager and has_filetype then
      pcall(lsp.manager.try_add_wrapper, buffer)
    end
  end
end

function M.nvim_lua_ls(opts)
  return require('lsp-zero.server').nvim_workspace(opts)
end

function M.set_sign_icons(opts)
  require('lsp-zero.server').set_sign_icons(opts)
end

function M.default_keymaps(opts)
  opts = opts or {buffer = 0}
  require('lsp-zero.server').default_keymaps(opts)
end

function M.get_capabilities()
  return require('lsp-zero.server').client_capabilities()
end

function M.new_client(opts)
  if type(opts) ~= 'table' then
    return
  end

  local name = opts.name or ''
  local config = M.build_options(name, opts)

  require('lsp-zero.client').setup(config)
end

function M.format_on_save(opts)
  return require('lsp-zero.format').format_on_save(opts)
end

function M.format_mapping(...)
  return require('lsp-zero.format').format_mapping(...)
end

function M.buffer_autoformat(...)
  return require('lsp-zero.format').buffer_autoformat(...)
end

function M.async_autoformat(...)
  return require('lsp-zero.format').async_autoformat(...)
end

M.dir = {}

function M.dir.find_all(list)
  return require('lsp-zero.dir').find_all(list)
end

function M.dir.find_first(list)
  return require('lsp-zero.dir').find_first(list)
end

M.omnifunc = {}

function M.omnifunc.setup(opts)
  require('lsp-zero.omnifunc').setup(opts)
end

---
-- Handle removed functions
---

M.setup = noop
M.set_preferences = noop

M.defaults = {}

function M.defaults.cmp_config(opts)
  local config = require('lsp-zero.cmp').get_config({
    set_lsp_source = true,
    set_mappings = true,
  })

  return vim.tbl_deep_extend('force', config, opts or {})
end

function M.defaults.cmp_mappings(opts)
  local defaults = require('lsp-zero.cmp').basic_mappings()
  return vim.tbl_deep_extend('force', defaults, opts or {})
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

return M

