# Tutorial

Here we will learn enough about Neovim to configure lsp-zero version 4. We will create a configuration file called `init.lua`, install a plugin manager, a colorscheme and finally setup lsp-zero.

If you already have a Neovim configuration setup with a plugin manager, go to the getting started page for a quick start.

## Requirements

* Basic knowledge about Neovim: what is `normal mode`, `insert mode`, `command mode` and how to navigate between them.
* Neovim v0.10 or greater
* git

## The Entry Point

To start we will create the file known as `init.lua`. The location of this file depends on your operating system. If you want to know where that is execute this command on your terminal.

```sh
nvim --headless -c 'echo stdpath("config")' -c 'echo ""' -c 'quit'
```

Create that folder and then navigate to it. Use whatever method you know best, use a terminal or a graphical file explorer.

Now create an empty file called `init.lua`.

Once the configuration exists in your system you can access it from the terminal using this command.

```sh
nvim -c 'edit $MYVIMRC'
```

Now let's make sure Neovim is actually loading our file. We will change the colorscheme to a light theme. So, open your `init.lua` and add this line.

```lua
if vim.fn.has('nvim-0.10') == 1 then
  vim.cmd.colorscheme('morning')
else
  vim.cmd.colorscheme('blue')
end
```

Open Neovim again and you should notice the light theme. If you get the blue theme then your  Neovim version does not meet the requirements. Visit Neovim's github repository, in the [release section](https://github.com/neovim/neovim/releases) you'll find prebuilt executables for the latest versions.

If you can't upgrade Neovim you can still install a previous version of lsp-zero.

Assuming everything went well, you can now delete the `if` block and change to a dark theme.

```lua
vim.cmd.colorscheme('habamax')
```

## Install the Plugin Manager

> [!NOTE]
> We don't **need** a plugin manager but they make our lives easier.

We are going to use [lazy.nvim](https://github.com/folke/lazy.nvim), only because that's what the cool kids are doing these days. You can do a lot with lazy.nvim but I'm just going to show the most basic usage.

First step is to install it from github. It just so happens we can do this using lua. In lazy.nvim's documentation they show us how to do it.

Add this to your init.lua.

```lua
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)
```

Notice in `lazypath` we use `stdpath('data')`, this will return the path to Neovim's data folder. So now we don't need to worry about changing our paths depending on the operating system, Neovim will do that for us. If you want to inspect the path, use this command inside Neovim.

```vim
:echo stdpath('data') . '/lazy/lazy.nvim'
```

To actually use lazy.nvim we need to call the `.setup()` function of the lua module called `lazy`. Like this.

```lua
require('lazy').setup({
  ---
  -- List of plugins...
  ---
})
```

## Adding a new plugin

Now let's use lazy.nvim for real this time. We are going to test it with a plugin called [tokyonight.nvim](https://github.com/folke/tokyonight.nvim), this is a colorscheme that will make Neovim look pretty.

Ready? We are going to follow these steps.

1. Add the plugin in lazy's setup.

```lua
require('lazy').setup({
  {'folke/tokyonight.nvim'},
})
```

2. We need to delete the old colorscheme line if it's still there.

3. Call the new colorscheme at the end of the `init.lua` file.

```lua
vim.opt.termguicolors = true
vim.cmd.colorscheme('tokyonight')
```

4. Save the file.

5. Restart Neovim.

When Neovim starts it should show a message telling us is cloning the plugin manager. After it's done another window will show up, it'll tell us the progress of the plugin's download. After the plugins are installed they will be loaded.

### Learning more about lazy.nvim

If you want to know more details about lazy.nvim, here are a few resources (that you can read later). 

* [Lazy.nvim: plugin configuration](https://dev.to/vonheikemen/lazynvim-plugin-configuration-3opi). This will teach you the basics of the "plugin spec" and how to split your plugin setup into multiple files.

* [Lazy.nvim: how to revert a plugin back to a previous version](https://dev.to/vonheikemen/lazynvim-how-to-revert-a-plugin-back-to-a-previous-version-1pdp). Learn how to recover from a bad plugin update.


## Setup lsp-zero

Now we need to add lsp-zero and all its dependencies in lazy's list of plugins.

```lua
require('lazy').setup({
  {'folke/tokyonight.nvim'},
  {'VonHeikemen/lsp-zero.nvim', branch = 'v4.x'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
})
```

Then we add the configuration at the end of the file.

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end

lsp_zero.extend_lspconfig({
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})
```

Save the file, restart Neovim and wait for everything to be downloaded.

Right now this setup won't do much. We don't have any language server installed (and the code to use them is not there yet).

### Language servers and how to use them

First thing you would want to do is install a language server. There are two ways you can do this:

#### Manual global install

In [nvim-lspconfig's documentation](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) you will find the list of language servers currently supported. Some of them have install instructions you can follow, others will have a link to the repository of the language server.

Let's pretend that we installed `tsserver` and `rust_analyzer`, this is how we would use them.

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end

lsp_zero.extend_lspconfig({
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

require('lspconfig').tsserver.setup({})
require('lspconfig').rust_analyzer.setup({})
```

We use the module `lspconfig` and call the setup function of each language server we installed.

If you need to customize a language server, add your config inside the curly braces of the setup function. Here is an example.

```lua
require('lspconfig').tsserver.setup({
  single_file_support = false,
  on_attach = function(client, bufnr)
    print('hello world')
  end,
})
```

Now, if none of your language server need a special config you can use the function [.setup_servers()](./reference/lua-api#setup-servers-list-opts).

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end

lsp_zero.extend_lspconfig({
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

#### Local installation with mason.nvim

There is a plugin called [mason.nvim](https://github.com/williamboman/mason.nvim), is often described a portable package manager. This plugin will allow Neovim to download language servers (and other type of tools) into a particular folder, meaning that the servers you install using this method will not be available system-wide.

If you decide to use this plugin you'll need some extra tools installed in your system. So, take a look at [mason.nvim's requirements](https://github.com/williamboman/mason.nvim#requirements).

> [!NOTE]
> mason.nvim doesn't provide any "special integration" to the tools it downloads. It's only good for installing and updating tools.

Anyway, if you choose this method you will need to add these two plugins:

* `williamboman/mason.nvim`
* `williamboman/mason-lspconfig.nvim`

```lua
require('lazy').setup({
  {'folke/tokyonight.nvim'},
  {'VonHeikemen/lsp-zero.nvim', branch = 'v4.x'},
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
})
```

`mason.nvim` will make sure we have access to the language servers. And we will use `mason-lspconfig` to configure the automatic setup of every language server we install.

```lua
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end

lsp_zero.extend_lspconfig({
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})
```

Now you will have access to a command called `:LspInstall`. If you execute that command while you have a file opened `mason-lspconfig.nvim` will suggest a language server compatible with that type of file.

Note that after you install a language server you need to restart Neovim so it can be configured properly.

#### Root directory

This is a very important concept you need to keep in mind. The "root directory" is the path where your code is. Think of it as your project folder. When you open a file compatible with a language server `lspconfig` will search for a set of files in the current folder (your working directory) or any of the parent folders. If it finds them, the language server will start analyzing that folder.

Some language servers have "single file support" enabled, this means if `lspconfig` can't determine the root directory then the current working directory becomes your root directory.

Let's say you have `lua_ls` installed, if you want it to detect the root directory of your Neovim config you can create a file called `.luarc.json` in the same folder your `init.lua` is located.

#### Configure lua language server

If you installed the language server for lua you are probably getting a lots of warnings, most of them should be about the global variable `vim`. That is a Neovim specific variable, the lua language server doesn't know anything about it. There are a couple of ways we can fix this.

* Workspace specific config

We can add the following config to the `.luarc.json` file located in our Neovim config folder.

```json
{
  "runtime.version": "LuaJIT",
  "runtime.path": [
    "lua/?.lua",
    "lua/?/init.lua"
  ],
  "diagnostics.globals": ["vim"],
  "workspace.checkThirdParty": false,
  "workspace.library": [
    "$VIMRUNTIME",
    "${3rd}/luv/library"
  ]
}
```

* Lua config

lsp-zero has a function that applies a basic config to `lua_ls` as a backup. If there isn't any local config file (`.luarc.json`) in the current root directory then it applies the Neovim specific settings to the language server.

```lua
local lsp_zero = require('lsp-zero')

require('lspconfig').lua_ls.setup({
  on_init = function(client)
    lsp_zero.nvim_lua_settings(client)
  end,
})
```

## Setup autocompletion

Last thing we are going to do is setup the autocompletion plugin: `nvim-cmp`.

To use nvim-cmp you need the lua module called `cmp`. And to make it work with Neovim's LSP client this is the minimal configuration needed.

```lua
local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({}),
})
```

This will work but the keybindings you get basically emulate Neovim's defaults, which might not be enough for some.

Now this is the way you can add more keybindings.

```lua
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = cmp.mapping.preset.insert({
    -- Navigate between completion items
    ['<C-p>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
    ['<C-n>'] = cmp.mapping.select_next_item({behavior = 'select'}),

    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate between snippet placeholder
    ['<C-f>'] = cmp_action.vim_snippet_jump_forward(),
    ['<C-b>'] = cmp_action.vim_snippet_jump_backward(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  }),
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
})
```

Note that here I'm showing a function called [.cmp_action()](./reference/lua-api#cmp-action), other extra mappings that people requested. There is a function for tab complete, one for a "supertab" behavior and a few others.

## Complete code

<details>

<summary>Expand: Manual setup of language servers </summary>

```lua
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {'folke/tokyonight.nvim'},
  {'VonHeikemen/lsp-zero.nvim', branch = 'v4.x'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
})

-- Set colorscheme
vim.opt.termguicolors = true
vim.cmd.colorscheme('tokyonight')

---
-- LSP setup
---
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end

lsp_zero.extend_lspconfig({
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})

---
-- Autocompletion config
---
local cmp = require('cmp')
local cmp_action = lsp_zero.cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate between snippet placeholder
    ['<C-f>'] = cmp_action.vim_snippet_jump_forward(),
    ['<C-b>'] = cmp_action.vim_snippet_jump_backward(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  }),
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
})
```

</details>


<details>

<summary>Expand: Automatic setup of language servers </summary>

```lua
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

-- Auto-install lazy.nvim if not present
if not uv.fs_stat(lazypath) then
  print('Installing lazy.nvim....')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
  print('Done.')
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {'folke/tokyonight.nvim'},
  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
})

-- Set colorscheme
vim.opt.termguicolors = true
vim.cmd.colorscheme('tokyonight')

---
-- LSP setup
---
local lsp_zero = require('lsp-zero')

local lsp_attach = function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end

lsp_zero.extend_lspconfig({
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  }
})

---
-- Autocompletion config
---
local cmp = require('cmp')
local cmp_action = lsp_zero.cmp_action()

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    -- `Enter` key to confirm completion
    ['<CR>'] = cmp.mapping.confirm({select = false}),

    -- Ctrl+Space to trigger completion menu
    ['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate between snippet placeholder
    ['<C-f>'] = cmp_action.vim_snippet_jump_forward(),
    ['<C-b>'] = cmp_action.vim_snippet_jump_backward(),

    -- Scroll up and down in the completion documentation
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
  }),
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
})
```

</details>

