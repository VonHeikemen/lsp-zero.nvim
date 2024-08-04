# LSP Zero

Collection of functions that will help you use Neovim's LSP client. The aim is to provide abstractions on top of Neovim's LSP client that are easy to use.

> [!IMPORTANT]
> `v4.x` became the default branch on `August 03`. If you are here because of a youtube video or some other tutorial, pay attention to the version of lsp-zero its been used in that tutorial.

## Demo

Most people use lsp-zero just to help them setup [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (an autocompletion plugin) and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) (a plugin with pre-made configurations for various language servers). Here's a showcase of (some) features you can get using all those plugins.

> See [demo in asciinema](https://asciinema.org/a/636643)

[![php code being edited in neovim](https://asciinema.org/a/636643.png)](https://asciinema.org/a/636643) 

## Documentation

You can browse the documentation here: [lsp-zero.netlify.app/v4.x](https://lsp-zero.netlify.app/v4.x/introduction.html)

* [Tutorial for beginners](https://lsp-zero.netlify.app/v4.x/tutorial.html)
* [Installation and Basic Usage](https://lsp-zero.netlify.app/v4.x/getting-started.html)
* [LSP Configuration](https://lsp-zero.netlify.app/v4.x/language-server-configuration.html)
* [Autocomplete](https://lsp-zero.netlify.app/v4.x/autocomplete.html)

<details>

<summary>Expand: More Documentation Links </summary>

* Integrations

  * [Integrate with mason.nvim](https://lsp-zero.netlify.app/v4.x/guide/integrate-with-mason-nvim.html)
  * [Enable folds with nvim-ufo](https://lsp-zero.netlify.app/v4.x/guide/quick-recipes.html#enable-folds-with-nvim-ufo)
  * [Setup copilot.lua + nvim-cmp](https://lsp-zero.netlify.app/v4.x/guide/setup-copilot-lua-plus-nvim-cmp.html)
  * [Setup with nvim-jdtls](https://lsp-zero.netlify.app/v4.x/guide/setup-with-nvim-jdtls.html)
  * [Setup with nvim-navic](https://lsp-zero.netlify.app/v4.x/guide/quick-recipes.html#setup-with-nvim-navic)
  * [Setup with rustaceanvim](https://lsp-zero.netlify.app/v4.x/guide/quick-recipes.html#setup-with-rustaceanvim)
  * [Setup with flutter-tools](https://lsp-zero.netlify.app/v4.x/guide/quick-recipes.html#setup-with-flutter-tools)
  * [Setup with nvim-metals](https://lsp-zero.netlify.app/v4.x/guide/quick-recipes.html#setup-with-nvim-metals)
  * [Setup with haskell-tools](https://lsp-zero.netlify.app/v4.x/guide/quick-recipes.html#setup-with-haskell-tools)

* Guides

  * [What to do when the language server doesn't start?](https://lsp-zero.netlify.app/v4.x/guide/what-to-do-when-lsp-doesnt-start.html)
  * [Lazy loading with lazy.nvim](https://lsp-zero.netlify.app/v4.x/guide/lazy-loading-with-lazy-nvim.html)
  * [lua_ls for Neovim](https://lsp-zero.netlify.app/v4.x/guide/neovim-lua-ls.html)
  * [Configure Volar 2.0 (with typescript support)](https://lsp-zero.netlify.app/v4.x/guide/configure-volar-v2.html)

* API

  * [Commands](https://lsp-zero.netlify.app/v4.x/reference/commands.html)
  * [Variables](https://lsp-zero.netlify.app/v4.x/reference/variables.html)
  * [Lua API](https://lsp-zero.netlify.app/v4.x/guide/what-to-do-when-lsp-doesnt-start.html) 

* Blog posts

  * [You might not need lsp-zero](https://lsp-zero.netlify.app/v3.x/blog/you-might-not-need-lsp-zero.html)
  * [ThePrimeagen 0 to LSP config](https://lsp-zero.netlify.app/v3.x/blog/theprimeagens-config-from-2022.html)

</details>

### Upgrade guides

* [from v3.x to v4.x](https://lsp-zero.netlify.app/v4.x/guide/migrate-from-v3-branch.html)
* [from v2.x to v4.x](https://lsp-zero.netlify.app/v4.x/guide/migrate-from-v2-branch.html)
* [from v1.x to v4.x](https://lsp-zero.netlify.app/v4.x/guide/migrate-from-v1-branch.html)

## Quickstart (for the impatient)

If you want instructions visit the documentation. The following links just provide code for copy/paste.

* [Lua template configuration](https://lsp-zero.netlify.app/v4.x/template/lua-config.html)
* [Vimscript template configuration](https://lsp-zero.netlify.app/v4.x/template/vimscript-config.html)
* [Opinionated config](https://lsp-zero.netlify.app/v4.x/template/opinionated.html) 
* [ThePrimeagen's "0 to LSP" config updated](https://lsp-zero.netlify.app/v3.x/blog/theprimeagens-config-from-2022.html)

## Support

If you find this tool useful and want to support my efforts, [buy me a coffee ☕](https://www.buymeacoffee.com/vonheikemen).

[![buy me a coffee](https://res.cloudinary.com/vonheikemen/image/upload/v1618466522/buy-me-coffee_ah0uzh.png)](https://www.buymeacoffee.com/vonheikemen)

