---@diagnostic disable: undefined-global

-- Health Check Utility Module
-- Comprehensive system and module health verification
-- Usage: require("utils.health").check_all() or specific check functions

local M = {}

-- Core system tools required for basic functionality
local CORE_TOOLS = { "git", "rg", "fd", "node" }

-- Language tools for the 6 supported languages
local LANGUAGE_TOOLS = { "go", "cargo", "zig", "clang", "gcc", "lua" }

-- LSP servers that should be available
local LSP_SERVERS = { "gopls", "rust-analyzer", "zls", "clangd", "typescript-language-server", "lua-language-server" }

-- Debug tools (when debugging module is enabled)
local DEBUG_TOOLS = { "dlv", "gdb", "lldb" }

-- Test tools (when testing module is enabled)
local TEST_TOOLS = { "go", "cargo", "zig", "make", "cmake" }

-- Utility function to check if a command exists
local function command_exists(cmd)
    return vim.fn.executable(cmd) == 1
end

-- Check core system tools
function M.check_core_tools()
    local results = {}
    for _, tool in ipairs(CORE_TOOLS) do
        results[tool] = command_exists(tool)
    end
    return results
end

-- Check language-specific tools
function M.check_language_tools()
    local results = {}
    for _, tool in ipairs(LANGUAGE_TOOLS) do
        results[tool] = command_exists(tool)
    end
    return results
end

-- Check LSP servers
function M.check_lsp_servers()
    local results = {}
    for _, server in ipairs(LSP_SERVERS) do
        results[server] = command_exists(server)
    end
    return results
end

-- Check debugging module health
function M.check_debug_module()
    if not vim.g.enable_debugging_module then
        return { enabled = false }
    end
    
    local results = { enabled = true }
    
    -- Check DAP status
    local dap_ok, dap = pcall(require, "dap")
    results.dap_loaded = dap_ok
    
    if dap_ok then
        results.dap_adapters = vim.tbl_keys(dap.adapters)
        results.dap_configurations = vim.tbl_keys(dap.configurations)
        results.adapter_count = #results.dap_adapters
        results.config_count = #results.dap_configurations
    end
    
    -- Check debug tools
    for _, tool in ipairs(DEBUG_TOOLS) do
        results[tool] = command_exists(tool)
    end
    
    return results
end

-- Check testing module health
function M.check_test_module()
    if not vim.g.enable_testing_module then
        return { enabled = false }
    end
    
    local results = { enabled = true }
    
    -- Check neotest status
    local neotest_ok, neotest = pcall(require, "neotest")
    results.neotest_loaded = neotest_ok
    
    if neotest_ok and neotest.config then
        results.adapters = neotest.config.adapters or {}
        results.adapter_count = #results.adapters
    end
    
    -- Check test tools
    for _, tool in ipairs(TEST_TOOLS) do
        results[tool] = command_exists(tool)
    end
    
    return results
end

-- Check plugin manager health
function M.check_plugin_health()
    local results = {}
    
    -- Check Lazy.nvim
    local lazy_ok, lazy = pcall(require, "lazy")
    results.lazy_loaded = lazy_ok
    
    if lazy_ok then
        local stats = lazy.stats()
        results.plugin_count = stats.count
        results.plugins_loaded = stats.loaded
        results.startup_time = stats.startuptime
    end
    
    -- Check Mason
    local mason_ok, mason = pcall(require, "mason")
    results.mason_loaded = mason_ok
    
    if mason_ok then
        local registry_ok, registry = pcall(require, "mason-registry")
        if registry_ok then
            results.mason_packages = #registry.get_installed_packages()
        end
    end
    
    return results
end

-- Check Neovim configuration health
function M.check_neovim_health()
    local results = {}
    
    -- Basic Neovim info
    results.version = vim.version()
    results.version_string = string.format("%d.%d.%d", results.version.major, results.version.minor, results.version.patch)
    results.has_nvim_010 = vim.fn.has("nvim-0.10") == 1
    
    -- Configuration paths
    results.config_path = vim.fn.stdpath("config")
    results.data_path = vim.fn.stdpath("data")
    results.cache_path = vim.fn.stdpath("cache")
    
    -- Leader keys
    results.leader = vim.g.mapleader
    results.localleader = vim.g.maplocalleader
    
    -- Module status
    results.debug_module_enabled = vim.g.enable_debugging_module or false
    results.testing_module_enabled = vim.g.enable_testing_module or false
    results.docs_module_enabled = vim.g.enable_docs_module or false
    
    return results
end

-- Comprehensive health check
function M.check_all()
    return {
        neovim = M.check_neovim_health(),
        core_tools = M.check_core_tools(),
        language_tools = M.check_language_tools(),
        lsp_servers = M.check_lsp_servers(),
        plugins = M.check_plugin_health(),
        debug_module = M.check_debug_module(),
        test_module = M.check_test_module(),
        timestamp = os.date("%Y-%m-%d %H:%M:%S")
    }
end

-- Report health status with notifications
function M.report_health(health_data)
    health_data = health_data or M.check_all()
    
    vim.notify("=== Configuration Health Check ===", vim.log.levels.INFO)
    
    -- Neovim info
    local nv = health_data.neovim
    vim.notify(string.format("Neovim: %s", nv.version_string), vim.log.levels.INFO)
    vim.notify(string.format("Leader: '%s' | LocalLeader: '%s'", nv.leader, nv.localleader), vim.log.levels.INFO)
    
    -- Core tools
    vim.notify("Core Tools:", vim.log.levels.INFO)
    for tool, status in pairs(health_data.core_tools) do
        local level = status and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify(string.format("  %s: %s", tool, status and "✓ OK" or "✗ MISSING"), level)
    end
    
    -- Language tools
    vim.notify("Language Tools:", vim.log.levels.INFO)
    for tool, status in pairs(health_data.language_tools) do
        local level = status and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify(string.format("  %s: %s", tool, status and "✓ OK" or "✗ MISSING"), level)
    end
    
    -- LSP servers
    vim.notify("LSP Servers:", vim.log.levels.INFO)
    for server, status in pairs(health_data.lsp_servers) do
        local level = status and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify(string.format("  %s: %s", server, status and "✓ OK" or "✗ MISSING"), level)
    end
    
    -- Plugin health
    local plugins = health_data.plugins
    vim.notify("Plugin Manager:", vim.log.levels.INFO)
    vim.notify(string.format("  Lazy.nvim: %s", plugins.lazy_loaded and "✓ OK" or "✗ FAILED"), 
              plugins.lazy_loaded and vim.log.levels.INFO or vim.log.levels.ERROR)
    if plugins.lazy_loaded then
        vim.notify(string.format("  Plugins: %d total, %d loaded", plugins.plugin_count, plugins.plugins_loaded), vim.log.levels.INFO)
        vim.notify(string.format("  Startup: %.2fms", plugins.startup_time or 0), vim.log.levels.INFO)
    end
    
    -- Optional modules
    local debug = health_data.debug_module
    if debug.enabled then
        vim.notify("Debug Module:", vim.log.levels.INFO)
        vim.notify(string.format("  DAP: %s", debug.dap_loaded and "✓ OK" or "✗ FAILED"), 
                  debug.dap_loaded and vim.log.levels.INFO or vim.log.levels.ERROR)
        if debug.dap_loaded then
            vim.notify(string.format("  Adapters: %d configured", debug.adapter_count or 0), vim.log.levels.INFO)
            vim.notify(string.format("  Configurations: %d available", debug.config_count or 0), vim.log.levels.INFO)
        end
        for _, tool in ipairs(DEBUG_TOOLS) do
            local status = debug[tool]
            vim.notify(string.format("  %s: %s", tool, status and "✓ OK" or "✗ MISSING"), 
                      status and vim.log.levels.INFO or vim.log.levels.WARN)
        end
    end
    
    local test = health_data.test_module
    if test.enabled then
        vim.notify("Test Module:", vim.log.levels.INFO)
        vim.notify(string.format("  Neotest: %s", test.neotest_loaded and "✓ OK" or "✗ FAILED"), 
                  test.neotest_loaded and vim.log.levels.INFO or vim.log.levels.ERROR)
        if test.neotest_loaded then
            vim.notify(string.format("  Adapters: %d configured", test.adapter_count or 0), vim.log.levels.INFO)
        end
    end
    
    vim.notify("=== Health Check Complete ===", vim.log.levels.INFO)
end

-- Quick health check for specific component
function M.quick_check(component)
    local checks = {
        core = M.check_core_tools,
        lang = M.check_language_tools,
        lsp = M.check_lsp_servers,
        debug = M.check_debug_module,
        test = M.check_test_module,
        plugins = M.check_plugin_health,
        neovim = M.check_neovim_health
    }
    
    local check_fn = checks[component]
    if not check_fn then
        vim.notify("Unknown component: " .. component, vim.log.levels.ERROR)
        vim.notify("Available: " .. table.concat(vim.tbl_keys(checks), ", "), vim.log.levels.INFO)
        return
    end
    
    return check_fn()
end

-- Export health data to file
function M.export_health(filepath)
    filepath = filepath or vim.fn.stdpath("data") .. "/health_report.json"
    local health_data = M.check_all()
    
    local json_ok, json = pcall(vim.fn.json_encode, health_data)
    if not json_ok then
        vim.notify("Failed to encode health data to JSON", vim.log.levels.ERROR)
        return false
    end
    
    local file = io.open(filepath, "w")
    if not file then
        vim.notify("Failed to open file for writing: " .. filepath, vim.log.levels.ERROR)
        return false
    end
    
    file:write(json)
    file:close()
    
    vim.notify("Health report exported to: " .. filepath, vim.log.levels.INFO)
    return true
end

-- Get missing tools summary
function M.get_missing_tools()
    local health_data = M.check_all()
    local missing = {}
    
    -- Core tools
    for tool, status in pairs(health_data.core_tools) do
        if not status then
            table.insert(missing, { type = "core", name = tool })
        end
    end
    
    -- Language tools
    for tool, status in pairs(health_data.language_tools) do
        if not status then
            table.insert(missing, { type = "language", name = tool })
        end
    end
    
    -- LSP servers
    for server, status in pairs(health_data.lsp_servers) do
        if not status then
            table.insert(missing, { type = "lsp", name = server })
        end
    end
    
    return missing
end

-- Installation suggestions for missing tools
function M.suggest_installations()
    local missing = M.get_missing_tools()
    if #missing == 0 then
        vim.notify("All tools are installed! ✓", vim.log.levels.INFO)
        return
    end
    
    vim.notify("=== Installation Suggestions ===", vim.log.levels.INFO)
    
    local suggestions = {
        git = "Install Git: https://git-scm.com/downloads",
        rg = "Install ripgrep: cargo install ripgrep (or system package manager)",
        fd = "Install fd: cargo install fd-find (or system package manager)",
        node = "Install Node.js: https://nodejs.org/",
        go = "Install Go: https://golang.org/dl/",
        cargo = "Install Rust: https://rustup.rs/",
        zig = "Install Zig: https://ziglang.org/download/",
        clang = "Install Clang: system package manager (build-essential, xcode-tools)",
        gcc = "Install GCC: system package manager (build-essential, xcode-tools)",
        lua = "Usually comes with Neovim, check Neovim installation",
        gopls = "Install via :Mason or 'go install golang.org/x/tools/gopls@latest'",
        ["rust-analyzer"] = "Install via :Mason or rustup component add rust-analyzer",
        zls = "Install via :Mason or from https://github.com/zigtools/zls",
        clangd = "Install via :Mason or system package manager",
        ["typescript-language-server"] = "Install via :Mason or 'npm install -g typescript-language-server'",
        ["lua-language-server"] = "Install via :Mason",
        dlv = "Install Delve: go install github.com/go-delve/delve/cmd/dlv@latest",
        gdb = "Install GDB: system package manager",
        lldb = "Install LLDB: system package manager (lldb, llvm)",
        make = "Install Make: system package manager (build-essential, xcode-tools)",
        cmake = "Install CMake: https://cmake.org/download/ or system package manager"
    }
    
    for _, item in ipairs(missing) do
        local suggestion = suggestions[item.name]
        if suggestion then
            vim.notify(string.format("%s (%s): %s", item.name, item.type, suggestion), vim.log.levels.WARN)
        else
            vim.notify(string.format("%s (%s): Install via system package manager", item.name, item.type), vim.log.levels.WARN)
        end
    end
    
    vim.notify("=== Installation Help Complete ===", vim.log.levels.INFO)
end

return M