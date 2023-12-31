This is what `require('lsp-zero')` does, explained with code:

```lua
--- btw, the user can disable all of this. or just parts of it.

---
-- lsp-zero applies cmp_nvim_lsp's capabilities automatically 
-- to each language server configured by lspconfig
---
local function ensure_capabilities()
  local util = require('lspconfig.util')

  util.on_setup = util.add_hook_after(
    util.on_setup,
    function(config, user_config)
      config.capabilities = vim.tbl_deep_extend(
        'force',
        config.capabilities,
        require('cmp_nvim_lsp').default_capabilities(),
        vim.tbl_get(user_config, 'capabilities') or {}
      )
    end
  )
end

---
-- since the user can load the plugins in whatever order they want,
-- lsp-zero only makes sure the "essential" options for nvim-cmp are in place.
---
local function ensure_cmp_works()
  local module_cache_empty = package.loaded['cmp'] == nil
  local ok, cmp = pcall(require, 'cmp')

  local base = {
    sources = {
      {name = 'nvim_lsp'}
    },
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
  }

  if ok and module_cache_empty then
    base.mapping = cmp.mapping.preset.insert({})
    cmp.setup(base)
    return
  end

  local make_new = function()
    local c = require('cmp')
    local cmp_config = c.get_config()
    local new_config = {}

    if vim.tbl_isempty(cmp_config.sources) then
      new_config.sources = base.sources
    end

    if vim.tbl_isempty(cmp_config.mapping) then
      new_config.mapping = c.mapping.preset.insert({})
    end

    local current_expand = cmp_config.snippet.expand
    local lsp_expand = base.snippet.expand

    new_config.snippet = {
      expand = function(args)
        local ok = pcall(current_expand, args)
        if not ok then
          current_expand = lsp_expand
          lsp_expand(args)
        end
      end,
    }

    return new_config
  end

  if ok and vim.g.loaded_cmp then
    cmp.setup(make_new())
    return
  end

  vim.api.nvim_create_autocmd('User', {
    pattern = 'CmpReady',
    once = true,
    callback = function() require('cmp').setup(make_new()) end,
  })
end

---
-- make some improvements to the ui
---
local function ui_settings()
  local border_style = 'rounded'

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    {border = border_style}
  )

  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {border = border_style}
  )

  vim.diagnostic.config({
    float = {border = border_style}
  })

  -- the default value for the signcolumn is 'auto'
  -- and that's annoying. don't believe me?
  -- use vim.opt.signcolumn = 'auto'
  vim.opt.signcolumn = 'yes'
end

---
-- this is what require('lsp-zero') does
---
ensure_capabilities()
ensure_cmp_works()
ui_settings()

---
-- now that all the boilerplate is done
-- the user can setup the language servers
---
require('lspconfig').lua_ls.setup({})

---
-- and also configure nvim-cmp however they want.
---
local cmp = require('cmp')
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- use the `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  })
})
```

