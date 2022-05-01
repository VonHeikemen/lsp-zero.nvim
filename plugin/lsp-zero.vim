function! s:installed_servers(...) abort
  return join(sort(luaeval("require'nvim-lsp-installer.servers'.get_installed_server_names()")), "\n")
endfunction

command! -nargs=* -bang -complete=custom,s:installed_servers LspZeroSetupServers lua require('lsp-zero').use({<f-args>}, {root_dir = '<bang>' == '!'}, true)

