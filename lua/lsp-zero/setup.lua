if vim.g.loaded_lsp_zero == 1 then
  local M = {}
  M.extend_plugins = function() return false end
  return M
end

vim.g.loaded_lsp_zero = 1
local M = {}
M.done = false

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

local function setup_lspconfig()
  local extend = vim.g.lsp_zero_extend_lspconfig

  if extend == false or extend == 0 then
    return
  end

  local doc_txt = vim.api.nvim_get_runtime_file('doc/lspconfig.txt', 0) or {}
  if #doc_txt == 0 then
    return
  end

  local configs = require('lspconfig.configs')
  if #vim.tbl_keys(configs) > 0 then
    local msg = '[lsp-zero] Some language servers have been configured before\n'
     .. 'lsp-zero could finish its initial setup. Some features may fail.'
     .. '\n\nDetails on how to solve this problem are in the help page.\n'
     .. 'Execute the following command\n\n:help lsp-zero-guide:fix-extend-lspconfig'

    vim.notify(msg, vim.log.levels.WARN)
    return
  end

  local Server = require('lsp-zero.server')
  Server.has_lspconfig = true
  Server.extend_lspconfig()
end

local function setup_cmp()
  local extend_cmp = vim.g.lsp_zero_extend_cmp
  if extend_cmp == 0 or extend_cmp == false then
    return
  end

  require('lsp-zero.cmp').apply_base()
end

function M.extend_plugins()
  if M.done then
    return false
  end

  M.done = true
  setup_lspconfig()
  setup_cmp()

  return true
end

---
-- UI settings
---
local border_style = vim.g.lsp_zero_ui_float_border
if border_style == nil then
  border_style = 'rounded'
end

if type(border_style) == 'string' then
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    {border = border_style}
  )

  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {border = border_style}
  )
  
  vim.diagnostic.config({
    float = {border = border_style}
  })
end

local signs = vim.g.lsp_zero_ui_signcolumn
if (
  (signs == nil and vim.o.signcolumn == 'auto')
  or signs == 1
  or signs == true
) then
  vim.o.signcolumn = 'yes'
end

return M

