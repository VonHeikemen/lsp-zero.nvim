# Tutorial

Here we will learn enough about Neovim to configure lsp-zero `v2.0`. We will create a configuration file called `init.lua`, install a plugin manager, a colorscheme and finally setup lsp-zero.

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

* [Getting started with neovim's native LSP client](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/tutorial.md)

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

## Setup lsp-zero

Now we need to add lsp-zero and all its dependencies in lazy's list of plugins.

```lua
require('lazy').setup({
  {'folke/tokyonight.nvim'},
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {'williamboman/mason.nvim'},           -- Optional
      {'williamboman/mason-lspconfig.nvim'}, -- Optional

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'saadparwaiz1/cmp_luasnip'} -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    }
  }
})
```

Then we add the configuration at the end of the file.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.setup()
```

Save the file, restart Neovim and wait for everything to be downloaded.

### Install a language server

Let's try to use the language server for lua. 

Open your `init.lua` and execute the command `:LspInstall`. Now `mason.nvim` will suggest a language server. Neovim should show a message like this.

```
Please select which server you want to install for filetype "lua":
1: lua_ls
Type number and <Enter> or click with the mouse (q or empty cancels):
```

Choose 1 for `lua_ls`, then press enter. A floating window will show up. When the server is done installing, a message should appear.

At the moment the language server can't start automatically, restart Neovim so the language server can be configured properly. Once the server starts you'll notice warning signs in the global variable vim, that means everything is well and good.

#### Configure lua language server

At this point you are probably getting a lots of warnings in your Neovim config, most of them should be about the global variable `vim`. That is a Neovim specific variable, the lua language server doesn't know anything about it. There are a couple of ways we can fix this.

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
    "/usr/share/nvim/runtime/lua",
    "./lua"
  ]
}
```

In the `workspace.library` property you can add the path to Neovim's runtime files.

Note that Neovim's runtime folder could be in a different location, it really depends on how you installed Neovim. If you want to know what is the correct path to Neovim' runtime execute this command.

```vim
:echo $VIMRUNTIME
```

* Fixed config

You should only use this method if your Neovim config is the only lua project you will ever manage with `lua_ls`.

lsp-zero has a function that returns a basic config for `lua_ls`, this is how you use it.

```lua
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
```

Add that line before the `.setup()` function of lsp-zero.

If you need to add your own config, use the first argument to `.nvim_lua_ls()`.

```lua
require('lspconfig').lua_ls.setup(
  lsp.nvim_lua_ls({
    single_file_support = false,
    on_attach = function(client, bufnr)
      print('hello world')
    end,
  })
)
```

#### Root directory

This is a very important concept you need to keep in mind. The "root directory" is the path where your code is. Think of it as your project folder. When you open a file compatible with a language server `lspconfig` will search for a set of files in the current folder (your working directory) or any of the parent folders. If it finds them, the language server will start analyzing that folder.

Some language servers have "single file support" enabled, this means if `lspconfig` can't determine the root directory then the current working directory becomes your root directory.

If you want to know if `lspconfig` managed to find the root directory of your project execute the command `:LspInfo`.

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
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {'williamboman/mason.nvim'},           -- Optional
      {'williamboman/mason-lspconfig.nvim'}, -- Optional

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'saadparwaiz1/cmp_luasnip'} -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    }
  }
})

-- Set colorscheme
vim.opt.termguicolors = true
vim.cmd.colorscheme('tokyonight')

-- LSP
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp.default_keymaps({buffer = bufnr})
end)

require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()
```

