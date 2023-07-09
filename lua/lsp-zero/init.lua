local noop = function() end

local M = {}
local s = {
  lsp_project_configs = {},
}

M.setup = noop
M.ensure_installed = function()
  local msg = '[lsp-zero] The function .ensure_installed() has been removed.\n'
    .. 'Use the module mason-lspconfig to install your LSP servers.\n'
    .. 'See :help lsp-zero-guide:ensure-installed'
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

function M.installed()
  local ok, mason = pcall(require, 'mason-lspconfig')
  if not ok then
    return {}
  end

  return mason.get_installed_servers()
end

function M.preset(opts)
  opts = opts or {}

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

  local setup = function()
    local Server = require('lsp-zero.server')
    local exclude = opts.exclude or {}
    local autostart = not (vim.bo.filetype == '')
    local bufnr = vim.api.nvim_get_current_buf()

    for _, name in ipairs(list) do
      if not vim.tbl_contains(exclude, name) then
        local ok = Server.setup(name, {})

        if autostart and ok then
          require('lspconfig')[name].manager.try_add_wrapper(bufnr)
        end
      end
    end
  end

  if opts.defer then
    vim.schedule(setup)
    return
  end

  setup()
end

function M.configure(name, opts)
  local Server = require('lsp-zero.server')

  M.store_config(name, opts)
  Server.setup(name, opts)
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
  local has_filetype = vim.bo.filetype ~= ''

  for _, name in ipairs(servers) do
    local config = vim.tbl_deep_extend(
      'force',
      s.lsp_project_configs[name] or {},
      opts or {}
    )

    local lsp = require('lspconfig')[name]
    lsp.setup(config)

    if lsp.manager and has_filetype then
      lsp.manager.try_add_wrapper(bufnr)
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

function M.new_server(opts)
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

return M

