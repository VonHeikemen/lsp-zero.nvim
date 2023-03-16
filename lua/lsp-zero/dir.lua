local M = {}

local function scan_dir(list, dir)
  local match = 0
  local str = '%s/%s'

  for _, name in ipairs(list) do
    local file = str:format(dir, name)
    if vim.loop.fs_stat(file) then
      match = match + 1
      if match == #list then
        return true
      end
    end
  end

  return false
end

function M.find_all(list)
  local dir = list.path

  if list.buffer then
    local ok, name = pcall(vim.api.nvim_buf_get_name, 0)
    dir = ok and vim.fs.dirname(name) or dir
  end

  if dir == nil then
    dir = vim.fn.getcwd()
  end

  if scan_dir(list, dir) then
    return dir
  end

  local home = vim.env.HOME

  for path in vim.fs.parents(dir) do
    if path == home then
      return
    end

    if scan_dir(list, path) then
      return path
    end
  end
end

function M.find_first(list)
  local dir = list.path

  if list.buffer then
    local ok, name = pcall(vim.api.nvim_buf_get_name, 0)
    dir = ok and vim.fs.dirname(name) or dir
  end

  local result = vim.fs.find(list, {
    path = dir,
    upward = true,
    limit = 1,
    stop = vim.env.HOME,
  })

  local path = result[1]

  if path == nil then
    return
  end

  if vim.fn.isdirectory(path) == 1 then
    return path
  end

  return vim.fs.dirname(path)
end

return M

