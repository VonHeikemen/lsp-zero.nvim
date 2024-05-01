---@class lsp_zero.config.Omnifunc
---@inlinedoc
---
---When enabled it triggers the completion menu if the character
---under the cursor matches opts.keyword_pattern. 
---@field autocomplete? boolean
---
---Regex pattern used by the autocomplete implementation.
---Default value is "[[:keyword:]]".
---@field keyword_pattern? string
---
---Assigns common actions to keymaps.
---@field mapping? lsp_zero.config.OmnifuncMapping
---
---When enabled the first item in the completion menu
---will be selected automatically.
---@field preselect? boolean
---
---Configures what happens when you select an item in the completion menu. 
---@field select_behavior? string
---
---When enabled <Tab> will trigger the completion menu if the cursor is
---in the middle of a word. When the completion menu is visible it will
---navigate to the next item in the menu. If there is a blank character
---under the cursor it inserts a Tab character. <Shift-Tab> will navigate
---to the previous item in the menu, and if the menu is not visible it'll
---insert a Tab character.
---@field tabcomplete? boolean
---
---It must be a valid keyboard shortcut. This will be used as a
---keybinding to trigger the completion menu manually.
---@field trigger? string
---
---Turns out Neovim will hide the completion menu when you delete a
---character, so when you enable this option lsp-zero will trigger
---the menu again after you press <backspace>.
---@field update_on_delete? boolean
---
---When enabled lsp-zero will try to complete using
---the words in the current buffer.
---@field use_fallback? boolean
---
---When enabled Neovim will show the state of
---the completion in message area.
---@field verbose? boolean
---
---Callback that will be invoked when the CompleteDone event
---is triggered and the completion item is a snippet.
---@field expand_snippet? fun(text: string)

---@class lsp_zero.config.OmnifuncMapping
---@inlinedoc
---
---Confirm completion item.
---@field confirm? string
---
---Hide completion menu.
---@field abort? string
---
---Navigate to next completion item.
---@field next_item? string
---
---Navigate to previous completion item.
---@field prev_item? string

local M = {}
local s = {}
local group = 'lsp_zero_completion'
local pattern = '[[:keyword:]]'

local match = vim.fn.match
local pumvisible = vim.fn.pumvisible
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local t = function(k) return vim.api.nvim_replace_termcodes(k, true, false, true) end

local key = {
  omni = '<C-x><C-o>',
  buffer = '<C-x><C-n>',
  next_item = '<Down>',
  prev_item = '<Up>',
  confirm = '<C-y>',
  abort = '<C-e>',
  tab = '<Tab>',
}

---@param user_opts lsp_zero.config.Omnifunc
function M.setup(user_opts)
  if type(user_opts) ~= 'table' then
    user_opts = {}
  end

  local defaults = {
    -- completion modes
    tabcomplete = false,
    autocomplete = false,
    trigger = nil,
    use_fallback = false,

    -- custom behavior
    verbose = false,
    preselect = true,
    keyword_pattern = nil,
    select_behavior = 'select',
    update_on_delete = false,
    expand_snippet = nil,

    mapping = {
      confirm = nil,
      abort = nil,
      next_item = nil,
      prev_item = nil,
    }
  }

  local opts = vim.tbl_deep_extend('force', defaults, user_opts)

  local id = augroup('lsp_zero_omnifunc', {clear = true})
  local mapping = opts.mapping

  if type(opts.expand_snippet) == 'function' then
    local es = opts.expand_snippet
    local expand = s.expand_lsp_snippet
    autocmd('CompleteDone', {
      group = id,
      desc = 'Expand LSP snippet',
      callback = function(event) expand(event.buf, es) end,
    })
  end

  if opts.preselect == false then
    vim.opt.completeopt:append('noselect')
  end

  if opts.verbose == false then
    vim.opt.shortmess:append('c')
  end

  if type(opts.keyword_pattern) == 'string' then
    pattern = opts.keyword_pattern
  end

  if opts.select_behavior == 'select' then
    vim.opt.completeopt:append('noinsert')
  elseif opts.select_behavior == 'insert' then
    vim.opt.completeopt:remove('noinsert')
    key.next_item = '<C-n>'
    key.prev_item = '<C-p>'
  end

  vim.opt.completeopt:remove('preview')
  vim.opt.completeopt:append('menu')
  vim.opt.completeopt:append('menuone')

  s.keymap(mapping.next_item, key.next_item)
  s.keymap(mapping.prev_item, key.prev_item)
  s.keymap(mapping.abort, key.abort)

  if type(mapping.confirm) == 'string' then
    local confirm = string.lower(mapping.confirm)
    if not vim.tbl_contains({'<enter>', '<cr>'}, confirm) then
      s.keymap(mapping.confirm, key.confirm)
    end
  end

  local set_autocomplete = opts.autocomplete
  local set_tabcomplete = opts.tabcomplete
  local set_toggle = opts.trigger
  local map_backspace = opts.update_on_delete

  if set_autocomplete then
    vim.opt.completeopt:append('noinsert')

    ---
    -- preserve dot-repeat
    ---
    local plug_omni = '<Plug>(lsp-zero-complete-omni)'
    local plug_buffer = '<Plug>(lsp-zero-complete-word)'

    vim.keymap.set('i', plug_omni, function()
      return '<C-x><C-o>'
    end, {expr = true})

    vim.keymap.set('i', plug_buffer, function()
      return '<C-x><C-n>'
    end, {expr = true})

    key.plug_omni = t(plug_omni)
    key.plug_buffer = t(plug_buffer)
  end

  if opts.use_fallback then
    if set_autocomplete then
      M.autocomplete_fallback()
    end

    if set_tabcomplete then
      M.tab_complete_fallback()
    end

    if set_toggle then
      M.toggle_menu_fallback(set_toggle)
    end
  end

  autocmd('LspAttach', {
    group = id,
    desc = 'setup LSP omnifunc completion',
    callback = function(event)
      if set_autocomplete then
        M.autocomplete(event.buf)
      end

      if set_tabcomplete then
        M.tab_complete(event.buf)
      end

      if set_toggle then
        M.toggle_menu(set_toggle, event.buf)
      end

      if map_backspace then
        s.backspace(event.buf)
      end
    end
  })
end

function M.autocomplete(buffer)
  pcall(vim.api.nvim_clear_autocmds, {group = group, buffer = buffer})
  augroup(group, {clear = false})

  autocmd('InsertCharPre', {
    buffer = buffer,
    group = group,
    desc = 'Autocomplete using the LSP omnifunc',
    callback = s.try_complete,
  })
end

function M.autocomplete_fallback()
  augroup(group, {clear = false})

  autocmd('InsertCharPre', {
    group = group,
    desc = 'Autocomplete using words in current file',
    callback = s.try_complete_fallback,
  })
end

function M.tab_complete(buffer)
  vim.keymap.set('i', '<Tab>', s.tab_expr, {buffer = buffer, expr = true})
  vim.keymap.set('i', '<S-Tab>', s.prev_item, {buffer = buffer, expr = true})
end

function M.tab_complete_fallback()
  vim.keymap.set('i', '<Tab>', s.complete_words, {expr = true})
  vim.keymap.set('i', '<S-Tab>', s.prev_item, {expr = true})
end

function M.toggle_menu(lhs, buffer)
  vim.keymap.set('i', lhs, s.toggle_expr, {buffer = buffer, expr = true})
end

function M.toggle_menu_fallback(lhs)
  vim.keymap.set('i', lhs, s.toggle_fallback, {expr = true})
end

function s.try_complete()
  if pumvisible() > 0 or s.is_macro() then
    return
  end

  if match(vim.v.char, pattern) >= 0 then
    vim.api.nvim_feedkeys(key.plug_omni, 'n', false)
  end
end

function s.try_complete_fallback()
  if pumvisible() > 0 or s.is_macro() or s.is_prompt() then
    return
  end

  if match(vim.v.char, pattern) >= 0 then
    vim.api.nvim_feedkeys(key.plug_buffer, 'n', false)
  end
end

function s.backspace(buffer)
  local rhs = function()
    if pumvisible() == 1 then
      return '<bs><c-x><c-o>'
    end

    return '<bs>'
  end

  vim.keymap.set('i', '<bs>', rhs, {expr = true, buffer = buffer})
end

function s.keymap(lhs, action)
  if lhs == nil or string.lower(lhs) == string.lower(action) then
    return
  end

  local rhs = function()
    if pumvisible() == 1 then
      return action
    end

    return lhs
  end

  vim.keymap.set('i', lhs, rhs, {expr = true})
end

function s.has_words_before()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local col = cursor[2]

  if col == 0 then
    return false
  end

  local line = cursor[1]
  local str = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]

  return str:sub(col, col):match('%s') == nil
end

function s.is_macro()
  return vim.fn.reg_recording() ~= '' or vim.fn.reg_executing() ~= ''
end

function s.is_prompt()
  return vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt'
end

function s.tab_expr()
  if pumvisible() == 1 then
    return key.next_item
  end

  if s.has_words_before() then
    return key.omni
  end

  return key.tab
end

function s.complete_words()
  if pumvisible() == 1 then
    return key.next_item
  end

  if s.has_words_before() then
    return key.buffer
  end

  return key.tab
end

function s.prev_item()
  if pumvisible() == 1 then
    return key.prev_item
  end

  return key.tab
end

function s.toggle_expr()
  if pumvisible() == 1 then
    return key.abort
  end

  return key.omni
end

function s.toggle_fallback()
  if pumvisible() == 1 then
    return key.abort
  end

  return key.buffer
end

function s.expand_lsp_snippet(bufnr, expand)
  local comp = vim.v.completed_item
  local kind = vim.lsp.protocol.CompletionItemKind
  local item = vim.tbl_get(comp, 'user_data', 'nvim', 'lsp', 'completion_item')

  -- Check that we were given a snippet
  if (
    not item
    or not item.insertTextFormat
    or item.insertTextFormat == 1
    or not (
      item.kind == kind.Snippet
      or item.kind == kind.Keyword
    )
  ) then
    return
  end

  -- Remove the inserted text
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local lnum = cursor[1] - 1
  local start_col = cursor[2] - #comp.word

  if start_col < 0 then
    return
  end

  local set_text = vim.api.nvim_buf_set_text
  local ok = pcall(set_text, bufnr, lnum, start_col, lnum, #line, {''})

  if not ok then
    return
  end

  -- Insert snippet
  local snip_text = vim.tbl_get(item, 'textEdit', 'newText') or item.insertText

  if not snip_text then
    -- Language server indicated it had a snippet,
    -- but no snippet text could be found!
    return
  end

  expand(snip_text)
end

return M

