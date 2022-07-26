function! s:installed_servers(...) abort
  return join(sort(luaeval("require'lsp-zero.installer'.fn.get_servers()")), "\n")
endfunction

command! -nargs=* -bang -complete=custom,s:installed_servers LspZeroSetupServers lua require('lsp-zero').use({<f-args>}, {root_dir = '<bang>' == '!'}, true)

