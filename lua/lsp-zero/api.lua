---@class lsp_zero.api
local M = {}

local s = {
  lsp_project_configs = {},
}

---An empty function.
M.noop = function() end

---Contains functions that can be use as mappings in nvim-cmp.
function M.cmp_action()
  return require('lsp-zero.cmp-mapping')
end

---Modify completion item text to show a
---label with the name of the source.
---@param opts lsp_zero.config.CmpFormat
---@return cmp.FormattingConfig
function M.cmp_format(opts)
  return require('lsp-zero.cmp').format(opts)
end

---Add the essential configuration options to nvim-cmp,
---so it can work out of the box.
---@param opts? lsp_zero.config.CmpExtend
function M.extend_cmp(opts)
  require('lsp-zero.cmp').extend(opts or {})
end

---Takes care of the integration between lspconfig and nvim-cmp.
---It extends lspconfigs default capabilities options using data
---from cmp_nvim_lsp. And it creates a "hook" so users can provide
---their own default config.
function M.extend_lspconfig()
  local Server = require('lsp-zero.server')

  if Server.setup_done then
    return
  end

  if Server.has_configs() then
    local msg = '[lsp-zero] Some language servers have been configured before\n'
     .. 'you called the function .extend_lspconfig().\n\n'
     .. 'Solution: Go to the place where you use lspconfig for the first time.\n'
     .. 'Call the .extend_lspconfig() function before you setup the language server'

     vim.notify(msg, vim.log.levels.WARN)
     return
   end

  Server.has_lspconfig = true
  Server.extend_lspconfig()
end

---@class lsp_zero.config.SetupServers
---@inlinedoc
---
---List of servers to ignore.
---@field exclude? string[]

---Configure all the language servers in {list} using lspconfig.
---@param list string[] List of servers to configure
---@param opts? lsp_zero.config.SetupServers
function M.setup_servers(list, opts)
  if type(list) ~= 'table' then
    return
  end

  opts = opts or {}

  local Server = require('lsp-zero.server')
  local exclude = opts.exclude or {}

  for _, name in ipairs(list) do
    if not vim.tbl_contains(exclude, name) then
      Server.setup(name, {})
    end
  end
end

---Setup a language server using lspconfig
---@param name string Name of the language server
---@param opts? lsp_zero.config.LspConfig Configuration options for the language server
function M.configure(name, opts)
  opts = opts or {}
  local Server = require('lsp-zero.server')

  M.store_config(name, opts)
  Server.setup(name, opts)
end

---Setup a language server using lspconfig
---@param name string Name of the language server
function M.default_setup(name)
  require('lsp-zero.server').setup(name, {})
end

---Executes the {callback} function every time a
---language server is attached.
---to a buffer.
---@param callback fun(client: lsp_zero.api.Client, bufnr: integer)
function M.on_attach(callback)
  local Server = require('lsp-zero.server')

  if type(callback) == 'function' then
    Server.common_attach = callback
  end
end

---It will share the configuration options with all
---the language servers initialized by lspconfig.
---@param opts lsp_zero.config.LspConfig
function M.set_server_config(opts)
  if type(opts) == 'table' then
    local Server = require('lsp-zero.server')
    Server.default_config = opts
  end
end

---Returns all the parameters lsp-zero uses to initialize a language
---server. This includes default capabilities and settings that were
---added using the .set_server_config() function.
---@param name string Name of the language server
---@param opts? lsp_zero.config.LspConfig Configuration options for the language server
---@return lsp_zero.config.LspConfig
function M.build_options(name, opts)
  local Server = require('lsp-zero.server')

  Server.skip_setup(name)

  local defaults = {
    capabilities = Server.client_capabilities(),
    on_attach = function() end,
  }

  return vim.tbl_deep_extend(
    'force',
    defaults,
    Server.default_config or {},
    opts or {}
  )
end

---Saves the configuration options for a language server, so you can use it
---at a later time in a local config file.
---@param name string Name of the language server
---@param opts lsp_zero.config.LspConfig Configuration options for the language server
function M.store_config(name, opts)
  if type(opts) == 'table' then
    s.lsp_project_configs[name] = opts
  end
end

---For when you want you want to add more settings to a particular language
---server in a particular project. It is meant to be called in project
---local config (but you can still use it in your init.lua).
---@param servers string|string[] Name (or list of names) of the language server
---@param opts lsp_zero.config.LspConfig Configuration options for the language server
function M.use(servers, opts)
  if type(servers) == 'string' then
    servers = {servers}
  end

  local has_filetype = not (vim.bo.filetype == '')
  local buffer = vim.api.nvim_get_current_buf()
  local lspconfig = require('lspconfig')
  local user_opts = opts or {}

  for _, name in ipairs(servers) do
    local config = vim.tbl_deep_extend(
      'force',
      s.lsp_project_configs[name] or {},
      user_opts
    )

    local lsp = lspconfig[name]
    lsp.setup(config)

    if lsp.manager and has_filetype then
      pcall(function() lsp.manager:try_add_wrapper(buffer) end)
    end
  end
end

---Returns settings specific to Neovim for the lua language server, lua_ls.
---@param opts? lsp_zero.config.LspConfig
---@return lsp_zero.config.LspConfig
function M.nvim_lua_ls(opts)
  return require('lsp-zero.server').nvim_workspace(opts)
end

---@class lsp_zero.config.SignIcons
---@field warn? string
---@field error? string
---@field info? string
---@field hint? string

---Defines the sign icons that appear in the gutter.
---@param opts lsp_zero.config.SignIcons
function M.set_sign_icons(opts)
  require('lsp-zero.server').set_sign_icons(opts)
end

---@class lsp_zero.config.DefaultKeymapOpts
---@inlinedoc
---
---Setup buffer local keymaps to the provided buffer.
---Defaults to current buffer.
---@field buffer? integer
---
---List of keymaps that should be ignored.
---@field exclude? string[]
---
---If true lsp-zero will not override an
---existing keymap. Defaults to true.
---@field preserve_mappings? boolean

---Create the keybindings bound to built-in
---functions in Neovim's LSP client.
---@param opts lsp_zero.config.DefaultKeymapOpts
function M.default_keymaps(opts)
  opts = opts or {buffer = 0}
  require('lsp-zero.server').default_keymaps(opts)
end

---Returns Neovim's default capabilities mixed with the
---capabilities provided by the cmp_nvim_lsp plugin.
---@return table<string, any>
function M.get_capabilities()
  local Server = require('lsp-zero.server')
  local client_defaults = Server.client_capabilities()
  local user_defaults = vim.tbl_get(Server, 'default_config', 'capabilities')

  if user_defaults == nil then
    return client_defaults
  end

  return vim.tbl_deep_extend('force', client_defaults, user_defaults)
end

---Uses the CursorHold event to trigger a document highlight request.
---In other words, it will highlight the symbol under the cursor.
---@param client lsp_zero.api.Client Instance of Neovim's lsp client
---@param bufnr? integer Restrict highlight to the given buffer
function M.highlight_symbol(client, bufnr)
  require('lsp-zero.server').highlight_symbol(client, bufnr)
end

---A thin wrapper around vim.lsp.start(). It will execute a user provided
---function to detect the root directory of the project when Neovim
---assigns the file type for a buffer. If the root directory is detected
---the language server will be attached to the file.
---@param opts lsp_zero.api.ClientOpts
function M.new_client(opts)
  if type(opts) ~= 'table' then
    return
  end

  local Server = require('lsp-zero.server')

  local defaults = {
    capabilities = Server.client_capabilities(),
  }

  local config = vim.tbl_deep_extend(
    'force',
    defaults,
    Server.default_config or {},
    opts
  )

  require('lsp-zero.client').setup(config)
end

---Setup autoformat on save. This will to allow you to associate a
---language server with a list of filetypes.
---@param opts lsp_zero.config.FormatOnSave
function M.format_on_save(opts)
  return require('lsp-zero.format').format_on_save(opts)
end

---Configure {key} to format the current buffer.
---@param key string Keymap to bind
---@param opts lsp_zero.config.FormatOnSave
function M.format_mapping(key, opts)
  return require('lsp-zero.format').format_mapping(key, opts)
end

---Format the current buffer using the active language servers.
---@param client? lsp_zero.api.Client Instance of Neovim lsp client
---@param bufnr? integer Restrict formatting to the given buffer
---@param opts? lsp_zero.config.FormatOpts Formatting options
function M.buffer_autoformat(client, bufnr, opts)
  return require('lsp-zero.format').buffer_autoformat(client, bufnr, opts)
end

---Saves the file and then sends a formatting request to {client}. After the
---getting the response from the client it will save the file (again).
---@param client lsp_zero.api.Client Instance of Neovim lsp client
---@param bufnr? integer Restrict formatting to the given buffer
---@param opts? lsp_zero.config.FormatOpts Formatting options
function M.async_autoformat(client, bufnr, opts)
  return require('lsp-zero.format').async_autoformat(client, bufnr, opts)
end

---@class lsp_zero.dir
M.dir = {}

---Checks the parent directories and returns the path to the first folder that
---has all the files in {list}.
---@param list lsp_zero.config.DirList List of files
---@return string | nil
function M.dir.find_all(list)
  return require('lsp-zero.dir').find_all(list)
end

---Checks the parent directories and returns the path to the first folder that
---has a file in {list}. This is useful to detect the root directory.
---@param list lsp_zero.config.DirList List of files
---@return string | nil
function M.dir.find_first(list)
  return require('lsp-zero.dir').find_first(list)
end

---@class lsp_zero.omnifunc
M.omnifunc = {}

---Configure the behavior of Neovim's completion mechanism. If for some reason
---you refuse to install nvim-cmp you can use this function to make the
---built-in completions more user friendly.
---@param opts lsp_zero.config.Omnifunc
function M.omnifunc.setup(opts)
  require('lsp-zero.omnifunc').setup(opts)
end

return M

