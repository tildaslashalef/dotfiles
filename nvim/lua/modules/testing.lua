---@diagnostic disable: undefined-global

-- Testing Module for Systems Programming Languages
-- Supports: Go, Rust, Zig, C/C++
-- Enable in options.lua: vim.g.enable_testing_module = true

return {
    -- Neotest: Modern test runner framework
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",

            -- Language adapters for our 4 target languages
            "nvim-neotest/neotest-go",        -- Go testing
            "rouge8/neotest-rust",            -- Rust testing
            "lawrence-laz/neotest-zig",       -- Zig testing
            "alfaix/neotest-gtest",           -- C/C++ Google Test
        },
        
        keys = {
            -- Test running
            { "<leader>tr", function() require("neotest").run.run() end,                     desc = "Test: Run nearest" },
            { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end,  desc = "Test: Run file" },
            { "<leader>tF", function() require("neotest").run.run(vim.fn.getcwd()) end,     desc = "Test: Run all" },
            { "<leader>tl", function() require("neotest").run.run_last() end,               desc = "Test: Run last" },
            
            -- Debug testing
            { "<leader>td", function() require("neotest").run.run({strategy = "dap"}) end,  desc = "Test: Debug nearest" },
            
            -- Test output and results
            { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Test: Show output" },
            { "<leader>tO", function() require("neotest").output_panel.toggle() end,        desc = "Test: Toggle output panel" },
            { "<leader>ts", function() require("neotest").summary.toggle() end,             desc = "Test: Toggle summary" },
            
            -- Test navigation
            { "[t",         function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Test: Previous failed" },
            { "]t",         function() require("neotest").jump.next({ status = "failed" }) end, desc = "Test: Next failed" },
            
            -- Test watching (auto-run on file changes)
            { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Test: Watch file" },
            { "<leader>tW", function() require("neotest").watch.toggle(vim.fn.getcwd()) end,     desc = "Test: Watch all" },
            
            -- Test stopping
            { "<leader>tS", function() require("neotest").run.stop() end,                   desc = "Test: Stop" },
        },
        
        opts = function()
            return {
                adapters = {
                    -- Go testing with go test
                    require("neotest-go")({
                        experimental = {
                            test_table = true,
                        },
                        args = { "-count=1", "-timeout=60s", "-race", "-cover" },
                    }),
                    
                    -- Rust testing with cargo test
                    require("neotest-rust")({
                        args = { "--no-capture" },
                        dap_adapter = "codelldb",
                    }),
                    
                    -- Zig testing with zig test
                    require("neotest-zig")({
                        -- Default configuration is usually sufficient
                    }),
                    
                    -- C/C++ testing with Google Test
                    require("neotest-gtest").setup({
                        -- Will look for test executables matching these patterns
                        patterns = {
                            "test_*",
                            "*_test",
                            "*_tests",
                            "tests",
                            "test",
                        },
                    }),
                },
                
                -- Discovery settings
                discovery = {
                    enabled = true,
                    concurrent = 1,
                },
                
                -- Running settings
                running = {
                    concurrent = true,
                },
                
                -- Summary window configuration
                summary = {
                    enabled = true,
                    animated = true,
                    follow = true,
                    expand_errors = true,
                    mappings = {
                        expand = { "<CR>", "<2-LeftMouse>" },
                        expand_all = "e",
                        output = "o",
                        short = "O",
                        attach = "a",
                        jumpto = "i",
                        stop = "u",
                        run = "r",
                        debug = "d",
                        mark = "m",
                        run_marked = "R",
                        debug_marked = "D",
                        clear_marked = "M",
                        target = "t",
                        clear_target = "T",
                        next_failed = "J",
                        prev_failed = "K",
                        watch = "w",
                    },
                },
                
                -- Output settings
                output = {
                    enabled = true,
                    open_on_run = "short",
                },
                
                -- Output panel settings
                output_panel = {
                    enabled = true,
                    open = "botright split | resize 15",
                },
                
                -- Quickfix integration
                quickfix = {
                    enabled = true,
                    open = false,
                },
                
                -- Status configuration
                status = {
                    enabled = true,
                    virtual_text = true,
                    signs = true,
                },
                
                -- Icons
                icons = {
                    child_indent = "│",
                    child_prefix = "├",
                    collapsed = "─",
                    expanded = "╮",
                    failed = "",
                    final_child_indent = " ",
                    final_child_prefix = "╰",
                    non_collapsible = "─",
                    passed = "",
                    running = "",
                    running_animated = { "/", "|", "\\", "-", "/", "|", "\\", "-" },
                    skipped = "",
                    unknown = "",
                    watching = "",
                },
                
                -- Floating window settings
                floating = {
                    border = "rounded",
                    max_height = 0.6,
                    max_width = 0.6,
                    options = {},
                },
                
                -- Highlights
                highlights = {
                    adapter_name = "NeotestAdapterName",
                    border = "NeotestBorder",
                    dir = "NeotestDir",
                    expand_marker = "NeotestExpandMarker",
                    failed = "NeotestFailed",
                    file = "NeotestFile",
                    focused = "NeotestFocused",
                    indent = "NeotestIndent",
                    marked = "NeotestMarked",
                    namespace = "NeotestNamespace",
                    passed = "NeotestPassed",
                    running = "NeotestRunning",
                    select_win = "NeotestWinSelect",
                    skipped = "NeotestSkipped",
                    target = "NeotestTarget",
                    test = "NeotestTest",
                    unknown = "NeotestUnknown",
                    watching = "NeotestWatching",
                },
            }
        end,
        
        config = function(_, opts)
            local neotest_ns = vim.api.nvim_create_namespace("neotest")
            vim.diagnostic.config({
                virtual_text = {
                    format = function(diagnostic)
                        local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
                        return message
                    end,
                },
            }, neotest_ns)
            
            require("neotest").setup(opts)
        end,
    },
    
    -- Coverage display
    {
        "andythigpen/nvim-coverage",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = {
            "Coverage",
            "CoverageLoad",
            "CoverageShow",
            "CoverageHide",
            "CoverageToggle",
            "CoverageClear",
        },
        keys = {
            { "<leader>tc", "<cmd>Coverage<cr>",        desc = "Test: Load coverage" },
            { "<leader>tC", "<cmd>CoverageToggle<cr>",  desc = "Test: Toggle coverage" },
        },
        opts = {
            auto_reload = true,
            auto_reload_timeout_ms = 500,
            commands = true,
            highlights = {
                covered = { fg = "#C3E88D" },   -- green
                uncovered = { fg = "#F07178" }, -- red
            },
            signs = {
                covered = { hl = "CoverageCovered", text = "▎" },
                uncovered = { hl = "CoverageUncovered", text = "▎" },
            },
            summary = {
                min_coverage = 80.0,
            },
            lang = {
                go = {
                    coverage_file = "coverage.out",
                    coverage_command = "go test -coverprofile=coverage.out ./...",
                },
                rust = {
                    coverage_file = "tarpaulin-report.xml",
                    coverage_command = "cargo tarpaulin --out xml",
                },
                c = {
                    coverage_file = "coverage.info",
                    coverage_command = "lcov --capture --directory . --output-file coverage.info",
                },
                cpp = {
                    coverage_file = "coverage.info", 
                    coverage_command = "lcov --capture --directory . --output-file coverage.info",
                },
            },
        },
    },
    
    -- Language-specific test utilities
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, { "go", "rust", "zig", "c", "cpp" })
            end
        end,
    },
    
    -- Go-specific test enhancements
    {
        "ray-x/go.nvim",
        ft = "go",
        keys = {
            { "<leader>gtf", "<cmd>GoTestFunc<cr>",    desc = "Go: Test function",  ft = "go" },
            { "<leader>gtF", "<cmd>GoTestFile<cr>",    desc = "Go: Test file",      ft = "go" },
            { "<leader>gtp", "<cmd>GoTestPkg<cr>",     desc = "Go: Test package",   ft = "go" },
            { "<leader>gta", "<cmd>GoTest<cr>",        desc = "Go: Test all",       ft = "go" },
            { "<leader>gtc", "<cmd>GoCoverage<cr>",    desc = "Go: Coverage",       ft = "go" },
            { "<leader>gtC", "<cmd>GoCoverageToggle<cr>", desc = "Go: Toggle coverage", ft = "go" },
            { "<leader>gtb", "<cmd>GoTestCompile<cr>", desc = "Go: Test compile",   ft = "go" },
        },
    },
    
    -- Additional language-specific test commands via autocmds
    {
        "nvim-lua/plenary.nvim",
        init = function()
            -- Language-specific test commands
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "rust", "zig", "c", "cpp" },
                callback = function()
                    local ft = vim.bo.filetype
                    local bufnr = vim.api.nvim_get_current_buf()
                    
                    if ft == "rust" then
                        -- Rust-specific test commands
                        vim.keymap.set("n", "<leader>rtf", "<cmd>!cargo test<cr>", 
                            { desc = "Rust: Run all tests", buffer = bufnr })
                        vim.keymap.set("n", "<leader>rtd", "<cmd>!cargo test --doc<cr>", 
                            { desc = "Rust: Run doc tests", buffer = bufnr })
                        vim.keymap.set("n", "<leader>rtb", "<cmd>!cargo bench<cr>", 
                            { desc = "Rust: Run benchmarks", buffer = bufnr })
                        vim.keymap.set("n", "<leader>rtc", "<cmd>!cargo tarpaulin --out html<cr>", 
                            { desc = "Rust: Generate coverage", buffer = bufnr })
                            
                    elseif ft == "zig" then
                        -- Zig-specific test commands
                        vim.keymap.set("n", "<leader>ztf", "<cmd>!zig test %<cr>", 
                            { desc = "Zig: Test current file", buffer = bufnr })
                        vim.keymap.set("n", "<leader>zta", "<cmd>!zig build test<cr>", 
                            { desc = "Zig: Run all tests", buffer = bufnr })
                            
                    elseif ft == "c" or ft == "cpp" then
                        -- C/C++-specific test commands (assuming CMake/CTest)
                        vim.keymap.set("n", "<leader>ctf", "<cmd>!ctest<cr>", 
                            { desc = "C/C++: Run CTest", buffer = bufnr })
                        vim.keymap.set("n", "<leader>ctb", "<cmd>!make test<cr>", 
                            { desc = "C/C++: Make test", buffer = bufnr })
                        vim.keymap.set("n", "<leader>ctc", "<cmd>!lcov --capture --directory . --output-file coverage.info && genhtml coverage.info --output-directory coverage<cr>", 
                            { desc = "C/C++: Generate coverage", buffer = bufnr })
                    end
                end,
                desc = "Setup language-specific test keybindings",
            })
        end,
    },
}