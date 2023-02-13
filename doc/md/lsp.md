# LSP

## Introduction

Language servers are configured and initialized using [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/).

If you ever wondered "What does lsp-zero do?" This is the answer:

```lua
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
local lsp_attach = function(client, bufnr)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, {buffer = bufnr})
  -- More keybindings and commands....
end

require('lspconfig').tsserver.setup({
  on_attach = lsp_attach,
  capabilities = lsp_capabilities
})
```

In this example I'm using `tsserver` but it could be any LSP server.

What happens is that lsp-zero uses `lspconfig`'s setup function to initialize the LSP server. Then uses the `on_attach` option to create the keybindings and commands. Finally, it passes the "client capabilities" to the LSP server, this is the integration between the LSP client and the autocompletion plugin.

## Default keybindings

When a language server gets attached to a buffer you gain access to some keybindings and commands. All of these are bound to built-in functions, so you can get more details using the `:help` command.

* `K`: Displays hover information about the symbol under the cursor in a floating window. See [:help vim.lsp.buf.hover()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.hover()).

* `gd`: Jumps to the definition of the symbol under the cursor. See [:help vim.lsp.buf.definition()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.definition()).

* `gD`: Jumps to the declaration of the symbol under the cursor. Some servers don't implement this feature. See [:help vim.lsp.buf.declaration()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.declaration()).

* `gi`: Lists all the implementations for the symbol under the cursor in the quickfix window. See [:help vim.lsp.buf.implementation()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.implementation()).

* `go`: Jumps to the definition of the type of the symbol under the cursor. See [:help vim.lsp.buf.type_definition()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.type_definition()).

* `gr`: Lists all the references to the symbol under the cursor in the quickfix window. See [:help vim.lsp.buf.references()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.references()).

* `gs`: Displays signature information about the symbol under the cursor in a floating window. See [:help vim.lsp.buf.signature_help()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.signature_help()). If a mapping already exists for this key this function is not bound.

* `<F2>`: Renames all references to the symbol under the cursor. See [:help vim.lsp.buf.rename()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.rename()).

* `<F3>`: Formats a buffer using the attached language server. See [:help vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format())).

* `<F4>`: Selects a code action available at the current cursor position. See [:help vim.lsp.buf.code_action()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.code_action()).

* `gl`: Show diagnostics in a floating window. See [:help vim.diagnostic.open_float()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.open_float()).

* `[d`: Move to the previous diagnostic in the current buffer. See [:help vim.diagnostic.goto_prev()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.goto_prev()).

* `]d`: Move to the next diagnostic. See [:help vim.diagnostic.goto_next()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.goto_next()).

