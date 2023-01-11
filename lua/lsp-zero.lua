local M = {}

local preset = require('lsp-zero.presets')
local Server = require('lsp-zero.server')

local internal = {
  setup_status = 'pending',
  cmp_opts = {},
  servers = {},
  install_servers = {},
  fn = {}
}

local safe_call = function(fn, ...)
  local ok, res = pcall(fn, ...)
  if not ok then
    vim.notify(res, vim.log.levels.ERROR)
    return
  end

  return res
end

local run = function(args)
  if internal.setup_status == 'lspconfig_extended' then
    local msg = "[lsp-zero] You can't use .setup() after .extend_lspconfig()"
    vim.notify(msg, vim.log.levels.ERROR)
    return
  end

  internal.setup_status = 'complete'

  local user_config = args.settings
  local configure = Server.setup
  local suggest = user_config.suggest_lsp_servers
  local handle_setup = user_config.setup_servers_on_start

  require('lsp-zero.snippets')

  Server.setup_handlers()

  if user_config.manage_nvim_cmp then
    require('lsp-zero.nvim-cmp-setup').call_setup(args.cmp_opts)
  end

  if user_config.configure_diagnostics then
    Server.setup_diagnostics()
  end

  local manual_setup = suggest == false and handle_setup == false
  local use_global = user_config.call_servers == 'global'

  if use_global then
    return
  end

  local installer = require('lsp-zero.installer')
  installer.choose()
  installer.fn.setup()

  if manual_setup then
    return
  end

  local state = require('lsp-zero.state')

  if suggest then
    safe_call(state.sync)

    local autocmd = [[
      augroup lsp_cmds
        autocmd!
        autocmd FileType * lua vim.defer_fn(require('lsp-zero').suggest_server, 5)
      augroup END
    ]]

    vim.cmd(autocmd)
  else
    -- suggest is false and setup is per project
    -- then there is nothing left to do
    if handle_setup == 'per-project' then return end
  end

  local setup_server = function(name)
    local server_opts = args.server_opts[name] or {}
    configure(name, server_opts)
  end

  installer.fn.use(setup_server)

  if #internal.install_servers > 0 then
    Server.ensure_installed(internal.install_servers)
  end
end

M.setup = function()
  local settings = require('lsp-zero.settings')

  return run({
    settings = settings,
    cmp_opts = internal.cmp_opts,
    server_opts = internal.servers
  })
end

M.use = function(servers, lsp_opts, force)
  local settings = require('lsp-zero.settings')
  local check_enabled = not force
  local enabled = settings.setup_servers_on_start == 'per-project'

  if check_enabled and not enabled then
    return
  end

  lsp_opts = lsp_opts or {}

  if not lsp_opts.root_dir then
    lsp_opts.root_dir = true
  end

  if type(servers) == 'string' then
    servers = {servers}
  end

  for _, name in pairs(servers) do
    local opts = vim.tbl_deep_extend(
      'force',
      {},
      internal.servers[name] or {},
      lsp_opts
    )

    Server.setup(name, opts)
  end
end

M.preset = function(name)
  local opts = M.create_preset(name)
  if not opts[1] then
    error('[lsp-zero] Invalid preset')
    return
  end

  M.set_preferences(opts)
end

M.set_preferences = function(opts)
  local settings = require('lsp-zero.settings')
  if type(opts[1]) ~= 'string' then
    opts[1] = 'custom'
  end

  local new_settings = vim.tbl_deep_extend('force', settings, opts)

  if type(opts.sign_icons) == 'table' and vim.tbl_isempty(opts.sign_icons) then
    new_settings.sign_icons = {}
  elseif opts.sign_icons == false then
    new_settings.sign_icons = {}
  end

  for key, _ in pairs(settings) do
    settings[key] = new_settings[key]
  end
end

M.create_preset = function(name)
  if preset[name] == nil then
    local msg = "[lsp-zero] '%s' is not a valid preset."
    vim.notify(msg:format(name), vim.log.levels.WARN)

    return {false}
  end

  return preset[name]()
end

M.build_options = function(name, opts)
  return Server.build_options(name, opts)
end

M.setup_servers = function(list)
  local settings = require('lsp-zero.settings')
  local delay_setup = not list.force
  list.force = nil

  if settings.setup_servers_on_start and delay_setup then
    return internal.fn.setup_servers(list)
  end

  Server.setup_servers(list)
end

M.configure = function(server_name, opts)
  opts = opts or {}

  local settings = require('lsp-zero.settings')
  local delay_setup = not opts.force_setup
  opts.force_setup = nil

  if settings.setup_servers_on_start and delay_setup then
    return internal.fn.configure(server_name, opts)
  end

  Server.setup(server_name, opts)
end

M.skip_server_setup = function(list)
  local settings = require('lsp-zero.settings')

  if settings.setup_servers_on_start == false then
    return
  end

  local arg_type = type(list)

  if arg_type == 'string' then
    return Server.skip_server(list)
  end

  for _, name in ipairs(list) do
    Server.skip_server(name)
  end
end

M.on_attach = function(fn)
  if type(fn) == 'function' then
    Server.common_on_attach = fn
  end
end

M.set_server_config = function(opts)
  if type(opts) == 'table' then
    Server.default_config = opts
  end
end

M.setup_nvim_cmp = function(opts)
  local settings = require('lsp-zero.settings')

  if settings.manage_nvim_cmp then
    return internal.fn.setup_nvim_cmp(opts)
  end

  local msg = '[lsp-zero] Settings for nvim_cmp should be handled by the user.'
  vim.notify(msg, vim.log.levels.WARN)
end

M.ensure_installed = function(list)
  local settings = require('lsp-zero.settings')
  local use_global = settings.call_servers == 'global'

  if use_global then return end

  if settings.suggest_lsp_servers or settings.setup_servers_on_start then
    internal.install_servers = list
  else
    Server.ensure_installed(list)
  end
end

M.nvim_workspace = function(opts)
  opts = opts or {}
  local settings = require('lsp-zero.settings')
  local server_opts = M.defaults.nvim_workspace()

  if opts.library then
    server_opts.settings.Lua.workspace.library = opts.library
  end

  if opts.root_dir then
    server_opts.root_dir = opts.root_dir
  end

  local nvim_source = pcall(require, 'cmp_nvim_lua')

  if settings.cmp_capabilities and nvim_source then
    server_opts.before_init = function()
      local cmp_sources = require('cmp').get_config().sources
      local names = vim.tbl_map(function(s) return s.name end, cmp_sources)

      if not vim.tbl_contains(names, 'nvim_lua') then
        table.insert(cmp_sources, {name = 'nvim_lua'})
        require('cmp').setup.filetype('lua', {sources = cmp_sources})
      end
    end
  end

  M.configure('sumneko_lua', server_opts)
end

M.set_sign_icons = function(opts)
  local defaults = require('lsp-zero.presets').defaults().sign_icons
  local icon = vim.tbl_deep_extend('force', defaults, opts or {})

  Server.set_sign_icons(icon)
end

M.extend_lspconfig = function(opts)
  if internal.setup_status == 'complete' then
    local msg = "[lsp-zero] You can't use .extend_lspconfig() after .setup()"
    vim.notify(msg, vim.log.levels.WARN)
    return
  end

  if internal.setup_status == 'lspconfig_extended' then
    return
  end

  internal.setup_status = 'lspconfig_extended'

  return Server.extend_lspconfig(opts)
end

M.defaults = {}

M.defaults.diagnostics = function(opts)
  local config = Server.diagnostics_config()

  if type(opts) == 'table' then
    return vim.tbl_deep_extend('force', config, opts)
  end

  return config
end

M.defaults.cmp_mappings = function(opts)
  local mappings = require('lsp-zero.nvim-cmp-setup').default_mappings()

  if type(opts) == 'table' then
    return vim.tbl_deep_extend('force', mappings, opts)
  end

  return mappings
end

M.defaults.cmp_sources = function()
  return require('lsp-zero.nvim-cmp-setup').sources()
end

M.defaults.cmp_config = function(opts)
  local config = require('lsp-zero.nvim-cmp-setup').cmp_config()

  if type(opts) == 'table' then
    return vim.tbl_deep_extend('force', config, opts)
  end

  return config
end

M.defaults.nvim_workspace = function()
  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')

  return {
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
          library = {
            -- Make the server aware of Neovim runtime files
            vim.fn.expand('$VIMRUNTIME/lua'),
            vim.fn.stdpath('config') .. '/lua'
          }
        }
      }
    }
  }
end

M.suggest_server = function()
  local settings = require('lsp-zero.settings')
  local use_global = settings.call_servers == 'global'
  local ft = vim.bo.filetype

  if use_global or vim.bo.buftype == 'prompt' or ft == '' or ft == nil then
    return
  end

  local state = require('lsp-zero.state')
  local current_state = state.get()

  if not current_state.ok then return end

  local visited = current_state.filetypes[ft]
  if visited then return end

  state.save_filetype(ft)

  local util = require('lsp-zero.utils')
  local installer = require('lsp-zero.installer')

  installer.choose()

  local is_there = util.should_suggest_server(
    ft,
    installer.fn.get_servers()
  )

  if is_there then return end

  local server_available = util.should_suggest_server(
    ft,
    util.available_servers()
  )

  if not server_available then return end

  local answer = vim.fn.confirm(
    'Would you like to install a language server for this filetype?',
    '&Yes\n&No'
  )

  if answer == 1 then
    vim.cmd('LspInstall')
  end
end

internal.fn.setup_nvim_cmp = function(settings)
  internal.cmp_opts = settings
end

internal.fn.configure = function(name, settings)
  internal.servers[name] = settings
end

internal.fn.setup_servers = function(list)
  if list.opts == nil and list.root_dir == true then
    list.opts = {root_dir = function() return vim.fn.getcwd() end}
  end

  for _, server in ipairs(list) do
    internal.servers[server] = list.opts
  end
end

return M

