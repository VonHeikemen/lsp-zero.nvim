local preset = {}

preset.defaults = function()
  return {
    'defaults',
    set_lsp_keymaps = false,
    configure_diagnostics = false,
    call_servers = 'global',
    setup_servers_on_start = false,
    manage_nvim_cmp = false,
    state_file = vim.fn.stdpath('data') .. '/lsp-zero.info.json',
  }
end

preset.minimal = function()
  local opts = preset.defaults()

  opts[1] = 'minimal'
  opts.configure_diagnostics = true
  opts.setup_servers_on_start = true
  opts.call_servers = 'local'

  return opts
end

preset.recommended = function()
  local opts = preset.defaults()

  opts[1] = 'recommended'
  opts.set_lsp_keymaps = true
  opts.configure_diagnostics = true
  opts.setup_servers_on_start = true
  opts.manage_nvim_cmp = true
  opts.call_servers = 'local'

  return opts
end

preset['lsp-compe'] = function()
  local opts = preset.recommended()

  opts[1] = 'lsp-compe'
  opts.manage_nvim_cmp = false

  return opts
end

preset['lsp-only'] = function()
  local opts = preset.recommended()

  opts[1] = 'lsp-only'
  opts.manage_nvim_cmp = false
  opts.cmp_capabilities = false

  return opts
end

preset['manual-setup'] = function()
  local opts = preset.recommended()

  opts[1] = 'manual-setup'
  opts.suggest_lsp_servers = false
  opts.setup_servers_on_start = false

  return opts
end

preset['per-project'] = function()
  local opts = preset.recommended()

  opts[1] = 'per-project'
  opts.suggest_lsp_servers = false
  opts.setup_servers_on_start = 'per-project'

  return opts
end

preset['system-lsp'] = function()
  local opts = preset.recommended()

  opts[1] = 'system-lsp'
  opts.suggest_lsp_servers = false
  opts.setup_servers_on_start = false
  opts.call_servers = 'global'

  return opts
end

return preset

