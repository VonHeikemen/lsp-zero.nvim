local M = {}

local preset = require('lsp-zero.presets')
local state = require('lsp-zero.state')
local util = require('lsp-zero.utils')
local lsp_install = require('nvim-lsp-installer')

local safe_call = function(fn, ...)
  local ok, res = pcall(fn, ...)
  if not ok then
    vim.notify(res, vim.log.levels.ERROR)
    return
  end

  return res
end

M.setup = function()
  local settings = require('lsp-zero.settings')

  if settings.manage_nvim_cmp then
    M.setup_nvim_cmp({})
  end

  if settings.setup_servers_on_start then
    lsp_install.on_server_ready(function(server)
      M.configure(server.name, {autostart = true})
    end)
  end

  if settings.suggest_lsp_servers then
    safe_call(state.sync)
    lsp_install.on_server_ready(function(server)
        safe_call(state.check_server, server)
    end)
  end

  if settings.suggest_lsp_servers then
    local autocmd = [[
      augroup lsp_cmds
        autocmd!
        autocmd FileType * lua vim.defer_fn(require('lsp-zero').suggest_server, 5)
      augroup END
    ]]

    vim.cmd(autocmd)
  end
end

M.preset = function(name)
  M.set_preferences(M.create_preset(name))
end

M.set_preferences = function(opts)
  local settings = require('lsp-zero.settings')
  if not opts[1] then return end

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
  require('lsp-zero.server').setup_servers(list)
end

M.configure = function(server_name, opts)
  require('lsp-zero.server').setup(server_name, opts)
end

M.ensure_installed = function(list)
  require('lsp-zero.server').ensure_installed(list)
end

M.setup_nvim_cmp = function(opts)
  require('lsp-zero.nvim-cmp-setup').call_setup(opts)
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

  local server_available = util.should_suggest_server(ft)
  if not server_available then return end

  local answer = vim.fn.confirm(
    'Would you like to install a language server for this filetype?',
    '&Yes\n&No'
  )

  if answer == 1 then
    vim.cmd('LspInstall')
  end
end

return M

