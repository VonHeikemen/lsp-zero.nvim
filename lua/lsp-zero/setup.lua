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
      client = vim.lsp.get_client_by_id(id)
    end

    Server.common_attach(client, bufnr)
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_cmds,
  desc = 'lsp-zero on_attach',
  callback = lsp_attach
})


---
-- UI settings
---
local ui_settings = {}

local border_style = vim.g.lsp_zero_ui_float_border
if border_style == nil then
  ui_settings.border = 'rounded'
elseif type(border_style) == 'string' then
  ui_settings.border = border_style
end

local signs = vim.g.lsp_zero_ui_signcolumn
if (signs == nil and vim.o.signcolumn == 'auto') or signs == 1 then
  ui_settings.set_signcolumn = true
elseif signs == 0 then
  ui_settings.set_signcolumn = false
end

require('lsp-zero.ui').setup(ui_settings)

vim.g.loaded_lsp_zero = 1

