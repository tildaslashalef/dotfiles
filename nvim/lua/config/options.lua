---@diagnostic disable: undefined-global


local opt = vim.opt

-- General
opt.mouse = "a"                -- Enable mouse mode
opt.clipboard = "unnamedplus"  -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2           -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true             -- Confirm to save changes before exiting modified buffer
opt.cursorline = true          -- Enable highlighting of the current line
opt.expandtab = true           -- Use spaces instead of tabs
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true              -- Ignore case
opt.inccommand = "nosplit"         -- preview incremental substitute
opt.laststatus = 3                 -- global statusline
opt.list = true                    -- Show some invisible characters (tabs...
opt.number = true                  -- Print line number
opt.pumblend = 10                  -- Popup blend
opt.pumheight = 10                 -- Maximum number of entries in a popup
opt.relativenumber = true          -- Relative line numbers
opt.scrolloff = 4                  -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true              -- Round indent
opt.shiftwidth = 2                 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false               -- Dont show mode since we have a statusline
opt.sidescrolloff = 8              -- Columns of context
opt.signcolumn = "yes"             -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true               -- Don't ignore case with capitals
opt.smartindent = true             -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true              -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true              -- Put new windows right of current
opt.tabstop = 2                    -- Number of spaces tabs count for
opt.termguicolors = true           -- True color support
opt.timeoutlen = 300               -- Lower than default (1000) to quickly trigger which-key
opt.undofile = true                -- Enable undofile
opt.undolevels = 10000
opt.updatetime = 200               -- Save swap file and trigger CursorHold
opt.virtualedit = "block"          -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5                -- Minimum window width
opt.wrap = false                   -- Disable line wrap
opt.fillchars = {
    foldopen = "󰅀",
    foldclose = "󰅂",
    fold = " ",
    foldsep = " ",
    diff = "╱",
    eob = " ",
}

-- Folding
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Performance optimizations
opt.lazyredraw = false -- Don't redraw while executing macros (good performance config)
opt.ttyfast = true     -- Faster redrawing
opt.synmaxcol = 240    -- Max column for syntax highlight

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- Global variables for optional modules
vim.g.enable_debugging_module = false -- DAP debugging
vim.g.enable_testing_module = false   -- Test runners and coverage
vim.g.enable_docs_module = false      -- Note-taking and documentation

-- Disable builtin plugins we don't need
local disabled_built_ins = {
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit",
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end

-- Health check commands using utilities
local health = require("utils.health")

-- Main health check command
vim.api.nvim_create_user_command("ConfigHealth", function()
    health.report_health()
end, { desc = "Check configuration health" })

-- Export health report
vim.api.nvim_create_user_command("ConfigHealthExport", function()
    health.export_health()
end, { desc = "Export health report to JSON" })

-- Quick health checks for specific components
vim.api.nvim_create_user_command("ConfigHealthQuick", function(opts)
    local component = opts.args
    if component == "" then
        vim.notify("Usage: :ConfigHealthQuick <component>", vim.log.levels.INFO)
        vim.notify("Available: core, lang, lsp, debug, test, plugins, neovim", vim.log.levels.INFO)
        return
    end
    
    local result = health.quick_check(component)
    if result then
        vim.notify("=== " .. component:upper() .. " Health ===", vim.log.levels.INFO)
        for key, value in pairs(result) do
            local status = type(value) == "boolean" and (value and "✓ OK" or "✗ FAILED") or tostring(value)
            vim.notify(string.format("  %s: %s", key, status), vim.log.levels.INFO)
        end
    end
end, { 
    desc = "Quick health check for specific component",
    nargs = 1,
    complete = function()
        return { "core", "lang", "lsp", "debug", "test", "plugins", "neovim" }
    end
})

-- Installation suggestions
vim.api.nvim_create_user_command("ConfigSuggest", function()
    health.suggest_installations()
end, { desc = "Suggest installations for missing tools" })

-- Module-specific health checks (only created if modules are enabled)
if vim.g.enable_debugging_module then
    vim.api.nvim_create_user_command("DebugHealth", function()
        local debug_health = health.check_debug_module()
        if not debug_health.enabled then
            vim.notify("Debug module is not enabled", vim.log.levels.WARN)
            return
        end
        
        vim.notify("=== Debug Module Health ===", vim.log.levels.INFO)
        vim.notify("  DAP loaded: " .. (debug_health.dap_loaded and "✓ OK" or "✗ FAILED"), 
                  debug_health.dap_loaded and vim.log.levels.INFO or vim.log.levels.ERROR)
        
        if debug_health.dap_loaded then
            vim.notify("  Adapters: " .. (debug_health.adapter_count or 0) .. " configured", vim.log.levels.INFO)
            vim.notify("  Configurations: " .. (debug_health.config_count or 0) .. " available", vim.log.levels.INFO)
            
            if debug_health.dap_adapters and #debug_health.dap_adapters > 0 then
                vim.notify("  Available adapters: " .. table.concat(debug_health.dap_adapters, ", "), vim.log.levels.INFO)
            end
        end
        
        -- Check debug tools
        local tools = { "dlv", "gdb", "lldb" }
        for _, tool in ipairs(tools) do
            local status = debug_health[tool]
            vim.notify("  " .. tool .. ": " .. (status and "✓ OK" or "✗ MISSING"), 
                      status and vim.log.levels.INFO or vim.log.levels.WARN)
        end
    end, { desc = "Check debugging module health" })
end

if vim.g.enable_testing_module then
    vim.api.nvim_create_user_command("TestHealth", function()
        local test_health = health.check_test_module()
        if not test_health.enabled then
            vim.notify("Test module is not enabled", vim.log.levels.WARN)
            return
        end
        
        vim.notify("=== Test Module Health ===", vim.log.levels.INFO)
        vim.notify("  Neotest loaded: " .. (test_health.neotest_loaded and "✓ OK" or "✗ FAILED"), 
                  test_health.neotest_loaded and vim.log.levels.INFO or vim.log.levels.ERROR)
        
        if test_health.neotest_loaded then
            vim.notify("  Adapters: " .. (test_health.adapter_count or 0) .. " configured", vim.log.levels.INFO)
        end
        
        -- Check test tools
        local tools = { "go", "cargo", "zig", "make", "cmake" }
        for _, tool in ipairs(tools) do
            local status = test_health[tool]
            if status ~= nil then
                vim.notify("  " .. tool .. ": " .. (status and "✓ OK" or "✗ MISSING"), 
                          status and vim.log.levels.INFO or vim.log.levels.WARN)
            end
        end
    end, { desc = "Check testing module health" })
end
