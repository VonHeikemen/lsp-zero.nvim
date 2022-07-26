local M = {}
local uv = vim.loop

M.get_supported_filetypes = function(name)
  local exceptions = {
    awk_ls = {'awk'},
    vdmj = {'vdmsl', 'vdmpp', 'vdmrt'},
  }

  if exceptions[name] then
    return exceptions[name]
  end

  local mod = 'lspconfig.server_configurations.%s'
  local server = require(mod:format(name))

  return server.default_config.filetypes or {}
end

M.should_suggest_server = function(current_filetype, servers)
  for _, s in pairs(servers) do
    local fts = M.get_supported_filetypes(s)

    for _, ft in pairs(fts) do
      if current_filetype == ft then
        return true
      end
    end
  end

  return false
end

M.available_servers = function()
  local lsp_paths = vim.api.nvim_get_runtime_file(
    'lua/lspconfig/server_configurations/*',
    1
  )

  if #lsp_paths == 0 then
    return {}
  end

  return vim.tbl_map(function(p) return vim.fn.fnamemodify(p, ':t:r') end, lsp_paths)
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

