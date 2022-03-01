local M = {}
local uv = vim.loop

M.should_suggest_server = function(current_filetype, servers)
  local lsp_install = require('nvim-lsp-installer')
  local get_server = #servers == 0

  if get_server then
    servers = lsp_install.get_available_servers()
  end

  for _, s in pairs(servers) do
    local fts = {}

    if get_server then
      fts = s:get_supported_filetypes()
    else
      local ok, server = lsp_install.get_server(s)
      fts = ok and server:get_supported_filetypes() or {}
    end

    for _, ft in pairs(type(fts) == 'table' and fts or {}) do
      if current_filetype == ft then
        return true
      end
    end
  end

  return false
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

