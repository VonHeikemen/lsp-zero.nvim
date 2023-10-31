local M = {}
local state = {filetypes = {}, tools = {}, tool_lang = {}, current = {}}

local function extend_config(defaults, tools)
  local languages = {}
  state.tools = {}

  local init = defaults.init_options

  for _, tool in ipairs(tools) do
    ---
    -- Set initialization config
    ---
    if tool.formatCommand then
      init.documentFormatting = true
    end

    if tool.formatCanRange then
      init.documentRangeFormatting = true
    end

    if tool.hoverCommand then
      init.hover = true
    end

    if tool.symbolCommand then
      init.documentSymbol = true
    end

    if tool.completionCommand then
      init.completion = true
    end

    local config = tool.config
    local name = tool.name

    if name == nil then
      name = tostring(#state.tools + 1)
    end

    if config == nil then
      local t = vim.deepcopy(tool)
      t.name = nil
      t.config = nil
      t.languages = nil
      config = t
    end

    local tool_lang = tool.languages or {}
    state.tools[name] = config
    state.tool_lang[name] = tool_lang

    ---
    -- Assign languages
    ---
    for _, l in ipairs(tool_lang) do
      if languages[l] == nil then
        languages[l] = {}
      end

      table.insert(languages[l], config)
    end
  end

  defaults.filetypes = vim.tbl_keys(languages)
  defaults.settings.languages = languages
  state.filetypes = defaults.filetypes
end

function M.tools(opts)
  if type(opts) ~= 'table' then
    return
  end

  local config = {
    cmd = {'efm-langserver'},
    name = 'efm',
    init_options = {
      documentFormatting = false,
      documentRangeFormatting = false,
      hover = false,
      documentSymbol = false,
      completion = false
    },
    settings = {
      languages = {},
    },
  }

  extend_config(config, opts)

  if type(opts.server_config) == 'table' then
    config = vim.tbl_deep_extend('force', config, opts.server_config)
  end

  state.current = config

  return config
end

function M.langs(opts)
  if opts == nil then
    return state.filetypes
  end

  local include = opts.with
  local exclude = opts.exclude or {}

  if include == nil then
    if #exclude == 0 then
      return state.filetypes
    end

    return vim.tbl_filter(function(l)
      return not vim.tbl_contains(exclude, l)
    end, state.filetypes)
  end

  local res = {}
  for name, config in pairs(state.tools) do
    local prop = config[include]
    if prop ~= nil and prop then
      for _, l in pairs(state.tool_lang[name]) do
        if not vim.tbl_contains(exclude, l) then
          res[l] = true
        end
      end
    end
  end

  return vim.tbl_keys(res)
end

function M.get_tool_config(arg, opts)
  local t = state.tools[arg]
  if t == nil then
    return
  end

  opts = opts or {}

  local res = vim.deepcopy(t)
  if opts.include_lang then
    res.languages = state.tool_lang[arg]
  end

  return res
end

function M.get_server_config()
  return state.current
end

return M

