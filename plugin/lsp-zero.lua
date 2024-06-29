if vim.g.loaded_lsp_zero == 1 then
  return
end

vim.g.loaded_lsp_zero = 1

---
-- Commands
---
local function setup_server(input)
  local opts = {}
  if input.bang then
    opts.root_dir = function()
      return vim.fn.get_cwd()
    end
  end

  require('lsp-zero').use(input.fargs, opts)
end

vim.api.nvim_create_user_command(
  'LspZeroSetupServers',
  setup_server,
  {
    bang = true,
    nargs = '*',
  }
)

vim.api.nvim_create_user_command(
  'LspZeroWorkspaceAdd',
  'lua vim.lsp.buf.add_workspace_folder()',
  {}
)

vim.api.nvim_create_user_command(
  'LspZeroWorkspaceList',
  'lua vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))',
  {}
)

local function inspect_config_source(input)
  local server = input.args
  local mod = 'lua/lspconfig/server_configurations/%s.lua'
  local path = vim.api.nvim_get_runtime_file(mod:format(server), false)

  if path[1] == nil then
    local msg = "[lsp-zero] Could not find configuration for '%s'"
    vim.notify(msg:format(server), vim.log.levels.WARN)
    return
  end

  vim.cmd.sview({
    args = {path[1]},
    mods = {vertical = true},
  })
end

local function config_source_complete(user_input)
  local mod = 'lua/lspconfig/server_configurations'
  local path = vim.api.nvim_get_runtime_file(mod, false)[1]
  local pattern = '%s/*.lua'

  local list = vim.split(vim.fn.glob(pattern:format(path)), '\n')
  local res = {}

  for _, i in ipairs(list) do
    local name = vim.fn.fnamemodify(i, ':t:r')
    if vim.startswith(name, user_input) then
      res[#res + 1] = name
    end
  end

  return res
end

vim.api.nvim_create_user_command(
  'LspZeroViewConfigSource',
  inspect_config_source,
  {
    nargs = 1,
    complete = config_source_complete,
  }
)


---
-- Autocommands
---
local lsp_cmds = vim.api.nvim_create_augroup('lsp_zero_attach', {clear = true})

local function lsp_attach(event)
  local Server = require('lsp-zero.server')
  local bufnr = event.buf

  Server.set_buf_commands(bufnr)

  if Server.common_attach then
    local id = vim.tbl_get(event, 'data', 'client_id')
    local client = {}

    if id then
      client = vim.lsp.get_client_by_id(id) or {}
    end

    Server.common_attach(client, bufnr)
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_cmds,
  desc = 'lsp-zero on_attach',
  callback = lsp_attach
})

