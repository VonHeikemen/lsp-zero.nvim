# Tutorial

## Requirements

* Neovim v0.7.0 or greater.
* For unix systems we need: git, curl or wget, unzip, tar, gzip.
* For windows + powershell: git, tar, and 7zip or peazip or archiver or winzip or WinRAR.

We need all of this because we want to manage our language server from inside neovim.

For the following examples I'll assume you have a linux system. I'll also assume you know how to enter commands inside neovim.

## We begin with a little lua

Let's figure out where our config file should live. Open neovim, then use the command `:echo stdpath('config')`, it'll show you the path where the lua config should be. In my case it shows `/home/dev/.config/nvim`. So now we use neovim to create that file, enter the command.

```
:edit ~/.config/nvim/init.lua
```

Let's start with a simple test to make sure everything works. If you press `<Tab>` in insert mode you'll notice it takes 8 spaces, we are going to change that by adding this to our init.lua.

```lua
-- Tab set to two spaces
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
```

We save the file and quit with the command `:wq`.

We enter neovim again, go to insert mode then press `<Tab>`. If tab expands to two spaces we know everything is fine. If not, you're most likely editing the wrong file.

## Plugin manager

To download plugins we are going to use `packer`, only is one popular plugin managers out there.

Go to packer.nvim's github repo, in the [quickstart section](https://github.com/wbthomason/packer.nvim#quickstart), grab the `git clone` command for your operating system. I'll take the linux one:

```sh
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

Now we return to our `init.lua`. At the end of the file we add.

```lua
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Colorscheme
  use 'joshdick/onedark.vim'
end)
```

A couple of things are happening in here. We are initializing `packer` and we are telling it to manage two plugins. The pattern you should notice is:

```lua
use 'github-user/repo'
```

that's all packer needs to download a plugin from github.

At this point we don't need to do the save-quit dance. Save the file with `:write`, then evaluate it with `:source %`. Now you can install the new plugins. Execute `:PackerSync`. A split window will show up telling us the progress of the download. Once the download is finished you can press `q` to close the progress window.

To test that everything went well we are going to use the new colorscheme. At the end of `init.lua` add.

```lua
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
pcall(vim.cmd, 'colorscheme onedark')
```

Save, evaluate. You'll notice the pretty colors.

## LSP Support

Finally, we are in good shape to add the cool LSP features. Okay, we'll add lsp-zero and all its dependencies after the `use` statement that has the colorscheme.

Our plugin list should look like this.

```lua
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Colorscheme
  use 'joshdick/onedark.vim'

  -- LSP
  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v1.x',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      -- Snippets
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},
    }
  }
end)
```

Save the file, evaluate (again). Install with `:PackerSync`.

Add the configuration for `lsp-zero`.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.setup()
```

Save and quit neovim.

Open neovim again. Now try to edit `init.lua`. Use the command `:edit $MYVIMRC`. Then use the command `:LspInstall`. Now the plugin `mason-lspconfig.nvim` will suggest a language server.

```
Please select which server you want to install for filetype "lua":
1: lua_ls
Type number and <Enter> or click with the mouse (q or empty cancels):
```

Choose 1 for `lua_ls`, then press enter. A floating window appear, it will show the progress of the installation.

At the moment there is a good chance the language server can't start automatically after install. Use the command `:edit` to refresh the file or restart neovim if that doesn't work. Once the server starts you'll notice warning signs in the global variable `vim`, that means everything is well and good.

If you wanted to, you could add a completion source and setup `lua_ls` specifically for neovim, all with one line of code.

```lua
lsp.nvim_workspace()
```

You need to add it before calling `.setup()`.

```lua
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.nvim_workspace()

lsp.setup()
```

That's it. You are all set. Exit and open neovim again, you should have full support for neovim's lua api.

## Complete Example

```lua
---
-- Settings
---

-- Tab set to two spaces
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- Give me space
vim.opt.signcolumn = 'yes'

---
-- Plugins
---

require('packer').startup(function(use)
  -- packer can update itself
  use 'wbthomason/packer.nvim'

  -- colorscheme
  use 'joshdick/onedark.vim'

  -- LSP
  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v1.x',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},

      -- Snippets
      {'L3MON4D3/LuaSnip'},
      {'rafamadriz/friendly-snippets'},
    }
  }
end)

-- Setup colorscheme
vim.opt.termguicolors = true
pcall(vim.cmd, 'colorscheme onedark')

-- LSP setup
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.nvim_workspace()

lsp.setup()
```

## What's next?

Learn the default keybindings:

* [Keybindings for Autocompletion](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/autocomplete.md#default-keybindings)
* [Keybindings for the LSP actions](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/lsp.md#default-keybindings)

Take a look at a more advance setup, to learn how to configure LSP servers.

* [Configuring language servers](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/advance-usage.md#configuring-language-servers)

Also, read the documentation of [mason.nvim](https://github.com/williamboman/mason.nvim).

Ask me anything about `lsp-zero` here, in the [discussion tab](https://github.com/VonHeikemen/lsp-zero.nvim/discussions) on github, or matrix [#lsp-zero-nvim:matrix.org](https://matrix.to/#/#lsp-zero-nvim:matrix.org).

