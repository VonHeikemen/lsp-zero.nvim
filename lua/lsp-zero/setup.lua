local M = {}
local s = {}

function M.apply(args)
  require('lsp-zero.snippets')
  s.setup_ui({border = 'rounded'})

  local Server = require('lsp-zero.server')

  local user_settings = s.settings(args.preset, args.preset_overrides)

  if user_settings.manage_nvim_cmp then
    require('lsp-zero.cmp-setup').apply(args.cmp_opts)
  end

  if user_settings.configure_diagnostics then
    vim.diagnostic.config(Server.diagnostics_config())
  end

  local use_local = user_settings.call_servers == 'local'

  if use_local then
    use_local = require('lsp-zero.installer').setup()
  end

  Server.user_settings({
    enable_keymaps = user_settings.set_lsp_keymaps
  })

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
end

function s.settings(name, opts)
  local preset = require('lsp-zero.preset')
  local result = {}

  if name == 'none' then
    name = 'default'
  end

  if preset[name] then
    result = preset[name]()
  end

  result = vim.tbl_deep_extend('force', {}, result, opts)

  return result
end

return M

