local M = {}

local function get_cmp()
  local ok_cmp, cmp = pcall(require, 'cmp')
  return ok_cmp and cmp or {}
end

local function vim_snippet_support()
  if M._vim_snippet == nil then
    M._vim_snippet = type(vim.tbl_get(vim, 'snippet', 'expand')) == 'function'
  end

  return M._vim_snippet
end

local function get_luasnip()
  local ok_luasnip, luasnip = pcall(require, 'luasnip')
  return ok_luasnip and luasnip or {}
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

function M.toggle_completion(opts)
  opts = opts or {}
  local cmp = get_cmp()

  return cmp.mapping(function()
    if cmp.visible() then
      cmp.abort()
    else
      cmp.complete()
    end
  end, opts.modes)
end

---
-- vim.snippet mappings
---

function M.vim_snippet_jump_forward()
  local cmp = get_cmp()

  if not vim_snippet_support() then
    local msg = '[lsp-zero] vim.snippet module is not available.' 
      .. '\ncmp action "vim_snippet_jump_forward" will not work.'
      .. '\nMake sure you are using Neovim v0.10 or greater.'
    vim.notify(msg, vim.log.levels.WARN)
    return vim.NIL
  end

  return cmp.mapping(function(fallback)
    if vim.snippet.jumpable(1) then
      vim.snippet.jump(1)
    else
      fallback()
    end
  end, {'i', 's'})
end

function M.vim_snippet_jump_backward()
  local cmp = get_cmp()

  if not vim_snippet_support then
    return vim.NIL
  end

  return cmp.mapping(function(fallback)
    if vim.snippet.jumpable(-1) then
      vim.snippet.jump(-1)
    else
      fallback()
    end
  end, {'i', 's'})
end

function M.vim_snippet_next(select_opts)
  local cmp = get_cmp()

  if not vim_snippet_support() then
    local msg = '[lsp-zero] vim.snippet module is not available.' 
      .. '\ncmp action "vim_snippet_next" will not work.'
      .. '\nMake sure you are using Neovim v0.10 or greater.'
    vim.notify(msg, vim.log.levels.WARN)
    return vim.NIL
  end

  return cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item(select_opts)
    elseif vim.snippet.jumpable(1) then
      vim.snippet.jump(1)
    else
      fallback()
    end
  end, {'i', 's'})
end

function M.vim_snippet_prev(select_opts)
  local cmp = get_cmp()

  if not vim_snippet_support then
    return vim.NIL
  end

  return cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item(select_opts)
    elseif vim.snippet.jumpable(-1) then
      vim.snippet.jump(-1)
    else
      fallback()
    end
  end, {'i', 's'})
end

function M.vim_snippet_tab_next(select_opts)
  local cmp = get_cmp()

  if not vim_snippet_support() then
    local msg = '[lsp-zero] vim.snippet module is not available.' 
      .. '\ncmp action "vim_snippet_tab_next" will not work.'
      .. '\nMake sure you are using Neovim v0.10 or greater.'
    vim.notify(msg, vim.log.levels.WARN)
    return vim.NIL
  end

  return cmp.mapping(function(fallback)
    local col = vim.fn.col('.') - 1

    if cmp.visible() then
      cmp.select_next_item(select_opts)
    elseif vim.snippet.jumpable(1) then
      vim.snippet.jump(1)
    elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
      fallback()
    else
      cmp.complete()
    end
  end, {'i', 's'})
end

---
-- luasnip mappings
---

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
    if luasnip.jumpable(-1) then
      luasnip.jump(-1)
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
      fallback()
    else
      cmp.complete()
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

function M.luasnip_next_or_expand(select_opts)
  local cmp = get_cmp()
  local luasnip = get_luasnip()

  return cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item(select_opts)
    elseif luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    else
      fallback()
    end
  end, {'i', 's'})
end

function M.luasnip_next(select_opts)
  local cmp = get_cmp()
  local luasnip = get_luasnip()

  return cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item(select_opts)
    elseif luasnip.jumpable(1) then
      luasnip.jump(1)
    else
      fallback()
    end
  end, {'i', 's'})
end

return M

