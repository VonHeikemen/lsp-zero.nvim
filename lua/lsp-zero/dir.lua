local M = {}
local uv = vim.uv or vim.loop

local function dir_parents(start)
  return function(_, dir)
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then
      return
    end

    return parent
  end,
    nil,
    start
end

local function scan_dir(list, dir)
  local match = 0
  local str = '%s/%s'

  for _, name in ipairs(list) do
    local file = str:format(dir, name)
    if uv.fs_stat(file) then
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
    dir = ok and vim.fn.fnamemodify(name, ':h') or dir
  end

  if dir == nil then
    dir = vim.fn.getcwd()
  end

  if scan_dir(list, dir) then
    return dir
  end

  local stop = list.stop or vim.env.HOME

  for path in dir_parents(dir) do
    if path == stop then
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
    dir = ok and vim.fn.fnamemodify(name, ':h') or dir
  end

  if dir == nil then
    dir = vim.fn.getcwd()
  end

  local dirs = {dir}
  local stop = list.stop or vim.env.HOME
  for path in dir_parents(dir) do
    if path == stop then
      break
    end

    table.insert(dirs, path)
  end

  local str = '%s/%s'
  for _, path in ipairs(dirs) do
    for _, file in ipairs(list) do
      if uv.fs_stat(str:format(path, file)) then
        return path
      end
    end
  end
end

return M

