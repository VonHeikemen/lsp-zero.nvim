local M = {defaults = {}}
local s = {
  setup_status = 'pending',
  lsp_project_configs = {},
  args = {
    preset = 'none',
    cmp_opts = {},
    servers = {},
    skip_servers = {},
    install = {},
    server_config = {}
  }
}

local Server = require('lsp-zero.server')

if vim.fn.has('nvim-0.8') == 1 then
  Server.extend_lspconfig()
else
  local msg = '[lsp-zero] You need Neovim v0.8 or greater to use lsp-zero v2.\n'
    .. 'Use the v1.x branch if you need compatibility with Neovim v0.7 or lower.'
  vim.notify(msg, vim.log.levels.WARN)
end

function M.cmp_action()
  return require('lsp-zero.cmp-mapping')
end

function M.setup()
  if s.setup_status == 'complete' then
    return
  end

  s.setup_status = 'complete'

  require('lsp-zero.setup').apply(s.args)
end

function M.preset(opts)
  require('lsp-zero.settings').preset(opts)
  return M
end

function M.setup_servers(list)
  if type(list) ~= 'table' then
    return
  end

  for _, name in ipairs(list) do
    s.args.servers[name] = {}
  end
end

function M.configure(name, opts)
  local arg_type = type(opts)
  if arg_type == 'table' then
    s.args.servers[name] = opts
  elseif opts then
    s.args.servers[name] = {}
  end
end

function M.skip_server_setup(list)
  if type(list) ~= 'table' then
    return
  end

  for _, name in ipairs(list) do
    s.args.skip_servers[name] = true
  end
end

function M.ensure_installed(list)
  if type(list) == 'table' then
    s.args.install = list
  end
end

function M.on_attach(fn)
  if type(fn) == 'function' then
    Server.common_attach = fn
  end
end

function M.set_server_config(opts)
  if type(opts) == 'table' then
    Server.default_config = opts
  end
end

function M.build_options(name, opts)
  Server.skip_server(name)

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

  for _, name in ipairs(servers) do
    local config = vim.tbl_deep_extend(
      'force',
      s.lsp_project_configs[name] or {},
      opts or {}
    )

    local lsp = require('lspconfig')[name]
    lsp.setup(config)

    if lsp.manager and vim.bo.filetype ~= '' then
      lsp.manager.try_add_wrapper()
    end
  end
end

function M.nvim_lua_ls(opts)
  return Server.nvim_workspace(opts)
end

function M.set_sign_icons(opts)
  Server.set_sign_icons(opts)
end

function M.extend_lspconfig(opts)
  if s.args.preset ~= 'none' then
    return
  end

  local ok = pcall(require, 'lspconfig')

  if not ok then
    local msg = "[lsp-zero] Could not find the module lspconfig. Please make sure 'nvim-lspconfig' is installed."
    vim.notify(msg, vim.log.levels.ERROR)
    return
  end

  local defaults_opts = {
    set_lsp_keymaps = false,
    capabilities = {},
    on_attach = nil,
  }

  opts = vim.tbl_deep_extend('force', defaults_opts, opts or {})

  Server.enable_keymaps = opts.set_lsp_keymaps

  if Server.enable_keymaps == true then
    Server.enable_keymaps = {}
  end

  M.on_attach(opts.on_attach)

  if type(opts.capabilities) == 'table' then
    Server.set_default_capabilities(opts.capabilities)
  end
end

function M.default_keymaps(opts)
  opts = opts or {buffer = 0}
  Server.default_keymaps(opts)
end

function M.extend_cmp(opts)
  require('lsp-zero.cmp-setup').extend(opts)
end


---
-- Deprecated functions
---

function M.set_preferences(opts)
  if type(opts) == 'table' then
    require('lsp-zero.settings').set(opts)
  end
end

function M.nvim_workspace(opts)
  opts = opts or {}
  local server_opts = M.defaults.nvim_workspace()

  if opts.library then
    server_opts.settings.Lua.workspace.library = opts.library
  end

  if opts.root_dir then
    server_opts.root_dir = opts.root_dir
  end

  M.configure('lua_ls', server_opts)
end

function M.setup_nvim_cmp(opts)
  if type(opts) == 'table' then
    s.args.cmp_opts = opts
  end
end

function M.defaults.diagnostics(opts)
  local config = Server.diagnostics_config()

  if type(opts) == 'table' then
    return vim.tbl_deep_extend('force', config, opts)
  end

  return config
end

function M.defaults.nvim_workspace(opts)
  return Server.nvim_workspace(opts)
end

function M.defaults.cmp_mappings(opts)
  local cmp_setup = require('lsp-zero.cmp-setup')
  local config = vim.tbl_deep_extend(
    'force',
    cmp_setup.basic_mappings(),
    cmp_setup.extra_mappings()
  )

  if type(opts) == 'table' then
    return vim.tbl_deep_extend('force', config, opts)
  end

  return config
end

function M.defaults.cmp_sources(opts)
  local config = require('lsp-zero.cmp-setup').sources()

  if type(opts) == 'table' then
    return vim.tbl_deep_extend('force', config, opts)
  end

  return config
end

function M.defaults.cmp_config(opts)
  local cmp_setup = require('lsp-zero.cmp-setup')
  local config = cmp_setup.cmp_config()
  config.sources = cmp_setup.sources()
  config.mapping = M.defaults.cmp_mappings()

  if type(opts) == 'table' then
    return vim.tbl_deep_extend('force', config, opts)
  end

  return config
end

return M

