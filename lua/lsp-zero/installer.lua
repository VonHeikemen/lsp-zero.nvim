local M = {}
M.enabled = false

function M.setup()
  local mason = M.load_module('mason')
  local lspconfig = M.load_module('mason-lspconfig')

  if mason == 'failed' or lspconfig == 'failed' then
    M.enabled = false
    return false
  end

  M.enabled = true

  return true
end

function M.load_module(name)
  if package.loaded[name] ~= nil then
    return 'loaded'
  end

  local ok, mod = pcall(require, name)

  if not ok then
    return 'failed'
  end

  mod.setup()

  return 'loaded'
end

return M

