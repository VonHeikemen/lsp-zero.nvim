local preset = {}

preset.minimal = function()
  return {
    float_border = 'rounded',
    configure_diagnostics = true,
    call_servers = 'local',
    setup_servers_on_start = true,
    set_lsp_keymaps = false,
    manage_nvim_cmp = {
      set_sources = 'lsp',
      set_basic_mappings = true,
      set_extra_mappings = false,
      use_luasnip = true,
      set_format = true,
      documentation_window = true,
    },
  }
end

preset.recommended = function()
  return {
    float_border = 'rounded',
    configure_diagnostics = true,
    setup_servers_on_start = true,
    call_servers = 'local',
    set_lsp_keymaps = {
      preserve_mappings = false,
      omit = {}
    },
    manage_nvim_cmp = {
      set_sources = 'recommended',
      set_basic_mappings = true,
      set_extra_mappings = true,
      use_luasnip = true,
      set_format = true,
      documentation_window = true,
    },
  }
end

preset['lsp-compe'] = function()
  local opts = preset.recommended()

  opts.manage_nvim_cmp = false

  return opts
end

preset['lsp-only'] = function()
  local opts = preset.recommended()

  opts.manage_nvim_cmp = false

  return opts
end

preset['manual-setup'] = function()
  local opts = preset.recommended()

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

  opts.setup_servers_on_start = false
  opts.call_servers = 'global'

  return opts
end

return preset

