command! -nargs=* -bang LspZeroSetupServers lua require('lsp-zero').setup_servers({root_dir = '<bang>' == '!', <f-args>})
