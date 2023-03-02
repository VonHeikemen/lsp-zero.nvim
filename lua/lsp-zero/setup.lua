local M = {}
local s = {}

function M.apply(args)
  local Server = require('lsp-zero.server')

  local user_settings = require('lsp-zero.settings').get()
  local cmp_txt = vim.api.nvim_get_runtime_file('doc/cmp.txt', 1) or {}

  M.state = user_settings

  if user_settings.manage_nvim_cmp and #cmp_txt > 0 then
    require('lsp-zero.cmp-setup').apply(
      args.cmp_opts,
      user_settings.manage_nvim_cmp
    )
  end

  s.setup_ui({border = user_settings.float_border})

  if user_settings.configure_diagnostics then
    vim.diagnostic.config(Server.diagnostics_config())
  end

  local use_local = user_settings.call_servers == 'local'

  if use_local then
    use_local = require('lsp-zero.installer').setup()
  end

  Server.enable_keymaps = user_settings.set_lsp_keymaps

  if Server.enable_keymaps == true then
    Server.enable_keymaps = {}
  end

  if use_local == false or user_settings.setup_servers_on_start == false then
    Server.setup_servers(args.servers, {ignore = args.skip_servers})
    return
  end

  if args.install and #args.install > 0 then
    Server.ensure_installed(args.install)
  end

  Server.setup_installed(args.servers, {ignore = args.skip_servers})
end

function s.setup_ui(opts)
  if vim.o.signcolumn == 'auto' then
    vim.opt.signcolumn = 'yes'
  end

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    {border = opts.border}
  )

  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {border = opts.border}
  )

  vim.diagnostic.config({
    float = {border = opts.border}
  })
end

return M

