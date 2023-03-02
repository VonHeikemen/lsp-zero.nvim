# Tutorial

Here we will learn enough to about Neovim to configure lsp-zero `v2.0`. We will create a configuration file called `init.lua`, install a plugin manager, a colorscheme and finally setup lsp-zero.

## Requirements

* Basic knowledge about Neovim: what is `normal mode`, `insert mode`, `command mode` and how to navigate between them.
* Neovim v0.8 or greater
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
vim.cmd.colorscheme('morning')
```

Open Neovim again and you should notice the light theme. If you get an error it means your Neovim version does not meet the requirements. Visit Neovim's github repository, in the [release section](https://github.com/neovim/neovim/releases) you'll find prebuilt executables for the latest versions.

If you can't upgrade Neovim you can still install `v1.0` of lsp-zero, I have another tutorial for that:

* [Getting started with neovim's native LSP client](https://dev.to/vonheikemen/getting-started-with-neovims-native-lsp-client-in-the-year-of-2022-the-easy-way-bp3)

Assuming everything went well, you can now change the theme to something else.

```lua
vim.cmd.colorscheme('habamax')
```

## Install the Plugin Manager

> Note: We don't **need** a plugin manager but they make our lives easier.

We are going to use [lazy.nvim](https://github.com/folke/lazy.nvim), only because that's what the cool kids are doing these days. You can do a lot with lazy.nvim but I'm just going to show the most basic usage.

First step is to install it from github. It just so happens we can do this using lua. In lazy.nvim's documentation they show us how to do it.

Add this to your init.lua.

```lua
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

-- Auto-install lazy.nvim if not present
if not vim.loop.fs_stat(lazypath) then
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

Notice in `lazypath` we use `stdpath('data')`, this will return the path to Neovim's data folder. So now we don't need to worry changing our paths depending on the operating system, Neovim will do that for us. If you want to inspect the path, use this command.

```vim
:echo stdpath('data') . '/lazy/lazy.nvim'
```

To actually use lazy.nvim we need to call the `.setup()` function of the lua module called `lazy`.

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

When Neovim starts it should show a message telling us is cloning the plugin manager. After it's done another window will show up, it'll tell us the progress of the plugins download. After plugins are installed they will be loaded.

## Setup lsp-zero

Now we need to add lsp-zero and all its dependencies in lazy's list of plugins.

```lua
require('lazy').setup({
  {'folke/tokyonight.nvim'},
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'dev-v2',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {'williamboman/mason.nvim'},           -- Optional
      {'williamboman/mason-lspconfig.nvim'}, -- Optional

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    }
  }
})
```

Then we add the configuration at the end of the file.

```lua
local lsp = require('lsp-zero').preset({name = 'minimal'})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()
```

Save the file, restart Neovim and wait for everything to be downloaded.

### Install a language server

Let's try to use the language server for lua. 

Open your `init.lua` and execute the command `:LspInstall`. Now `mason.nvim` will suggest a language server.

```
Please select which server you want to install for filetype "lua":
1: lua_ls
Type number and <Enter> or click with the mouse (q or empty cancels):
```

Choose 1 for `lua_ls`, then press enter. A floating window will show up. When the server is done installing it a message should appear.

At the moment there is a good chance the language server can't start automatically. Use the command `:edit` to refresh the file or restart Neovim if that doesn't work. Once the server starts you'll notice warning signs in the global variable vim, that means everything is well and good.

To make sure `lua_ls` can detect the "root directory" of our config we need to create a file called `.luarc.json` in the Neovim config folder. This file can be empty, it just need to exists.

If you wanted to, you could setup `lua_ls` specifically for Neovim, all with one line of code.

```lua
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
```

Add this before the setup function of lsp-zero.

That's it. You are all set. Exit and open neovim again, you should have full support for neovim's lua api.

## Complete Example

```lua
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

-- Auto-install lazy.nvim if not present
if not vim.loop.fs_stat(lazypath) then
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
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'dev-v2',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {'williamboman/mason.nvim'},           -- Optional
      {'williamboman/mason-lspconfig.nvim'}, -- Optional

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    }
  }
})

-- Set colorscheme
vim.opt.termguicolors = true
vim.cmd.colorscheme('tokyonight')

-- LSP
local lsp = require('lsp-zero').preset({name = 'minimal'})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()
```

