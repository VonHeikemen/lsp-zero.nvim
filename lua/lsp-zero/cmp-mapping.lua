local M = {}

local function get_cmp()
  local ok_cmp, cmp = pcall(require, 'cmp')
  return ok_cmp and cmp or nil
end

local function get_luasnip()
  local ok_luasnip, luasnip = pcall(require, 'luasnip')
  return ok_luasnip and luasnip or nil
end

function M.tab_complete(select_opts)
  local cmp = get_cmp()
  return cmp.mapping(function(fallback)
    local col = vim.fn.col('.') - 1

    if cmp.visible() then
      cmp.select_next_item(select_opts)
    elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
      fallback()
    else
      cmp.complete()
    end
  end, {'i', 's'})
end

function M.select_prev_or_fallback(select_opts)
  local cmp = get_cmp()
  return cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item(select_opts)
    else
      fallback()
    end
  end, {'i', 's'})
end

function M.toggle_completion()
  local cmp = get_cmp()
  return cmp.mapping(function()
    if cmp.visible() then
      cmp.abort()
    else
      cmp.complete()
    end
  end)
end

function M.luasnip_jump_forward()
  local cmp = get_cmp()
  local luasnip = get_luasnip()

  return cmp.mapping(function(fallback)
    if luasnip.jumpable(1) then
      luasnip.jump(1)
    else
      fallback()
    end
  end, {'i', 's'})
end

function M.luasnip_jump_backward()
  local cmp = get_cmp()
  local luasnip = get_luasnip()

  return cmp.mapping(function(fallback)
    if luasnip.jumpable(1) then
      luasnip.jump(1)
    else
      fallback()
    end
  end, {'i', 's'})
end

function M.luasnip_supertab(select_opts)
  local cmp = get_cmp()
  local luasnip = get_luasnip()

  return cmp.mapping(function(fallback)
    local col = vim.fn.col('.') - 1

    if cmp.visible() then
      cmp.select_next_item(select_opts)
    elseif luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
      cmp.complete()
    else
      fallback()
    end
  end, {'i', 's'})
end

function M.luasnip_shift_supertab(select_opts)
  local cmp = get_cmp()
  local luasnip = get_luasnip()

  return cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item(select_opts)
    elseif luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  end, {'i', 's'})
end

return M

