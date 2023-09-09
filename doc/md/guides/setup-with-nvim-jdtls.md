# Setup with nvim-jdtls

Here we will focus on getting a working configuration using [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls). The code in this guide will based of [starter.lvim/ftplugin/java.lua](https://github.com/LunarVim/starter.lvim/blob/a36820712ec282b201be431e7eb47a4bf32888c8/ftplugin/java.lua) and also the official documentation of nvim-jdtls.

## Requirements

* A working environment with Java 17 or greater
* Python 3.9 or greater
* A working configuration for Neovim (If you don't have one, follow this [step by step tutorial](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/tutorial.md))

The code on this guide assumes you will be using [mason.nvim](https://github.com/williamboman/mason.nvim) to install the following packages:

* [jdtls](https://github.com/eclipse/eclipse.jdt.ls)
* [java-test](https://github.com/microsoft/vscode-java-test) (optional)
* [java-debug-adapter](https://github.com/microsoft/java-debug) (optional)

Using `mason.nvim` to install these packages is optional, you can use the method you want. You'll have to modify a few paths though. I will keep all the paths in a function called `get_jdtls_paths` so is easier for you to change any path.

Here is the list of Neovim plugins you'll need:

* [lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim)
* [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)
* [mason.nvim](https://github.com/williamboman/mason.nvim) (optional)
* [nvim-dap](https://github.com/mfussenegger/nvim-dap) (optional)
* [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) (optional)
* [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) (optional)

The code to setup the debugger will be disabled by default. You can enable it by setting the property `debugger` to `true` in the variable called `features`.

## Before we start

Some context... the configuration for this guide was tested in Debian 11. I installed java using [sdkman](https://sdkman.io/). And I installed [jdtls](https://github.com/eclipse/eclipse.jdt.ls) using [mason.nvim](https://github.com/williamboman/mason.nvim). I'm not a java developer, I can't tell you this is the best setup for Java development, I can only tell you it worked on my machine.

You can still follow this guide if you are using another operating system.

## The first step

Setup lsp-zero and mason.nvim like you usually do. But don't setup `jdtls` with lsp-zero, we want `nvim-jdtls` to handle that LSP server.

```lua
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {'jdtls'},
  handlers = {
    lsp_zero.default_setup,
    jdtls = lsp_zero.noop,
  }
})
```

## Working with nvim-jdtls

The official documentation in nvim-jdtls suggest making an 'ftplugin' but I want to do things in a different way. I prefer a "setup script" that will be executed once. So instead of an ftplugin we are going to make a regular plugin.

Execute this command inside Neovim to make sure you have a plugin folder in your configuration folder.

```vim
:call mkdir(stdpath("config") . "/plugin", "p")
```

Now create a lua script called `jdtls.lua`. You can do this with vimscript if you want, here is the command.

```vim
:exe "edit" stdpath("config") . "/plugin/jdtls.lua" | write
```

In this new `jdtls.lua` script we are going to add our config for nvim-jdtls. There will be a lot code so first let me show you the structure of the configuration I want to create.

```lua
-- If you are using linux or mac this file will be located at:
-- ~/.config/nvim/plugin/jdtls.lua

-- `nvim-jdtls` will look for these files/folders
-- to determine the root directory of your project
local root_files = {
  '.git',
  'mvnw',
  'gradlew',
  'pom.xml',
  'build.gradle',
}

local function get_jdtls_paths()
  ---
  -- we will use this function to get all the paths
  -- we need to start the LSP server.
  ---
end

local function jdtls_on_attach(client, bufnr)
  ---
  -- This function will be executed everytime jdtls
  -- gets attached to a file.
  -- Here we will create the keybindings.
  ---
end

local function jdtls_setup(event)
  ---
  -- Here is where we setup nvim-jdtls.
  -- This function will be executed everytime you open a java file.
  ---

  local jdtls = require('jdtls')

  local config = {
    cmd = {'imagine-this-is-the-command-that-starts-jdtls'},
    root_dir = jdtls.setup.find_root(root_files),
    on_attach = jdtls_on_attach,
  }

  jdtls.start_or_attach(config)
end

vim.api.nvim_create_autocmd('FileType', {
  group = java_cmds,
  pattern = {'java'},
  desc = 'Setup jdtls',
  callback = jdtls_setup,
})
```

So we are going to use a `FileType` autocommand to execute some lua code everytime Neovim opens a java file. This is the same thing an ftplugin does, except we want to execute a function and not a whole file.

With `jdtls_setup` we will build the config for the module `jdtls`. This is where the LSP server starts.

`jdtls_on_attach` is where you can modify the keybindings you want to use.

`get_jdtls_paths` is where you can find the paths used to start the LSP server.

### Show me the code

The complete implementation for `jdtls.lua` is this:

```lua
local java_cmds = vim.api.nvim_create_augroup('java_cmds', {clear = true})
local cache_vars = {}

local root_files = {
  '.git',
  'mvnw',
  'gradlew',
  'pom.xml',
  'build.gradle',
}

local features = {
  -- change this to `true` to enable codelens
  codelens = false,

  -- change this to `true` if you have `nvim-dap`,
  -- `java-test` and `java-debug-adapter` installed
  debugger = false,
}

local function get_jdtls_paths()
  if cache_vars.paths then
    return cache_vars.paths
  end

  local path = {}

  path.data_dir = vim.fn.stdpath('cache') .. '/nvim-jdtls'

  local jdtls_install = require('mason-registry')
    .get_package('jdtls')
    :get_install_path()

  path.java_agent = jdtls_install .. '/lombok.jar'
  path.launcher_jar = vim.fn.glob(jdtls_install .. '/plugins/org.eclipse.equinox.launcher_*.jar')

  if vim.fn.has('mac') == 1 then
    path.platform_config = jdtls_install .. '/config_mac'
  elseif vim.fn.has('unix') == 1 then
    path.platform_config = jdtls_install .. '/config_linux'
  elseif vim.fn.has('win32') == 1 then
    path.platform_config = jdtls_install .. '/config_win'
  end

  path.bundles = {}

  ---
  -- Include java-test bundle if present
  ---
  local java_test_path = require('mason-registry')
    .get_package('java-test')
    :get_install_path()

  local java_test_bundle = vim.split(
    vim.fn.glob(java_test_path .. '/extension/server/*.jar'),
    '\n'
  )

  if java_test_bundle[1] ~= '' then
    vim.list_extend(path.bundles, java_test_bundle)
  end

  ---
  -- Include java-debug-adapter bundle if present
  ---
  local java_debug_path = require('mason-registry')
    .get_package('java-debug-adapter')
    :get_install_path()

  local java_debug_bundle = vim.split(
    vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'),
    '\n'
  )

  if java_debug_bundle[1] ~= '' then
    vim.list_extend(path.bundles, java_debug_bundle)
  end

  ---
  -- Useful if you're starting jdtls with a Java version that's 
  -- different from the one the project uses.
  ---
  path.runtimes = {
    -- Note: the field `name` must be a valid `ExecutionEnvironment`,
    -- you can find the list here: 
    -- https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    --
    -- This example assume you are using sdkman: https://sdkman.io
    -- {
    --   name = 'JavaSE-17',
    --   path = vim.fn.expand('~/.sdkman/candidates/java/17.0.6-tem'),
    -- },
    -- {
    --   name = 'JavaSE-18',
    --   path = vim.fn.expand('~/.sdkman/candidates/java/18.0.2-amzn'),
    -- },
  }

  cache_vars.paths = path

  return path
end

local function enable_codelens(bufnr)
  pcall(vim.lsp.codelens.refresh)

  vim.api.nvim_create_autocmd('BufWritePost', {
    buffer = bufnr,
    group = java_cmds,
    desc = 'refresh codelens',
    callback = function()
      pcall(vim.lsp.codelens.refresh)
    end,
  })
end

local function enable_debugger(bufnr)
  require('jdtls').setup_dap({hotcodereplace = 'auto'})
  require('jdtls.dap').setup_dap_main_class_configs()

  local opts = {buffer = bufnr}
  vim.keymap.set('n', '<leader>df', "<cmd>lua require('jdtls').test_class()<cr>", opts)
  vim.keymap.set('n', '<leader>dn', "<cmd>lua require('jdtls').test_nearest_method()<cr>", opts)
end

local function jdtls_on_attach(client, bufnr)
  if features.debugger then
    enable_debugger(bufnr)
  end

  if features.codelens then
    enable_codelens(bufnr)
  end

  -- The following mappings are based on the suggested usage of nvim-jdtls
  -- https://github.com/mfussenegger/nvim-jdtls#usage
  
  local opts = {buffer = bufnr}
  vim.keymap.set('n', '<A-o>', "<cmd>lua require('jdtls').organize_imports()<cr>", opts)
  vim.keymap.set('n', 'crv', "<cmd>lua require('jdtls').extract_variable()<cr>", opts)
  vim.keymap.set('x', 'crv', "<esc><cmd>lua require('jdtls').extract_variable(true)<cr>", opts)
  vim.keymap.set('n', 'crc', "<cmd>lua require('jdtls').extract_constant()<cr>", opts)
  vim.keymap.set('x', 'crc', "<esc><cmd>lua require('jdtls').extract_constant(true)<cr>", opts)
  vim.keymap.set('x', 'crm', "<esc><Cmd>lua require('jdtls').extract_method(true)<cr>", opts)
end

local function jdtls_setup(event)
  local jdtls = require('jdtls')

  local path = get_jdtls_paths()
  local data_dir = path.data_dir .. '/' ..  vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

  if cache_vars.capabilities == nil then
    jdtls.extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

    local ok_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
    cache_vars.capabilities = vim.tbl_deep_extend(
      'force',
      vim.lsp.protocol.make_client_capabilities(),
      ok_cmp and cmp_lsp.default_capabilities() or {}
    )
  end

  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  local cmd = {
    -- 💀
    'java',

    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-javaagent:' .. path.java_agent,
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    
    -- 💀
    '-jar',
    path.launcher_jar,

    -- 💀
    '-configuration',
    path.platform_config,

    -- 💀
    '-data',
    data_dir,
  }

  local lsp_settings = {
    java = {
      -- jdt = {
      --   ls = {
      --     vmargs = "-XX:+UseParallelGC -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Dsun.zip.disableMemoryMapping=true -Xmx1G -Xms100m"
      --   }
      -- },
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = 'interactive',
        runtimes = path.runtimes,
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      -- inlayHints = {
      --   parameterNames = {
      --     enabled = 'all' -- literals, all, none
      --   }
      -- },
      format = {
        enabled = true,
        -- settings = {
        --   profile = 'asdf'
        -- },
      }
    },
    signatureHelp = {
      enabled = true,
    },
    completion = {
      favoriteStaticMembers = {
        'org.hamcrest.MatcherAssert.assertThat',
        'org.hamcrest.Matchers.*',
        'org.hamcrest.CoreMatchers.*',
        'org.junit.jupiter.api.Assertions.*',
        'java.util.Objects.requireNonNull',
        'java.util.Objects.requireNonNullElse',
        'org.mockito.Mockito.*',
      },
    },
    contentProvider = {
      preferred = 'fernflower',
    },
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      }
    },
    codeGeneration = {
      toString = {
        template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
      },
      useBlocks = true,
    },
  }

  -- This starts a new client & server,
  -- or attaches to an existing client & server depending on the `root_dir`.
  jdtls.start_or_attach({
    cmd = cmd,
    settings = lsp_settings,
    on_attach = jdtls_on_attach,
    capabilities = cache_vars.capabilities,
    root_dir = jdtls.setup.find_root(root_files),
    flags = {
      allow_incremental_sync = true,
    },
    init_options = {
      bundles = path.bundles,
    },
  })
end

vim.api.nvim_create_autocmd('FileType', {
  group = java_cmds,
  pattern = {'java'},
  desc = 'Setup jdtls',
  callback = jdtls_setup,
})
```

If you don't use `mason.nvim` you'll have to delete every reference to `require('mason-registry')` and replace it with a hardcoded value. For example the `jdtls` path, you'll have to find these lines:

```lua
local jdtls_install = require('mason-registry')
  .get_package('jdtls')
  :get_install_path()
```

Then use a string with the path to the folder where you installed `jdtls`.

```lua
local jdtls_install = '/path/to/my/jdtls'
```

## What's next?

Setup a debugger, probably. You'll want to install the plugins [nvim-dap](https://github.com/mfussenegger/nvim-dap) and [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui). Install `java-debug-adapter` and `java-test`. Then enable the debugger setup function in `jdtls.lua`, search for the variable `features` and set `debugger` to `true`.

To learn about nvim-dap and nvim-dap-ui watch this video [Debugging In Neovim (ft TJ DeVries and BashBunni)](https://www.youtube.com/watch?v=0moS8UHupGc). Sadly is not about java, but it should teach you the basics of nvim-dap and how to use it.

