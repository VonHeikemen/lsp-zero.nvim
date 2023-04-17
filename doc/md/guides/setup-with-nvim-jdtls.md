# Setup with nvim-jdtls

Here we will focus on getting a working configuration using [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls). The code in this guide will based of [starter.lvim/ftplugin/java.lua](https://github.com/LunarVim/starter.lvim/blob/a36820712ec282b201be431e7eb47a4bf32888c8/ftplugin/java.lua) and also the official documentation of nvim-jdtls.

## Requirements

* A working environment with Java 17 or greater
* Python 3.9 or greater
* A working configuration for Neovim (If you don't have one, follow this [step by step tutorial](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/tutorial.md))

The code on this guide assumes you will be using [mason.nvim](https://github.com/williamboman/mason.nvim) to install the following packages:

* [jdtls](https://github.com/eclipse/eclipse.jdt.ls)
* [java-test](https://github.com/microsoft/vscode-java-test) (optional)
* [java-debug-adapter](https://github.com/microsoft/java-debug) (optional)

Using `mason.nvim` to install these packages is optional, you can use the method you want. You'll have to modify a few paths though. I will keep all the paths in a function called `get_jdtls_paths` so is easier for you to change any path.

You will also need these Neovim plugins:

* [lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim)
* [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)
* [nvim-dap](https://github.com/mfussenegger/nvim-dap) (optional)
* [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) (optional)

The code to setup the debugger will be disabled. To enable it just "uncomment" the call to the function `enable_debugger()`.

## Before we start

Some context... the configuration for this guide was tested in Debian 11. I installed java using [sdkman](https://sdkman.io/). And I installed [jdtls](https://github.com/eclipse/eclipse.jdt.ls) using [mason.nvim](https://github.com/williamboman/mason.nvim). I'm not a java developer, I can't tell you this is the best setup for Java development, I can only tell you it worked on my machine.

You can still follow this guide if you are using another operating system.

## The first step

We need to tell lsp-zero to ignore the LSP server `jdtls`. We want the plugin `nvim-jdtls` to have full control of the configuration for the server.

We will use the function [.skip_server_setup()](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#skip_server_setuplist) to make sure lsp-zero doesn't initialize jdtls.

```lua
local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

lsp.skip_server_setup({'jdtls'})

lsp.setup()
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

local root_files = {
  '.git',
  'mvnw',
  'gradlew',
  'pom.xml',
  'build.gradle',
}

local jdtls_capabilities = {}

local jdtls_paths = false

local function get_jdtls_paths()
  if jdtls_paths then
    return jdtls_paths
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

  local java_test_path = require('mason-registry')
    .get_package('java-test')
    :get_install_path()

  path.java_test_bundle = vim.split(
    vim.fn.glob(java_test_path .. '/extension/server/*.jar'),
    '\n'
  )

  local java_debug_path = require('mason-registry')
    .get_package('java-debug-adapter')
    :get_install_path()

  path.java_debug_bundle = vim.split(
    vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar'),
    '\n'
  )

  path.runtimes = {
    -- Useful if you're starting jdtls with a Java version that's 
    -- different from the one the project uses.
    --
    -- Note: the field `name` must be a valid `ExecutionEnvironment`,
    -- you can find the list here: 
    -- https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    --
    -- This example assume you are using sdkman: https://get.sdkman.io
    -- {
    --   name = 'JavaSE-17',
    --   path = vim.fn.expand('~/.sdkman/candidates/java/17.0.6-tem'),
    -- },
    -- {
    --   name = 'JavaSE-18',
    --   path = vim.fn.expand('~/.sdkman/candidates/java/18.0.2-amzn'),
    -- },
  }

  jdtls_paths = path

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

local function enable_debugger()
  require('jdtls').setup_dap({hotcodereplace = 'auto'})
  require('jdtls.dap').setup_dap_main_class_configs()

  vim.keymap.set('n', '<leader>df', "<cmd>lua require('jdtls').test_class()<cr>", opts)
  vim.keymap.set('n', '<leader>dn', "<cmd>lua require('jdtls').test_nearest_method()<cr>", opts)
end

local function jdtls_on_attach(client, bufnr)
  -- Uncomment the line below if you have `nvim-dap`, `java-test` and `java-debug-adapter`
  -- enable_debugger()

  -- Uncomment the line below to enable codelens
  -- enable_codelens(bufnr)

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

  jdtls.extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  local path = get_jdtls_paths()
  local data_dir = path.data_dir .. '/' ..  vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

  local bundles = {}

  -- Include java-test bundle if present
  if path.java_test_bundle[1] ~= '' then
    vim.list_extend(bundles, path.java_test_bundle)
  end

  -- Include java-debug-adapter bundle if present
  if path.java_debug_bundle[1] ~= '' then
    vim.list_extend(bundles, path.java_debug_bundle)
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
        enabled = false,
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

  if vim.tbl_isempty(jdtls_capabilities) then
    jdtls_capabilities = vim.tbl_deep_extend(
      'force',
      vim.lsp.protocol.make_client_capabilities(),
      require('cmp_nvim_lsp').default_capabilities()
    )
  end

  -- This starts a new client & server,
  -- or attaches to an existing client & server depending on the `root_dir`.
  jdtls.start_or_attach({
    cmd = cmd,
    settings = lsp_settings,
    on_attach = jdtls_on_attach,
    capabilities = jdtls_capabilities,
    root_dir = jdtls.setup.find_root(root_files),
    flags = {
      allow_incremental_sync = true,
    },
    init_options = {
      bundles = bundles,
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

Setup a debugger, probably. You'll want to install the plugins [nvim-dap](https://github.com/mfussenegger/nvim-dap) and [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui). Then install `java-debug-adapter` and `java-test`. The code to setup the debugger is disabled, you'll need to "uncomment" the call to the function `enable_debugger()` in order to use it.

I didn't test the debugger so I can't tell you how it works, but I believe it should work.

To learn about nvim-dap and nvim-dap-ui watch this video [Debugging In Neovim (ft TJ DeVries and BashBunni)](https://www.youtube.com/watch?v=0moS8UHupGc). Sadly is not about java, but it should teach you the basics of nvim-dap and how to use it.

