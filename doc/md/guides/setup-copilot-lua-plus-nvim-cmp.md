# Setup copilot.lua + nvim-cmp

Notice I said `.lua`, I'm not talking about [github/copilot.vim](https://github.com/github/copilot.vim).

Disclaimer: I do not have access to copilot. I'm just repeating the instructions from the plugin [zbirenbaum/copilot-cmp](https://github.com/zbirenbaum/copilot-cmp).

These are the step you should follow.

1. Install the plugins [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua) and [zbirenbaum/copilot-cmp](https://github.com/zbirenbaum/copilot-cmp).

2. Call the setup function for copilot.lua.

```lua
require('copilot').setup({
  suggestion = {enabled = false},
  panel = {enabled = false},
})
require('copilot_cmp').setup()
```

3. Once copilot started, run the command `:Copilot auth` to start the authentication process.

4. Add the source in nvim-cmp.

```lua
local cmp = require('cmp')
local cmp_format = require('lsp-zero').cmp_format()

cmp.setup({
  sources = {
    {name = 'copilot'},
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({
      -- documentation says this is important.
      -- I don't know why.
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    })
  }),
  --- (Optional) Show source name in completion menu
  formatting = cmp_format,
})
```

