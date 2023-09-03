# Tutorial

Here we will learn enough about Neovim to configure lsp-zero. We will create a configuration file called `init.lua`, install a plugin manager, a colorscheme and finally setup lsp-zero.

## Requirements

* Basic knowledge about Neovim: what is `normal mode`, `insert mode`, `command mode` and how to navigate between them.
* Neovim v0.7 or greater
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

Now let's make sure Neovim is actually loading our file. We will add a little message in our config. So, open your `init.lua` and add this line.

```lua
vim.pretty_print('hello, world')
```

Open Neovim again and you should notice the message at the bottom of the screen. If you get an error it means your Neovim version does not meet the requirements.

If you can't upgrade Neovim you can still install `v1.0` of lsp-zero, I have another tutorial for that:

* [Getting started with neovim's native LSP client](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/tutorial.md)

Assuming everything went well, you can delete the message.

## Install the Plugin Manager

> Note: We don't **need** a plugin manager but they make our lives easier.

To download plugins we are going to use [vim-plug](https://github.com/junegunn/vim-plug), only because is still compatible with Neovim v0.7.

Go to vim-plug's github repo, in the [Installation section](https://github.com/junegunn/vim-plug#neovim), grab the command for your operating system, then execute it in your terminal. I'll use the linux one:

```sh
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

Now we return to our `init.lua`. At the end of the file we add.

```lua
local Plug = vim.fn['plug#']
vim.call('plug#begin')

vim.call('plug#end')
```

## Adding a new plugin

Now let's use vim-plug for real this time. We are going to test it with a plugin called [onedark.vim](https://github.com/joshdick/onedark.vim), this is a colorscheme that will make Neovim look pretty.

Ready? We are going to follow these steps.

1. Add the plugin to vim-plug's list. Use the `Plug` function in between the `vim.call` functions.

```lua
local Plug = vim.fn['plug#']
vim.call('plug#begin')

-- Colorscheme
Plug('joshdick/onedark.vim')

vim.call('plug#end')
```

2. Save the file.

3. Execute your configuration using the command `:source %`.

4. Install the plugin using the command `:PlugInstall`

5. Call the new colorscheme at the end of the `init.lua` file.

```lua
vim.opt.termguicolors = true
vim.cmd('colorscheme onedark')
```

6. Restart Neovim.

## Setup lsp-zero

We need to add lsp-zero and all its dependencies in vim-plug's list.

```lua
local Plug = vim.fn['plug#']
vim.call('plug#begin')

-- Colorscheme
Plug('joshdick/onedark.vim')

-- LSP Support
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/cmp-nvim-lsp')

-- Autocompletion
Plug('hrsh7th/nvim-cmp')
Plug('L3MON4D3/LuaSnip')

Plug('VonHeikemen/lsp-zero.nvim', {branch = 'compat-07'})

vim.call('plug#end')
```

Save the file, "source" it, install the plugins. Then add the configuration of lsp-zero at the end of the file.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)
```

Now you can restart Neovim.

But this setup won't doesn't do much. We don't have any language server installed (and the code to use them is not there yet).

### Language servers and how to use them

First thing you would want to do is install a language server. There are two ways you can do this:

#### Manual global install

In [nvim-lspconfig's documentation](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) you will find the list of LSP servers currently supported. Some of them have install instructions you can follow, others will have a link to the repository of the LSP server.

Let's pretend that we installed `tsserver` and `rust_analyzer`, this is how we would use them.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('lspconfig').tsserver.setup({})
require('lspconfig').rust_analyzer.setup({})
```

We use the module `lspconfig` and call the setup function of each language server we installed.

If you need to customize a language server, add your config inside the curly braces of the setup function. Here is an example.

```lua
require('lspconfig').tsserver.setup({
  single_file_support = false,
  on_init = function(client)
    -- disable formatting capabilities
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentFormattingRangeProvider = false
  end,
})
```

Now, if none of your language server need a special config you can use the function [.setup_servers()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/compat-07/doc/md/api-reference.md#setup_serverslist-opts).

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})
```

#### Local installation with mason.nvim

There is a plugin called [mason.nvim](https://github.com/williamboman/mason.nvim), is often described as a portable package manager. This plugin will allow Neovim to download language servers (and other type of tools) into a particular folder, meaning that the servers you install using this method will not be available system-wide.

> Note: mason.nvim doesn't provide any "special integration" with the tools it downloads. It's only good for installing and updating tools.

Anyway, if you choose this method you will need to add these two plugins:

* `williamboman/mason.nvim`
* `williamboman/mason-lspconfig.nvim`

```lua
local Plug = vim.fn['plug#']
vim.call('plug#begin')

-- Colorscheme
Plug('joshdick/onedark.vim')

-- LSP Support
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')

-- Autocompletion
Plug('hrsh7th/nvim-cmp')
Plug('L3MON4D3/LuaSnip')

Plug('VonHeikemen/lsp-zero.nvim', {branch = 'compat-07'})

vim.call('plug#end')
```

Install the new plugins and restart Neovim.

`mason.nvim` will make sure we have access to the LSP servers. And we will use `mason-lspconfig` to configure the automatic setup of every language server we install.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
  },
})
```

After doing this you will have access to a command called `:LspInstall`. If you execute that command while you have a file opened `mason-lspconfig.nvim` will suggest a language server compatible with that type of file.

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
    "./lua"
  ]
}
```

* Fixed config

You should only use this method if your Neovim config is the only lua project you will ever manage with `lua_ls`.

lsp-zero has a function that returns a basic config for `lua_ls`, this is how you use it.

```lua
require('lspconfig').lua_ls.setup(lsp_zero.nvim_lua_ls())
```

If you need to add your own config, use the first argument to `.nvim_lua_ls()`.

```lua
require('lspconfig').lua_ls.setup(
  lsp_zero.nvim_lua_ls({
    single_file_support = false,
    on_attach = function(client, bufnr)
      print('hello world')
    end,
  })
)
```

## Complete code

<details>
<summary>Expand: manual setup of LSP servers </summary>

```lua
local Plug = vim.fn['plug#']
vim.call('plug#begin')

-- Colorscheme
Plug('joshdick/onedark.vim')

-- LSP Support
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/cmp-nvim-lsp')

-- Autocompletion
Plug('hrsh7th/nvim-cmp')
Plug('L3MON4D3/LuaSnip')

Plug('VonHeikemen/lsp-zero.nvim', {branch = 'compat-07'})

vim.call('plug#end')

-- Set colorscheme
vim.opt.termguicolors = true
vim.cmd('colorscheme onedark')

-- LSP
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- Replace the language servers listed here
-- with the ones you have installed
lsp_zero.setup_servers({'tsserver', 'rust_analyzer'})

-- (Optional) configure lua language server
require('lspconfig').lua_ls.setup(lsp_zero.nvim_lua_ls())
```

</details>

<details>
<summary>Expand: automatic setup of LSP servers </summary>

```lua
local Plug = vim.fn['plug#']
vim.call('plug#begin')

-- Colorscheme
Plug('joshdick/onedark.vim')

-- LSP Support
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')

-- Autocompletion
Plug('hrsh7th/nvim-cmp')
Plug('L3MON4D3/LuaSnip')

Plug('VonHeikemen/lsp-zero.nvim', {branch = 'compat-07'})

vim.call('plug#end')

-- Set colorscheme
vim.opt.termguicolors = true
vim.cmd('colorscheme onedark')

-- LSP
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
    lua_ls = function()
      -- (Optional) configure lua language server
      require('lspconfig').lua_ls.setup(lsp_zero.nvim_lua_ls())
    end,
  }
})
```

</details>

