local preset = {}

preset.defaults = function()
  return {
    'defaults',
    set_lsp_keymaps = {
      preserve_mappings = false,
      omit = {},
    },
    manage_nvim_cmp = false,
    call_servers = 'local',
    configure_diagnostics = false,
    setup_servers_on_start = false,
    state_file = vim.fn.stdpath('data') .. '/lsp-zero.info.json',
  }
end

preset.minimal = function()
  local opts = preset.defaults()

  opts[1] = 'minimal'
  opts.configure_diagnostics = true
  opts.call_servers = 'local'
  opts.setup_servers_on_start = true
  opts.set_lsp_keymaps = false
  opts.manage_nvim_cmp = {
    set_sources = 'lsp',
    set_basic_mappings = true,
    set_extra_mappings = false,
    use_luasnip = true,
    set_format = true,
    documentation_window = false,
  }

  return opts
end

preset.recommended = function()
  local opts = preset.defaults()

  opts[1] = 'recommended'
  opts.configure_diagnostics = true
  opts.setup_servers_on_start = true
  opts.call_servers = 'local'
  opts.set_lsp_keymaps = {
    preserve_mappings = false,
    omit = {}
  }
  opts.manage_nvim_cmp = {
    set_sources = 'recommended',
    set_basic_mappings = true,
    set_extra_mappings = true,
    use_luasnip = true,
    set_format = true,
    documentation_window = true,
  }

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

  return opts
end

preset['manual-setup'] = function()
  local opts = preset.recommended()

  opts[1] = 'manual-setup'
  opts.setup_servers_on_start = false

  return opts
end

preset['per-project'] = function()
  local opts = preset.recommended()

  local msg = "[lsp-zero] The 'per-project' has been removed.\n"
    .. "To setup default config for an LSP server use the .store_config() function"

  vim.notify(msg, vim.log.levels.WARN)

  return opts
end

preset['system-lsp'] = function()
  local opts = preset.recommended()

  opts[1] = 'system-lsp'
  opts.setup_servers_on_start = false
  opts.call_servers = 'global'

  return opts
end

return preset

