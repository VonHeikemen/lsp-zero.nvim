# LSP Zero

The purpose of this plugin is to bundle all the "boilerplate code" necessary to have [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (a popular autocompletion plugin) and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) working together.

If you have any question about a feature or configuration feel free to open a new [discussion](https://github.com/VonHeikemen/lsp-zero.nvim/discussions) in this repository. Or join the chat [#lsp-zero-nvim:matrix.org](https://matrix.to/#/#lsp-zero-nvim:matrix.org).

## Announcement

Hello there. This is the development branch for version 3 of lsp-zero.

This version requires Neovim v0.8 or greater. If have Neovim v0.7.2 or lower please use the [v1.x branch](https://github.com/VonHeikemen/lsp-zero.nvim/tree/v1.x).

## How to get started

If you are new to neovim and you don't have a configuration file (`init.lua`) follow this [step by step tutorial](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/tutorial.md).

If you know how to configure neovim go to [Quickstart (for the impatient)](#quickstart-for-the-impatient).

Also consider [you might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/you-might-not-need-lsp-zero.md).

## Documentation

* LSP

  * [How does it work?](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#how-does-it-work)
  * [Commands](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#commands)
  * [Creating new keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#creating-new-keybindings)
  * [Disable keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#disable-keybindings)
  * [Install new language servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#install-new-language-servers)
  * [Configure language servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#configure-language-servers)
  * [Disable semantic highlights](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#disable-semantic-highlights)
  * [Disable a language server](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#disable-a-language-server)
  * [Custom servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#custom-servers)
  * [Enable Format on save](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#enable-format-on-save)
  * [Format buffer using a keybinding](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#format-buffer-using-a-keybinding)
  * [Use icons in the sign column](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#use-icons-in-the-sign-column)
  * [Troubleshooting](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#troubleshooting)

* Autocompletion

  * [How does it work?](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#how-does-it-work)
  * [Keybindings](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#keybindings)
  * [Use Enter to confirm completion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#use-enter-to-confirm-completion)
  * [Adding a source](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#adding-a-source)
  * [Add an external collection of snippets](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#add-an-external-collection-of-snippets)
  * [Preselect first item](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#preselect-first-item)
  * [Basic completions for Neovim's lua api](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#basic-completions-for-neovims-lua-api)
  * [Enable "Super Tab"](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#enable-super-tab)
  * [Regular tab complete](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#regular-tab-complete)
  * [Invoke completion menu manually](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#invoke-completion-menu-manually)
  * [Adding borders to completion menu](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#adding-borders-to-completion-menu)
  * [Change formatting of completion item](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#change-formatting-of-completion-item)
  * [lsp-kind](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#lsp-kind)

* Reference and guides

  * [API Reference](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md)
  * [Tutorial: Step by step setup from scratch](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/tutorial.md)
  * [Migrate from v1.x branch](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/migrate-from-v1-branch.md)
  * [lsp-zero under the hood](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/under-the-hood.md)
  * [You might not need lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/you-might-not-need-lsp-zero.md)
  * [Lazy loading with lazy.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/lazy-loading-with-lazy-nvim.md)
  * [Integrate with mason.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/integrate-with-mason-nvim.md)
  * [Integrate with null-ls](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/integrate-with-null-ls.md)
  * [Enable folds with nvim-ufo](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#enable-folds-with-nvim-ufo)
  * [Enable inlay hints with inlay-hints.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#enable-inlay-hints-with-inlay-hintsnvim)
  * [Setup copilot.lua + nvim-cmp](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/setup-copilot-lua-plus-nvim-cmp.md#setup-copilotlua--nvim-cmp)
  * [Setup with nvim-navic](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-nvim-navic)
  * [Setup with rust-tools](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-rust-tools)
  * [Setup with typescript.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-typescriptnvim)
  * [Setup with flutter-tools](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-flutter-tools)
  * [Setup with nvim-jdtls](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/setup-with-nvim-jdtls.md)
  * [Setup with nvim-metals](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-nvim-metals)
  * [Setup with haskell-tools](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-haskell-tools)
  * [Setup with clangd_extensions.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/quick-recipes.md#setup-with-clangd_extensionsnvim)

## Quickstart (for the impatient)

This section will teach you how to create a basic configuration.

### Installing

Use your favorite plugin manager to install this plugin and all its lua dependencies.

<details>
<summary>Expand: lazy.nvim snippet </summary>

For a more advance config that lazy loads everything take a look at the example on this link: [Lazy loading guide](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/lazy-loading-with-lazy-nvim.md).

```lua
{
  {'VonHeikemen/lsp-zero.nvim', branch = 'dev-v3'},

  --- Uncomment these if you want to manage LSP servers from neovim
  -- {'williamboman/mason.nvim'},
  -- {'williamboman/mason-lspconfig.nvim'},

  -- LSP Support
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {'hrsh7th/cmp-nvim-lsp'},
    },
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      {'L3MON4D3/LuaSnip'},
    }
  }
}
```

</details>

<details>
<summary>Expand: packer.nvim snippet </summary>

```lua
use {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'dev-v3',
  requires = {
    --- Uncomment these if you want to manage LSP servers from neovim
    -- {'williamboman/mason.nvim'},
    -- {'williamboman/mason-lspconfig.nvim'},

    -- LSP Support
    {'neovim/nvim-lspconfig'},
    -- Autocompletion
    {'hrsh7th/nvim-cmp'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'L3MON4D3/LuaSnip'},
  }
}
```
</details>

<details>
<summary>Expand: paq.nvim snippet </summary>

```lua
{'VonHeikemen/lsp-zero.nvim', branch = 'dev-v3'};

--- Uncomment these if you want to manage LSP servers from neovim
-- {'williamboman/mason.nvim'};
-- {'williamboman/mason-lspconfig.nvim'};

-- LSP Support
{'neovim/nvim-lspconfig'};
-- Autocompletion
{'hrsh7th/nvim-cmp'};
{'hrsh7th/cmp-nvim-lsp'};
{'L3MON4D3/LuaSnip'};
```

</details>

<details>
<summary>Expand: vim-plug snippet </summary>

```vim
"  Uncomment these if you want to manage LSP servers from neovim
"  Plug 'williamboman/mason.nvim'
"  Plug 'williamboman/mason-lspconfig.nvim'

" LSP Support
Plug 'neovim/nvim-lspconfig'
" Autocompletion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'

Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'dev-v3'}
```

When using vimscript you can wrap lua code in `lua <<EOF ... EOF`.

```vim
" Don't copy this example
lua <<EOF
print('this an example code')
print('written in lua')
EOF
```

</details>

### Usage

If you prefer to install every language server using "traditional" methods then go for the [manual setup section](#manual-setup-of-lsp-servers).

If want to manage the install and update of LSP servers from within Neovim then go to the [automatic setup section](#automatic-setup-of-lsp-servers).

#### Manual setup of LSP servers

First thing you'll want to do is install the language servers you want to use. Go to nvim-lspconfig's documentation, in the [server_configuration.md](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) file you'll find the list of LSP servers and how to install them.

Once you have the LSP servers installed in your system, add the config of lsp-zero.

```lua
local lsp = require('lsp-zero')

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

-- (Optional) Configure lua language server for neovim
-- require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

-- Replace the language servers listed here
-- with the ones installed in your system
lsp.setup_servers({'tsserver', 'rust_analyzer'})
```

If you want to customize a language server use the module `lspconfig`. Call the `setup` function of the LSP server like this.

```lua
require('lspconfig').lua_ls.setup({})
```

Here `lua_ls` is the language server we want to configure. And inside the `{}` is where you place the config. To get more details on the available options read the help page, use the command `:help lspconfig-setup`.

#### Automatic setup of LSP servers

If you decided to install [mason.nvim](https://github.com/williamboman/mason.nvim) and [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) you can manage the installation of the LSP servers from inside Neovim, and then use lsp-zero to handle the configuration.

Here a basic usage example.

```lua
local lsp = require('lsp-zero')

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  -- Replace the language servers listed here
  -- with the ones you want to install
  ensure_installed = {'tsserver', 'rust_analyzer'},
  handlers = {
    lsp.default_setup,
    lua_ls = function()
      -- (Optional) Configure lua language server for neovim
      require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
    end,
  },
})
```

For more details about how to use mason.nvim with lsp-zero see the guide on how to [integrate with mason.nvim](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/guides/integrate-with-mason-nvim.md).

## Language servers

Here are some things you need to know:

* The configuration for the language servers are provided by [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig).
* lsp-zero will create keybindings, commands, and will integrate nvim-cmp (the autocompletion plugin) with lspconfig if possible. You need to call lsp-zero's preset function before using lspconfig.

### Keybindings

When a language server gets attached to a buffer you gain access to some keybindings and commands. All of these shortcuts are bound to built-in functions, so you can get more details using the `:help` command.

* `K`: Displays hover information about the symbol under the cursor in a floating window. See [:help vim.lsp.buf.hover()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.hover()).

* `gd`: Jumps to the definition of the symbol under the cursor. See [:help vim.lsp.buf.definition()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.definition()).

* `gD`: Jumps to the declaration of the symbol under the cursor. Some servers don't implement this feature. See [:help vim.lsp.buf.declaration()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.declaration()).

* `gi`: Lists all the implementations for the symbol under the cursor in the quickfix window. See [:help vim.lsp.buf.implementation()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.implementation()).

* `go`: Jumps to the definition of the type of the symbol under the cursor. See [:help vim.lsp.buf.type_definition()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.type_definition()).

* `gr`: Lists all the references to the symbol under the cursor in the quickfix window. See [:help vim.lsp.buf.references()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.references()).

* `gs`: Displays signature information about the symbol under the cursor in a floating window. See [:help vim.lsp.buf.signature_help()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.signature_help()). If a mapping already exists for this key this function is not bound.

* `<F2>`: Renames all references to the symbol under the cursor. See [:help vim.lsp.buf.rename()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.rename()).

* `<F3>`: Format code in current buffer. See [:help vim.lsp.buf.format()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format()).

* `<F4>`: Selects a code action available at the current cursor position. See [:help vim.lsp.buf.code_action()](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.code_action()).

* `gl`: Show diagnostics in a floating window. See [:help vim.diagnostic.open_float()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.open_float()).

* `[d`: Move to the previous diagnostic in the current buffer. See [:help vim.diagnostic.goto_prev()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.goto_prev()).

* `]d`: Move to the next diagnostic. See [:help vim.diagnostic.goto_next()](https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.goto_next()).

By default lsp-zero will not create a keybinding if its "taken". This means if you already use one of these in your config, or some other plugins uses it ([which-key](https://github.com/folke/which-key.nvim) might be one), then lsp-zero's bindings will not work.

You can force lsp-zero's bindings by adding `preserve_mappings = false` to [.default_keymaps()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#default_keymapsopts).

```lua
lsp.default_keymaps({
  buffer = bufnr,
  preserve_mappings = false
})
```

### Troubleshooting

If you are having problems with a language server I recommend that you reduce your config to a minimal and check the logs of the LSP server.

What do I mean with a minimal example? Configure the language just using `lspconfig` and increase the log level. Here is a minimal config using `tsserver` as an example.

```lua
vim.lsp.set_log_level('debug')

vim.g.lsp_zero_extend_cmp = 0
vim.g.lsp_zero_extend_lspconfig = 0

local lsp_zero = require('lsp-zero')
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig').tsserver.setup({
  capabilities = lsp_capabilities,
  on_attach = function(client, bufnr)
    lsp_zero.default_keymaps({buffer = bufnr})
  end,
})

local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'}
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})
```

Then you can test the language and inspect the log file using the command `:LspLog`.

## Autocomplete

The plugin responsable for autocompletion is [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). The default config in lsp-zero will only add the minimum required to integrate lspconfig, nvim-cmp and [luasnip](https://github.com/L3MON4D3/LuaSnip).

### Keybindings

The default keybindings in lsp-zero are meant to emulate Neovim's default whenever possible.

* `<Ctrl-y>`: Confirms selection.

* `<Ctrl-e>`: Cancel completion.

* `<Down>`: Navigate to the next item on the list.

* `<Up>`: Navigate to previous item on the list.

* `<Ctrl-n>`: If the completion menu is visible, go to the next item. Else, trigger completion menu.

* `<Ctrl-p>`: If the completion menu is visible, go to the previous item. Else, trigger completion menu.

To add more keybindings I recommend you use [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) directly.

Here is an example configuration.

```lua
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate between snippet placeholder
    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  })
})
```

## Breaking changes

Changed/Removed features from the `v2.x` branch.

Note: You can disable the warnings about removed functions by setting the global variable `lsp_zero_api_warnings` to `0`. Before you require the module lsp-zero, put this `vim.g.lsp_zero_api_warnings = 0`.

### Functions

* [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#presetopts) was removed. Most settings were remove. The remaining settings can be changed using global variables, see [global variables](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#global-variables).
* [.set_preferences()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#set_preferencesopts) was removed in favor of overriding option directly in the [.preset()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#presetname).
* [.setup_nvim_cmp()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup_nvim_cmpopts) was be removed. Use the `cmp` module to customize nvim-cmp.
* [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#setup_serverslist) will no longer take an options argument. It'll only be a convenient way to initialize a list of servers.
* [.default.diagnostics()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#defaultsdiagnosticsopts) was removed. Diagnostics are not configured anymore.
* [.defaults.cmp_sources()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#defaultscmp_sources) was removed. Sources for nvim-cmp should be handled by the user.
* [.defaults.cmp_mappings()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#defaultscmp_mappingsopts) was removed. All nvim-cmp mappings can be overriden using the `cmp` module.
* [.nvim_workspace()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#nvim_workspaceopts) was removed. Use [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#nvim_lua_lsopts) to get the config for the lua language server.
* [.defaults.nvim_workspace()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#defaultsnvim_workspace) was replaced by [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#nvim_lua_lsopts).
* [.ensure_installed()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#ensure_installedlist) was removed. Use the module `mason-lspconfig` to install LSP servers.
* [.new_server()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#new_serveropts) was renamed to [.new_client()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#new_clientopts).

## FAQ

### How do I get rid warnings in my neovim lua config?

lsp-zero has a function that will configure the lua language server for you: [.nvim_lua_ls()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/api-reference.md#nvim_lua_lsopts)

### Can I use the Enter key to confirm completion item?

Yes, you can. You can find the details in the autocomplete documentation: [Enter key to confirm completion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#use-enter-to-confirm-completion).

### My luasnip snippet don't show up in completion menu. How do I get them back?

If you have this problem I assume you are migrating from the `v1.x` branch. What you have to do is add the luasnip source in nvim-cmp, then call the correct luasnip loader. You can find more details of this in the [documentation for autocompletion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#add-an-external-collection-of-snippets).

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)

