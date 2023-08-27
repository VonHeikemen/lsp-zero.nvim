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

    local show_msg = function() vim.notify(msg, vim.log.levels.WARN) end
    local event = 'LspAttach'

    if vim.bo.filetype == '' then
      event = 'FileType'
    end

    vim.api.nvim_create_autocmd(event, {
      once = true,
      desc = 'lsp-zero warning',
      callback = show_msg
    })
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

vim.api.nvim_create_autocmd('User', {
  once = true,
  pattern = 'LspZeroExtendPlugin',
  desc = 'lsp-zero extend lspconfig and nvim-cmp',
  callback = function()
    setup_lspconfig()
    setup_cmp()
  end,
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

