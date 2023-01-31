local M = {}
local uv = vim.loop

M.get_supported_filetypes = function(name)
  local fts = require('lsp-zero.lsp-filetypes')
  return fts[name] or {}
end

M.should_suggest_server = function(current_filetype, servers)
  for _, s in pairs(servers) do
    local fts = M.get_supported_filetypes(s)

    if fts[current_filetype] then
      return true
    end
  end

  return false
end

M.build_filetype_map = function()
  local configs = 'lua/lspconfig/server_configurations/*'
  local paths = vim.api.nvim_get_runtime_file(configs, 1)
  local lsp_filetypes = {}

  for _, path in ipairs(paths) do
    local name = vim.fn.fnamemodify(path, ':t:r')
    local server = require(string.format('lspconfig.server_configurations.%s', name))
    local supported = server.default_config.filetypes or {}
    lsp_filetypes[name] = {}

    for _, ft in ipairs(supported) do
      lsp_filetypes[name][ft] = true
    end
  end

  vim.cmd('redir > /tmp/lsp_ft.lua')
  print(vim.inspect(lsp_filetypes))
  vim.cmd('redir END')
end

M.write_file = function(path, contents)
  local fd = assert(uv.fs_open(path, 'w', 438))
  uv.fs_write(fd, contents, -1)
  assert(uv.fs_close(fd))
end

M.read_file = function(path)
  local fd = assert(uv.fs_open(path, 'r', 438))
  local fstat = assert(uv.fs_fstat(fd))
  local contents = assert(uv.fs_read(fd, fstat.size, 0))
  assert(uv.fs_close(fd))
  return contents
end

return M

