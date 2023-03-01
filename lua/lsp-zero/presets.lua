local preset = {}
local icons = {}

icons.sign = function()
  return {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = ''
  }
end

preset.defaults = function()
  return {
    'defaults',
    set_lsp_keymaps = true,
    configure_diagnostics = true,
    call_servers = 'local',
    suggest_lsp_servers = false,
    setup_servers_on_start = false,
    cmp_capabilities = false,
    manage_nvim_cmp = false,
    manage_luasnip = false,
    state_file = vim.fn.stdpath('data') .. '/lsp-zero.info.json',
    sign_icons = icons.sign(),
  }
end

preset.minimal = function()
  local opts = preset.defaults()

  opts[1] = 'minimal'
  opts.set_lsp_keymaps = false
  opts.configure_diagnostics = true
  opts.call_servers = 'local'
  opts.suggest_lsp_servers = false
  opts.setup_servers_on_start = true
  opts.cmp_capabilities = true
  opts.manage_nvim_cmp = false
  opts.manage_luasnip = true
  opts.sign_icons = {}

  return opts
end

preset.recommended = function()
  local opts = preset.defaults()

  opts[1] = 'recommended'
  opts.suggest_lsp_servers = true
  opts.setup_servers_on_start = true
  opts.cmp_capabilities = true
  opts.manage_nvim_cmp = true
  opts.manage_luasnip = true
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

