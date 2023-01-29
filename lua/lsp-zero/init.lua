local M = {defaults = {}}
local s = {
  setup_status = 'pending',
  lsp_project_configs = {},
  args = {
    preset = 'none',
    preset_overrides = {},
    servers = {},
    skip_servers = {},
    install = {},
    server_config = {}
  }
}

local Server = require('lsp-zero.server')

if vim.fn.has('nvim-0.8') == 1 then
  Server.extend_lspconfig()
end

function M.setup()
  if s.setup_status == 'complete' then
    return
  end

  s.setup_status = 'complete'

  require('lsp-zero.setup').apply(s.args)
end

function M.preset(opts)
  if type(opts) == 'string' then
    s.args.preset = opts
  end

  if type(opts) == 'table' and type(opts.name) == 'string' then
    s.args.preset = opts.name
    s.args.preset_overrides = opts
  end

  return M
end

function M.set_preferences(opts)
  if type(opts) == 'table' then
    s.args.preset_overrides = opts
  end
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

function M.build_options(_, opts)
  local defaults = {
    capabilities = Server.client_capabilities()
  }

  return vim.tbl_deep_extend('force', defaults, opts or {})
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
      Server.default_config,
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

function M.nvim_workspace(opts)
  opts = opts or {}
  local server_opts = M.defaults.nvim_workspace()

  if opts.library then
    server_opts.settings.Lua.workspace.library = opts.library
  end

  if opts.root_dir then
    server_opts.root_dir = opts.root_dir
  end

  if opts.force_setup == true then
    server_opts.force_setup = true
  end

  local nvim_source = pcall(require, 'cmp_nvim_lua')

  if nvim_source then
    server_opts.before_init = function()
      local cmp_sources = require('cmp').get_config().sources
      local names = vim.tbl_map(function(x) return x.name end, cmp_sources)

      if not vim.tbl_contains(names, 'nvim_lua') then
        table.insert(cmp_sources, {name = 'nvim_lua'})
        require('cmp').setup.filetype('lua', {sources = cmp_sources})
      end
    end
  end

  M.configure('sumneko_lua', server_opts)
end

function M.setup_nvim_cmp(opts)
  if type(opts) == 'table' then
    s.cmp_opts = opts
  end
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

  Server.user_settings({enable_keymaps = opts.set_lsp_keymaps})
  M.on_attach(opts.on_attach)

  Server.extend_lspconfig()
end

function M.defaults.diagnostics(opts)
local config = Server.diagnostics_config()

  if type(opts) == 'table' then
    return vim.tbl_deep_extend('force', config, opts)
  end

  return config
end

function M.defaults.cmp_mappings(opts)
  local config = require('lsp-zero.cmp-setup').default_mappings()

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
  local config = require('lsp-zero.cmp-setup').cmp_config()

  if type(opts) == 'table' then
    return vim.tbl_deep_extend('force', config, opts)
  end

  return config
end

function M.defaults.nvim_workspace(opts)
  return Server.nvim_workspace(opts)
end

return M

