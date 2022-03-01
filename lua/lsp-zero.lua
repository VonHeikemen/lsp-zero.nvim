local M = {}

local preset = require('lsp-zero.presets')
local state = require('lsp-zero.state')
local util = require('lsp-zero.utils')
local Server = require('lsp-zero.server')

local internal = {
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
  local user_config = args.settings
  local configure = Server.setup
  local suggest = user_config.suggest_lsp_servers
  local handle_setup = user_config.setup_servers_on_start

  if user_config.manage_nvim_cmp then
    require('lsp-zero.nvim-cmp-setup').call_setup(args.cmp_opts)
  end

  local manual_setup = suggest == false and handle_setup == false

  if manual_setup then
    return
  end

  if suggest then
    safe_call(state.sync)

    local autocmd = [[
      augroup lsp_cmds
        autocmd!
        autocmd FileType * lua vim.defer_fn(require('lsp-zero').suggest_server, 5)
      augroup END
    ]]

    vim.cmd(autocmd)
  end

  local setup_server = function(server)
    local server_opts = args.server_opts[server.name] or {}
    server_opts.autostart = true

    configure(server.name, server_opts)
  end

  local update_state = function(server)
    safe_call(state.check_server, server)
  end

  local lsp_install = require('nvim-lsp-installer')

  lsp_install.on_server_ready(function(server)
    if handle_setup then
      setup_server(server)
    end

    if suggest then
      update_state(server)
    end
  end)

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

M.preset = function(name)
  local opts = M.create_preset(name)
  if not opts[1] then
    error('(lsp-zero) Invalid preset')
    return
  end

  M.set_preferences(opts)
end

M.set_preferences = function(opts)
  local settings = require('lsp-zero.settings')
  if type(opts[1]) ~= 'string' then
    opts[1] = 'custom'
  end

  local new_settings = vim.tbl_extend('force', settings, opts)

  for key, _ in pairs(settings) do
    settings[key] = new_settings[key]
  end
end

M.create_preset = function(name)
  if preset[name] == nil then
    local msg = "%s is not a valid preset."
    vim.notify(msg, vim.log.levels.WARN)

    return {false}
  end

  return preset[name]()
end

M.setup_servers = function(list)
  local settings = require('lsp-zero.settings')

  if settings.setup_servers_on_start then
    return internal.fn.setup_servers(list)
  end

  Server.setup_servers(list)
end

M.configure = function(server_name, opts)
  local settings = require('lsp-zero.settings')

  if settings.setup_servers_on_start then
    return internal.fn.configure(server_name, opts)
  end

  Server.setup(server_name, opts)
end

M.on_attach = function(fn)
  if type(fn) == 'function' then
    Server.common_on_attach = fn
  end
end

M.setup_nvim_cmp = function(opts)
  local settings = require('lsp-zero.settings')

  if settings.manage_nvim_cmp then
    return internal.fn.setup_nvim_cmp(opts)
  end

  local msg = 'Settings for nvim_cmp should be handled by the user.'
  vim.notify(msg, vim.log.levels.WARN)
end

M.ensure_installed = function(list)
  local settings = require('lsp-zero.settings')
  if settings.suggest_lsp_servers or settings.setup_servers_on_start then
    internal.install_servers = list
  else
    Server.ensure_installed(list)
  end
end

M.nvim_workspace = function(opts)
  opts = opts or {}
  local settings = require('lsp-zero.settings')
  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')

  local server_opts = {
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

  if opts.library then
    server_opts.settings.Lua.workspace.library = opts.library
  end

  if opts.root_dir then
    server_opts.root_dir = opts.root_dir
  end

  local nvim_source = pcall(require, 'cmp_nvim_lua')

  if settings.cmp_capabilities and nvim_source then
    local cmp_sources = require('lsp-zero.nvim-cmp-setup').sources()
    table.insert(cmp_sources, {name = 'nvim_lua'})
    require('cmp').setup.filetype('lua', {sources = cmp_sources})
  end

  M.configure('sumneko_lua', server_opts)
end

M.suggest_server = function()
  local ft = vim.bo.filetype

  if vim.bo.buftype == 'prompt' or ft == '' or ft == nil then
    return
  end

  local current_state = state.get()
  if not current_state.ok then return end

  local visited = current_state.filetypes[ft]
  if visited then return end

  state.save_filetype(ft)

  local server_available = util.should_suggest_server(ft, {})
  if not server_available then return end

  if #internal.install_servers > 0 then
    local is_there = util.should_suggest_server(ft, internal.install_servers)
    if is_there then return end
  end

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

