local M = {}
local s = {mason = {}, lsp = {}}
local valid = {mason = true,  ['lsp-installer'] = true}
local id = function(arg) return arg end

M.choose = function()
  local global_config = require('lsp-zero.settings')
  local method = global_config.call_servers

  if method == 'local' and pcall(require, 'mason') then
    method = 'mason'
    M.fn = s.mason

    if pcall(require, 'mason-lspconfig') == false then
      local msg = "[lsp-zero] Couldn't find module 'mason-lspconfig'"
      vim.notify(msg, vim.log.levels.ERROR)
      method = ''
    end
  end

  local lsp_installer = pcall(require, 'nvim-lsp-installer')
  if method == 'local' and lsp_installer then
    method = 'lsp-installer'
    M.fn = s.lsp
  end

  if method == 'mason' and lsp_installer then
    if pcall(require, 'nvim-lsp-installer') then
      local msg = "[lsp-zero] Module 'nvim-lsp-installer' was found.\nPlease remove it and restart neovim."
      vim.notify(msg, vim.log.levels.ERROR)
      method = ''
    end
  end

  if valid[method] == nil then
    M.fn = s.id
  end

  global_config.call_servers = method

  M.choose = id
end

s.lsp.setup = function()
  require('nvim-lsp-installer').setup({})
  M.fn.setup = id
  s.lsp.setup = id
end

s.lsp.use = function(setup_server)
  local lsp_install = require('nvim-lsp-installer')
  s.lsp.setup()

  for _, server in pairs(lsp_install.get_installed_servers()) do
    setup_server(server.name)
  end
end

s.lsp.install = function(list)
  local global_config = require('lsp-zero.settings')
  local get_server = require('nvim-lsp-installer.servers').get_server
  local installed = false

  s.lsp.setup()

  for _, name in ipairs(list) do
    local ok, server = get_server(name)
    if ok and not server:is_installed() then
      installed = true
      vim.notify('[lsp-zero] Installing ' .. name, vim.log.levels.INFO)
      server:install()

      if global_config.suggest_lsp_servers then
        require('lsp-zero.state').check_server(server.name)
      end
    end
  end

  if installed then
    local msg = '[lsp-zero] Execute the command :LspInstallInfo to track the process of installation.\n'
      .. 'And, restart neovim when finished to initialize language servers properly.'

    vim.notify(msg, vim.log.levels.INFO)
  end
end

s.lsp.get_servers = function()
  local servers = require('nvim-lsp-installer').get_installed_servers()
  return vim.tbl_map(function(s) return s.name end, servers)
end

s.mason.setup = function()
  local mason_file = vim.api.nvim_get_runtime_file('lua/mason/api/command.lua', 1)
  if #mason_file == 1 and package.loaded['mason.api.command'] == nil then
    -- Setup mason if user didn't
    require('mason').setup()
  elseif #mason_file == 0 then
    -- If we are here `mason.api.command` no longer exists 
    -- Setup mason and hope for the best
    require('mason').setup()
  end

  -- Same deal here but with `mason-lspconfig`
  local lsp_file = vim.api.nvim_get_runtime_file('lua/mason-lspconfig/api/command.lua', 1)
  if #lsp_file == 1 and package.loaded['mason-lspconfig.api.command'] == nil then
    require('mason-lspconfig').setup()
  elseif #lsp_file == 0 then
    require('mason-lspconfig').setup()
  end

  M.fn.setup = id
  s.mason.setup = id
end

s.mason.use = function(setup_server)
  s.mason.setup()

  -- Setup installed servers directly
  -- hopefully this will avoid weird behaviors 
  -- which I think are caused by `.setup_handlers`
  local servers = s.mason.get_servers()
  for _, name in ipairs(servers) do
    setup_server(name)
  end

  -- This will duplicate the call to `setup_server`
  -- for now this is OK. `setup_server` will not configure a server twice
  require('mason-lspconfig').setup_handlers({setup_server})
end

s.mason.install = function(list)
  local global_config = require('lsp-zero.settings')

  s.mason.setup()

  if global_config.suggest_lsp_servers then
    for _, name in ipairs(list) do
      require('lsp-zero.state').check_server(name)
    end
  end

  require('mason-lspconfig.settings').set({ensure_installed = list})
  require('mason-lspconfig.ensure_installed')()
end

s.mason.get_servers = function()
  local mason_lsp = require('mason-lspconfig')
  return mason_lsp.get_installed_servers()
end

s.id = {
  setup = id,
  use = id,
  install = id,
  get_servers = function() return {} end
}

M.fn = s.id

return M

