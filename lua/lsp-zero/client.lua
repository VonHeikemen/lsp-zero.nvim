---@class lsp_zero.config.ClientConfig
---@inlinedoc
---
---command string or list treated like jobstart(). The command must launch the language server process.
---@field cmd? table |string|fun(dispatchers: table):table
---
---Directory to launch the `cmd` process. Not related to `root_dir`.
---@field cmd_cwd? string
---
---Environment flags to pass to the LSP on spawn.
---@field cmd_env? table<string, string>
---
---Daemonize the server process so that it runs in a separate process group from Nvim.
---@field detached? boolean
---
---List of workspace folders passed to the language server.
---@field workspace_folders? {uri: string, name: string}[]
---
---Map overriding the default capabilities passed to the language server on initialization.
---@field capabilities? table<string, any>
---
---Map of language server method names to |lsp-handler|
---@field handlers? table<string, lsp_zero.api.LspHandler>
---
---Map with language server specific settings. Keys are case-sensitive.
---@field settings? table
---
---Table that maps string of clientside commands to user-defined functions.
---@field commands? table<string,fun(command: lsp.Command, ctx: table)>
---
---Values to pass in the initialization request as `initializationOptions`.
---@field init_options? table
---
---Name in log messages. Defaults to client id.
---@field name? string
---
---language ID as string. Defaults to the filetype.
---@field get_language_id? fun(bufnr: integer, filetype: string): string
---
---The encoding that the LSP server expects. Client does not verify this is correct.
---@field offset_encoding? 'utf-8'|'utf-16'|'utf-32'
---
---Callback invoked when the client operation throws an error.
---@field on_error? fun(code: integer, err: string)
---
---Callback invoked before the LSP "initialize" phase.
---@field before_init? fun(params: table, config: lsp_zero.config.ClientConfig)
---
---Callback invoked after LSP "initialize" phase.
---@field on_init? fun(client: lsp_zero.api.Client, results: table)
---
---Callback invoked on client exit.
---@field on_exit? fun(code: integer, signal: integer, client_id: integer)
---
---Callback invoked when client attaches to a buffer.
---@field on_attach? fun(client: lsp_zero.api.Client, bufnr: integer)
---
---Passed directly to the language server in the initialize request.
---@field trace? "off" | "messages" | "verbose"
---
---A table with flags for the client.
---@field flags? {allow_incremental_sync?: boolean, debounce_text_changes?: integer, exit_timeout?: boolean|integer}
---
---Directory where the LSP server will base its workspaceFolders, rootUri, and rootPath on initialization.
---@field root_dir? string

---@class lsp_zero.api.ClientOpts: lsp_zero.config.ClientConfig
---@inlinedoc
---
---Set of filetypes for which to attempt to resolve {root_dir}.
---@field filetypes? string[]
---
---Callback invoked to determine the LSP server workspaceFolders, rootUri, and rootPath.
---@field root_dir? fun(): string

---@class lsp_zero.api.Client
---@inlinedoc
---
---Sends a request to the server.
---@field request fun(method: string, params: table, handler?: lsp_zero.api.LspHandler, bufnr: integer): boolean, integer|nil
---
---Sends a request to the server and synchronously waits for the response.
---@field request_sync fun(method: string, params: table, timeout_ms: integer, bufnr: integer): {err: lsp.ResponseError|nil, result:any}|nil, string|nil
---
---Sends a notification to an LSP server. Returns: a boolean to indicate if the notification was successful.
---@field notify fun(method: string, params: table): boolean
---
---Cancels a request with a given request id.
---@field cancel_request fun(id: integer): boolean
---
---Stops a client, optionally with force.
---@field stop fun(force?: boolean): boolean|nil
---
---Checks whether a client is stopped.
---@field is_stopped fun(): boolean
---
---Checks if a client supports a given method.
---@field supports_method fun(method: string): boolean
---
---The id allocated to the client
---@field id integer
---
---This is used for logs and messages. If not specified during creation defaults to client id.
---@field name string
---
---RPC client object, for low level interaction with the client. See :help vim.lsp.rpc.start().
---@field rpc lsp_zero.api.RpcPublicClient
---
---The encoding used for communicating with the server.
---@field offset_encoding string
---
---The handlers used by the client as described in the help page, see :help lsp-handler
---@field handlers table
---
---The current pending requests in flight to the server.
---@field requests table
---
---Copy of the table that was passed to the function vim.lsp.start_client()
---@field config lsp_zero.config.ClientConfig
---
---Response from the server on initialize describing the server's capabilities.
---@field server_capabilities table

---@class lsp_zero.api.RpcPublicClient
---@field request fun(method: string, params: table?, callback: fun(err: lsp.ResponseError|nil, result: any), notify_reply_callback: fun(integer)|nil):boolean,integer? see |vim.lsp.rpc.request()|
---@field notify fun(method: string, params: any):boolean see |vim.lsp.rpc.notify()|
---@field is_closing fun(): boolean
---@field terminate fun()

---@alias lsp_zero.api.LspHandler fun(err: lsp.ResponseError?, result: any, context: table, config?: table)

local M = {}

local lsp_cmds = vim.api.nvim_create_augroup('lsp_zero_start_client', {clear = true})

---@param opts lsp_zero.api.ClientOpts
function M.setup(opts)
  if opts.filetypes == nil then
    return
  end

  local setup_id
  local desc = 'Attach LSP server'
  local defaults = {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    on_exit = vim.schedule_wrap(function()
      if setup_id then
        pcall(vim.api.nvim_del_autocmd, setup_id)
      end
    end)
  }

  local config = vim.tbl_deep_extend('force', defaults, opts)

  local get_root = opts.root_dir
  if type(get_root) == 'function' then
    config.root_dir = nil
  end

  if opts.on_exit then
    local cb = opts.on_exit
    local cleanup = defaults.on_exit
    config.on_exit = function(...)
      cleanup()
      ---@diagnostic disable-next-line: need-check-nil
      cb(...)
    end
  end

  if config.name then
    desc = string.format('Attach LSP: %s', config.name)
  end

  local start_client = function()
    if get_root then
      config.root_dir = get_root()
    end

    if config.root_dir then
      vim.lsp.start(config)
    end
  end

  setup_id = vim.api.nvim_create_autocmd('FileType', {
    group = lsp_cmds,
    pattern = config.filetypes,
    desc = desc,
    callback = start_client
  })
end

return M

