local ok, luasnip = pcall(require, 'luasnip')
if not ok then return end

luasnip.config.set_config({
  region_check_events = 'InsertEnter',
  delete_check_events = 'InsertLeave'
})

require('luasnip.loaders.from_vscode').lazy_load()
