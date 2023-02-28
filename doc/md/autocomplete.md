# Autocompletion

## Introduction

The plugin responsable for autocompletion is [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). This plugin is designed to be unopinionated and modular. What this means for us (the users) is that we have to assemble various pieces to get a good experience. Here I'll tell you the different configurations lsp-zero can add to nvim-cmp.

Before we start let me just remind you the settings you can tweak from a preset.

```lua
manage_nvim_cmp = {
  set_basic_mappings = false,
  set_extra_mappings = false,
  set_sources = false,
  use_luasnip = true,
  set_format = true,
  documentation_border = true,
}
```

## Recommended sources

In nvim-cmp a "source" is a plugin that provides the actual data displayed in the completion menu. If you opt-in lsp-zero can configure these sources:

* [cmp-buffer](https://github.com/hrsh7th/cmp-buffer): provides suggestions based on the current file.

* [cmp-path](https://github.com/hrsh7th/cmp-path): gives completions based on the filesystem.

* [cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip): it shows snippets in the suggestions.

* [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp): show data send by the language server.

* [cmp-nvim-lua](https://github.com/hrsh7th/cmp-nvim-lua): provides completions based on neovim's lua api.

## Keybindings

### Vim's defaults

* `<Ctrl-y>`: Confirms selection.

* `<Ctrl-e>`: Cancel the completion.

* `<Up>`: Navigate to previous item on the list.

* `<Down>`: Navigate to the next item on the list.

* `<Ctrl-p>`: Navigate to previous item on the list.

* `<Ctrl-n>`: Navigate to the next item on the list.

### Added mappings

* `<Ctrl-u>`: Scroll up in the item's documentation.

* `<Ctrl-d>`: Scroll down in the item's documentation.

* `<Ctrl-f>`: Go to the next placeholder in the snippet.

* `<Ctrl-b>`: Go to the previous placeholder in the snippet.

