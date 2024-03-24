# Configure volar 2.0 (with typescript support)

Volar 2.0 has discontinued their "take over mode" which in previous version provided support for typescript in vue files. The new approach to get typescript support involves using the typescript language server along side volar. So here I'll show you the steps necessary to make `tsserver` work in vue files.

Is worth mention the solution I'm about to show is not specific to lsp-zero. You can follow these steps even if you don't use lsp-zero.

## "The trick"

At the heart of everything what you need to do is install the package [@vue/typescript-plugin](https://www.npmjs.com/package/@vue/typescript-plugin) using `npm` and then configure the typescript language server to use it.

For `mason.nvim` there's note at the end of the post. I recommend reading the whole post then do the steps.

## NPM packages and where to install them...

We are going to install some packages using `npm install -g`.

But before you do anything, I recommend creating an `.npmrc` file in your home directory. So you can control where `npm` will install the packages. Something like this.

```
prefix=/home/dev/.local/share/npm
global-bin-dir=/home/dev/.local/share/npm/bin

# note: these are example paths. replace them with a valid paths
```

Use the `prefix` and `global-bin-dir` options to tell `npm` where it should install the global packages. If you do this you don't have to worry about node version managers changing your paths.

After you have an `.npmrc` in your home directory with all the right options, make sure the path in `global-bin-dir`

## NPM install

Now you can install the language server for typescript. Execute this command in your terminal.

```sh
npm install -g typescript typescript-language-server
```

And you install `volar` using this command.

```sh
npm install -g @vue/language-server
```

Since `@vue/typescript-plugin` is a dependency of `@vue/language-server` we don't have to specify it in the npm install command.

After you install these language servers is a good idea to check if Neovim "knows" where they are. For example, you can open Neovim and execute this command.

```vim
echo exepath('vue-language-server')
```

This should show you the path to the executable of `vue-language-server`. If it doesn't it means you need to setup your `PATH` environment variable properly. Make sure it contains the path where `npm` install the executables of global packages.

## The typescript language server

Now it's time to go to our Neovim configuration.

So the way you I usually setup `tsserver` is by calling the setup function of lspconfig. Like this.

```lua
require('lspconfig').tsserver.setup({})
```

There is where we need to add our new settings. We will add a lua table called `init_options` and inside that we add a plugins table.

```lua{2-6}
require('lspconfig').tsserver.setup({
  init_options = {
    plugins = {

    }
  },
})
```

Inside this `plugins` table we need to add the path where `@vue/typescript-plugin` is located. And here is where it gets tricky. The path would be something like this:

```lua
local vue_typescript_plugin = '/home/dev/.local/share/npm'
  .. '/lib/node_modules'
  .. '/@vue/language-server/node_modules'
  .. '/@vue/typescript-plugin'
```

But this first part `/home/dev/.local/share/npm`, you should replace it with the location of the "npm prefix" in your system. To get that information you can execute this command in your terminal.

```lua
npm config get prefix
```

After you figure out where is `@vue/typescript-plugin` you can add it to the plugins table of `tsserver`.

```lua{9-13}
local vue_typescript_plugin = '/home/dev/.local/share/npm'
  .. '/lib/node_modules'
  .. '/@vue/language-server/node_modules'
  .. '@vue/typescript-plugin'

require('lspconfig').tsserver.setup({
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vue_typescript_plugin,
        languages = {'javascript', 'typescript', 'vue'}
      },
    }
  },
})
```

And the last detail we need to take care of is adding `vue` as a filetype supported by `tsserver`.

```lua{16-24}
local vue_typescript_plugin = '/home/dev/.local/share/npm'
  .. '/lib/node_modules'
  .. '/@vue/language-server/node_modules'
  .. '@vue/typescript-plugin'

require('lspconfig').tsserver.setup({
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vue_typescript_plugin,
        languages = {'javascript', 'typescript', 'vue'}
      },
    }
  },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'vue',
  },
})
```

### Don't forget about volar

After you are done with `tsserver` you can just call the setup function for volar.

```lua
require('lspconfig').volar.setup({})
```

## Note for mason.nvim users

You don't have to execute `npm install -g`, you can install `volar` with `mason.nvim` and then get the path to `@vue/typescript-plugin` with some utility functions.

You can define the variable `vue_typescript_plugin` like this.

```lua
local vue_typescript_plugin = require('mason-registry')
  .get_package('vue-language-server')
  :get_install_path()
  .. '/node_modules/@vue/language-server'
  .. '/node_modules/@vue/typescript-plugin'
```

So the complete configuration code should be something like this.

```lua
local vue_typescript_plugin = require('mason-registry')
  .get_package('vue-language-server')
  :get_install_path()
  .. '/node_modules/@vue/language-server'
  .. '/node_modules/@vue/typescript-plugin'

require('lspconfig').tsserver.setup({
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vue_typescript_plugin,
        languages = {'javascript', 'typescript', 'vue'}
      },
    }
  },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'vue',
  },
})

require('lspconfig').volar.setup({})
```

