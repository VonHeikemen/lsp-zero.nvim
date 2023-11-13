# What to do when a language server doesn't start?

## Ensure the executable is on your PATH

First things first, do you know what is the "PATH"?

If the answer is "No, I don't know what the hell you are talking about?" I'm going to tell you.

```
The PATH is an environment variable that contains a list of folder locations
that the operating system searches for executable files.
```

Here are a couple of links that can be useful to you.

* [How To View and Update the Linux PATH Environment Variable](https://www.digitalocean.com/community/tutorials/how-to-view-and-update-the-linux-path-environment-variable)

* [How to set the path and environment variables in Windows](https://www.computerhope.com/issues/ch000549.htm)

Now that you know, we can move on.

You can check if Neovim can find the executable of a language server using this command.

```lua
:lua require('lsp-zero.check').executable('eslint')
```

Here `eslint` is just an example. You can replace it with the name of the language server you want to check.

If the command is successfull you should a message like this.

```
LSP server: eslint
+ "vscode-eslint-language-server" is executable
```

If the executable could not be found, update your PATH environment variable. Add the folder where the executable of the language server is located.

## Inspect the log file

If the language server fails after it starts, look for an error message in the log file. Use the command `:LspLog`.

## Ensure mason-lspconfig knows about the server

If you are using `mason-lspconfig` to handle the automatic setup, the first thing you can do is make sure mason-lspconfig recognizes the server.

Execute this command to inspect the list of installed servers.

```lua
:lua = require('mason-lspconfig').get_installed_servers()
```

If everything is okay you should see a list like this.

```lua
{"tsserver", "eslint"}
```

If your language server is not on this list execute the command `:LspInstall` with the name of the server. For example:

```lua
:LspInstall eslint
```

## Ensure the setup function for the language server was called

Open Neovim using this commmand `nvim test`. The idea here is that you open Neovim with an empty buffer with no filetype (why? just in case you are lazy loading lspconfig). Now execute the command `:LspInfo`, this will show a floating window with some information. You should have something like this.

```
 Press q or <Esc> to close this window. Press <Tab> to view server doc.
 
 Language client log: /home/dev/.local/state/nvim/lsp.log
 Detected filetype:  
 
 0 client(s) attached to this buffer: 
 
 Configured servers list: tsserver, eslint
```

Notice at the bottom it says `Configured servers list`, your language server should be there. If it isn't, you need to make sure lspconfig's setup function is being called.

If `eslint` were missing then you would need to make sure somewhere in your config this function is being called.

```lua
require('lspconfig').eslint.setup({})
```

If you used `mason-lspconfig` automatic setup then it's being called for you in the `handlers` option. You should have something like this.

```lua
require('mason-lspconfig').setup({
  handlers = {
    lsp_zero.default_setup,
  }
})
```

`.default_setup` should be calling lspconfig. We can inspect that if we want.

We can take control of the default handler and check the state of lspconfig after the setup.

```lua
require('mason-lspconfig').setup({
  handlers = {
    function(name)
      lsp_zero.default_setup(name)
      local lsp = require('lspconfig')[name]
      print(name, type(lsp.manager))
    end,
  }
})
```

If everything went well Neovim should show you the name of each language server and next to them the word `table`.

```
tsserver table
eslint table
```

If you get the word `nil` instead of `table`, open a new issue in lsp-zero.

## Ensure root_dir can be detected

When you execute the command `:LspInfo` inside an existing file you should get more data about the server.

Sometimes you will get something like this.

```
 Other clients that match the filetype: typescript

 Config: eslint
 	filetypes:         javascript, typescript, vue, svelte, astro
 	root directory:    Not found.
 	cmd:               /home/dev/.local/bin/vscode-eslint-language-server --stdio
 	cmd is executable: true
 	autostart:         true
```

The important bit is this.

```
 	root directory:    Not found.
```

This means `lspconfig` could not figure out what is the root of your project.

lspconfig will look for some common configuration file in the current directory or the parent directories. If it can't find them the language server doesn't get attached to the file.

How do you know which files lspconfig looks for? Ideally, you would know because you read the documentation. Each server looks for a particular set of files and you can find that information here: [server_configurations.md](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md).

Sometimes the documentation in lspconfig just says `see source file` in the `root_dir` section. In this case what you can do is inspect the source code of lspconfig. You can use the command `:LspZeroViewConfigSource` with the name of a language server, this will open the configuration file for that server in a split window.

So you can inspect `eslint` config using this.

```vim
:LspZeroViewConfigSource eslint
```

Once there, you can look for a property called `root_dir`. This property is usually a lua function, so you might find some amount of logic there, but you can still get an idea of which files lspconfig looks for.

