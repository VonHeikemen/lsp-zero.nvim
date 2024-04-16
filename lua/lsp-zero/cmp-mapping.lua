---@class lsp_zero.cmp_mappings
local M = {}
local s = {}

local function get_cmp()
  local ok_cmp, cmp = pcall(require, 'cmp')
  return ok_cmp and cmp or {}
end

local function vim_snippet_support()
  if s._vim_snippet == nil then
    s._vim_snippet = type(vim.tbl_get(vim, 'snippet', 'expand')) == 'function'
  end

  return s._vim_snippet
end

local function get_luasnip()
  local ok_luasnip, luasnip = pcall(require, 'luasnip')
  return ok_luasnip and luasnip or {}
end

---Enables completion when the cursor is inside a word. If the completion
---menu is visible it will navigate to the next item in the list. If the
---line is empty it uses the fallback.
---@param select_opts? cmp.SelectOption
---@return cmp.Mapping
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

---If the completion menu is visible navigate to the previous item
---in the list. Else, uses the fallback.
---@param select_opts? cmp.SelectOption
---@return cmp.Mapping
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

---If the completion menu is visible it cancels the
---process. Else, it triggers the completion menu.
---@param opts {modes?: string[]}
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

---Go to the next placeholder in a snippet created by the module vim.snippet.
---@return cmp.Mapping
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

---Go to the previous placeholder in a snippet created by the module
---vim.snippet.
---@return cmp.Mapping
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

---If completion menu is visible it will navigate to the next item in the
---list. If the cursor can jump to a vim snippet placeholder, it moves to it.
---Else, it uses the fallback
---@param select_opts? cmp.SelectOption
---@return cmp.Mapping
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

---If completion menu is visible it will navigate to the previous item in the
---list. If the cursor can jump to a vim snippet placeholder, it moves to it.
---Else, it uses the fallback.
---@param select_opts? cmp.SelectOption
---@return cmp.Mapping
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

---If the completion menu is visible it will navigate to the next item in the
---list. If the cursor can jump to a vim snippet placeholder, it moves to it.
---If the cursor is in the middle of a word it displays the completion menu.
---Else, it uses the fallback.
---@param select_opts? cmp.SelectOption
---@return cmp.Mapping
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

---Go to the next placeholder in a snippet created by luasnip.
---@return cmp.Mapping
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

---Go to the previous placeholder in a snippet created by luasnip.
---@return cmp.Mapping
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

---If the completion menu is visible it will navigate to the next item in
---the list. If cursor is on top of the trigger of a snippet it'll expand
---it. If the cursor can jump to a luasnip placeholder, it moves to it.
---If the cursor is in the middle of a word that doesn't trigger a snippet
---it displays the completion menu. Else, it uses the fallback.
---@param select_opts? cmp.SelectOption
---@return cmp.Mapping
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

---If the completion menu is visible it will navigate to previous item in the
---list. If the cursor can navigate to a previous snippet placeholder, it
---moves to it. Else, it uses the fallback.
---@param select_opts? cmp.SelectOption
---@return cmp.Mapping
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

---If completion menu is visible it will navigate to the next item in the
---list. If cursor is on top of the trigger of a snippet it'll expand it.
---If the cursor can jump to a luasnip placeholder, it moves to it. Else,
---it uses the fallback.
---@param select_opts? cmp.SelectOption
---@return cmp.Mapping
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

---If completion menu is visible it will navigate to the next item in the
---list. If the cursor can jump to a luasnip placeholder, it moves to it.
---Else, it uses the fallback.
---@param select_opts? cmp.SelectOption
---@return cmp.Mapping
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

