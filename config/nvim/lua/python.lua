-- Python setup: native LSP (basedpyright + ruff), treesitter highlighting,
-- ruff format-on-save, and debugging via nvim-dap + debugpy.
-- Servers/tools installed with `uv tool install basedpyright ruff debugpy`.
-- coc stays in charge of every other filetype; it's disabled for python below.

----------------------------------------------------------------------------
-- LSP
----------------------------------------------------------------------------
vim.lsp.config('basedpyright', {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' },
  settings = {
    basedpyright = {
      -- default "recommended" is very strict/noisy; "standard" matches pyright
      analysis = { typeCheckingMode = 'standard' },
    },
  },
})

vim.lsp.config('ruff', {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.git' },
})

vim.lsp.enable({ 'basedpyright', 'ruff' })

-- Keep coc out of python buffers so it doesn't double up with native LSP.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function(ev)
    vim.b[ev.buf].coc_enabled = 0
    vim.b[ev.buf].coc_suggest_disable = 1
    vim.b[ev.buf].coc_diagnostic_disable = 1

    -- Treesitter highlighting (parser installed via :TSInstall python).
    pcall(vim.treesitter.start, ev.buf, 'python')

    -- Debugging (nvim-dap + nvim-dap-python)
    local ok, dap = pcall(require, 'dap')
    if ok then
      local function map(lhs, rhs)
        vim.keymap.set('n', lhs, rhs, { buffer = ev.buf, silent = true })
      end
      map('<leader>b', dap.toggle_breakpoint)
      map('<F5>', dap.continue)
      map('<F10>', dap.step_over)
      map('<F11>', dap.step_into)
      map('<leader>dr', dap.repl.toggle)
    end
  end,
})

local ok_dpy, dap_python = pcall(require, 'dap-python')
if ok_dpy then
  dap_python.setup(vim.fn.expand('~/.local/share/uv/tools/debugpy/bin/python'))
end

----------------------------------------------------------------------------
-- Per-buffer LSP behavior: completion, keymaps, format on save
----------------------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    if vim.bo[ev.buf].filetype ~= 'python' then
      return
    end
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    -- basedpyright's hover is better; don't let ruff shadow it
    if client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false
    end

    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    local function map(lhs, rhs)
      vim.keymap.set('n', lhs, rhs, { buffer = ev.buf, silent = true })
    end
    -- Same keys as the coc maps in init.vim, but native.
    map('gd', vim.lsp.buf.definition)
    map('gy', vim.lsp.buf.type_definition)
    map('gi', vim.lsp.buf.implementation)
    map('gr', vim.lsp.buf.references)
    map('K', vim.lsp.buf.hover)
    map('<leader>rn', vim.lsp.buf.rename)

    -- Tab/S-Tab drive the native completion popup (the global coc <TAB> map
    -- calls coc#pum, which is inert here since coc is disabled for python).
    vim.keymap.set('i', '<Tab>', function()
      return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
    end, { buffer = ev.buf, expr = true })
    vim.keymap.set('i', '<S-Tab>', function()
      return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
    end, { buffer = ev.buf, expr = true })
  end,
})

-- ruff format on save, same spirit as the Autoformat BufWrite list in init.vim
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.py',
  callback = function(ev)
    vim.lsp.buf.format({ bufnr = ev.buf, name = 'ruff', timeout_ms = 2000 })
  end,
})
