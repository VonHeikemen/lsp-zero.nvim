command! -nargs=* -bang LspZeroSetupServers lua require('lsp-zero').use({<f-args>}, {root_dir = '<bang>' == '!'}, true)
