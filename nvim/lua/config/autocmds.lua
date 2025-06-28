---@diagnostic disable: undefined-global

local function augroup(name)
    return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
            return
        end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "PlenaryTestPopup",
        "help",
        "lspinfo",
        "man",
        "notify",
        "qf",
        "query",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "checkhealth",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = augroup("auto_create_dir"),
    callback = function(event)
        if event.match:match("^%w%w+://") then
            return
        end
        local file = vim.loop.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- Language-specific settings
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("language_settings"),
    pattern = { "go" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = false
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("rust_settings"),
    pattern = { "rust" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("zig_settings"),
    pattern = { "zig" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("c_cpp_settings"),
    pattern = { "c", "cpp" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})

-- Health check on startup (only check lazy, let plugins load naturally)
vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup("startup_health"),
    callback = function()
        vim.defer_fn(function()
            -- Only check if lazy.nvim is available (plugins load on-demand)
            if not pcall(require, "lazy") then
                vim.notify("Critical: lazy.nvim not available", vim.log.levels.ERROR)
            end
            -- Note: Other plugins load on-demand, so checking them here is premature
        end, 1000)
    end,
})

-- Format on save for specific file types
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup("format_on_save"),
    pattern = { "*.lua", "*.go", "*.rs", "*.zig", "*.ts", "*.tsx", "*.js", "*.jsx", "*.c", "*.cpp", "*.h", "*.hpp" },
    callback = function()
        local ok, conform = pcall(require, "conform")
        if ok then
            conform.format({ bufnr = vim.api.nvim_get_current_buf() })
        end
    end,
})

-- Disable autoformat for files in certain directories
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup("disable_autoformat"),
    pattern = { "*/node_modules/*", "*/vendor/*", "*/.git/*" },
    callback = function()
        vim.b.autoformat = false
    end,
})

-- Enable inlay hints for supported languages and setup LSP Telescope keymaps
vim.api.nvim_create_autocmd({ "LspAttach" }, {
    group = augroup("lsp_inlay_hints"),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf
        
        -- Enable inlay hints if supported
        if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
        
        -- Setup LSP Telescope keymaps after LSP attaches
        vim.keymap.set("n", "<leader>ss", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", 
            { buffer = bufnr, desc = "Search Workspace Symbols" })
        vim.keymap.set("n", "<leader>sS", "<cmd>Telescope lsp_document_symbols<cr>", 
            { buffer = bufnr, desc = "Search Document Symbols" })
        vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", 
            { buffer = bufnr, desc = "Go to Definition" })
        vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", 
            { buffer = bufnr, desc = "Go to References" })
        vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>", 
            { buffer = bufnr, desc = "Go to Implementation" })
        vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<cr>", 
            { buffer = bufnr, desc = "Go to Type Definition" })
    end,
})

-- Show line diagnostics automatically in hover window
vim.api.nvim_create_autocmd("CursorHold", {
    group = augroup("show_diagnostics"),
    callback = function()
        vim.diagnostic.open_float(nil, {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = "rounded",
            source = "always",
            prefix = " ",
            scope = "cursor",
        })
    end,
})

-- Update imports on save for specific languages
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup("update_imports"),
    pattern = { "*.go" },
    callback = function()
        local params = vim.lsp.util.make_range_params()
        params.context = { only = { "source.organizeImports" } }
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
        for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                    vim.lsp.util.apply_workspace_edit(r.edit, enc)
                end
            end
        end
    end,
})

-- Auto-save when leaving insert mode or text changes
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    group = augroup("auto_save"),
    pattern = "*",
    callback = function()
        if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
            vim.cmd("silent! update")
        end
    end,
})

-- Disable auto-save for certain file types
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("disable_auto_save"),
    pattern = { "oil" },
    callback = function()
        vim.b.auto_save = false
    end,
})
