---@diagnostic disable: undefined-global

-- DAP (Debug Adapter Protocol) Module for Systems Programming Languages
-- Supports: Go, Rust, Zig, C/C++
-- Enable in options.lua: vim.g.enable_debugging_module = true

return {
    -- DAP Core
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            -- Mason integration for auto-installing debug adapters
            {
                "jay-babu/mason-nvim-dap.nvim",
                dependencies = { "mason.nvim" },
                cmd = { "DapInstall", "DapUninstall" },
                opts = {
                    automatic_installation = true,
                    ensure_installed = {
                        "delve",    -- Go
                        "codelldb", -- Rust, Zig, C/C++
                    },
                    handlers = {}, -- uses default handlers
                },
            },

            -- UI enhancements
            {
                "rcarriga/nvim-dap-ui",
                keys = {
                    { "<leader>du", function() require("dapui").toggle() end, desc = "Debug UI" },
                    { "<leader>de", function() require("dapui").eval() end,   desc = "Debug Eval",      mode = { "n", "v" } },
                },
                opts = {
                    icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
                    mappings = {
                        expand = { "<CR>", "<2-LeftMouse>" },
                        open = "o",
                        remove = "d",
                        edit = "e",
                        repl = "r",
                        toggle = "t",
                    },
                    layouts = {
                        {
                            elements = {
                                { id = "scopes",      size = 0.25 },
                                { id = "breakpoints", size = 0.25 },
                                { id = "stacks",      size = 0.25 },
                                { id = "watches",     size = 0.25 },
                            },
                            size = 40,
                            position = "left",
                        },
                        {
                            elements = {
                                { id = "repl",    size = 0.5 },
                                { id = "console", size = 0.5 },
                            },
                            size = 10,
                            position = "bottom",
                        },
                    },
                    controls = {
                        enabled = true,
                        element = "repl",
                        icons = {
                            pause = "",
                            play = "",
                            step_into = "",
                            step_over = "",
                            step_out = "",
                            step_back = "",
                            run_last = "↻",
                            terminate = "□",
                        },
                    },
                    floating = {
                        max_height = nil,
                        max_width = nil,
                        border = "single",
                        mappings = {
                            close = { "q", "<Esc>" },
                        },
                    },
                    windows = { indent = 1 },
                    render = {
                        max_type_length = nil,
                        max_value_lines = 100,
                    },
                },
                config = function(_, opts)
                    local dap = require("dap")
                    local dapui = require("dapui")
                    dapui.setup(opts)

                    -- Auto-open/close UI
                    dap.listeners.after.event_initialized["dapui_config"] = function()
                        dapui.open()
                    end
                    dap.listeners.before.event_terminated["dapui_config"] = function()
                        dapui.close()
                    end
                    dap.listeners.before.event_exited["dapui_config"] = function()
                        dapui.close()
                    end
                end,
            },

            -- Virtual text for variables
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {
                    enabled = true,
                    enabled_commands = true,
                    highlight_changed_variables = true,
                    highlight_new_as_changed = false,
                    show_stop_reason = true,
                    commented = false,
                    only_first_definition = true,
                    all_references = false,
                    filter_references_pattern = '<module',
                    virt_text_pos = 'eol',
                    all_frames = false,
                    virt_lines = false,
                    virt_text_win_col = nil,
                },
            },
        },

        keys = {
            -- Basic debugging controls
            { "<F5>",       function() require("dap").continue() end,          desc = "Debug: Continue" },
            { "<F10>",      function() require("dap").step_over() end,        desc = "Debug: Step Over" },
            { "<F11>",      function() require("dap").step_into() end,        desc = "Debug: Step Into" },
            { "<F12>",      function() require("dap").step_out() end,         desc = "Debug: Step Out" },

            -- Breakpoint management
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Debug: Conditional Breakpoint" },
            { "<leader>dc", function() require("dap").clear_breakpoints() end, desc = "Debug: Clear Breakpoints" },

            -- Session management
            { "<leader>dd", function() require("dap").continue() end,          desc = "Debug: Start/Continue" },
            { "<leader>ds", function() require("dap").close() end,            desc = "Debug: Stop" },
            { "<leader>dr", function() require("dap").restart() end,          desc = "Debug: Restart" },

            -- REPL and evaluation
            { "<leader>dR", function() require("dap").repl.open() end,        desc = "Debug: Open REPL" },
            { "<leader>dl", function() require("dap").run_last() end,         desc = "Debug: Run Last" },
        },

        config = function()
            local dap = require("dap")

            -- Configure signs
            vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "🔍", texthl = "DiagnosticSignWarn", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointRejected", { text = "❌", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "DiagnosticSignWarn", linehl = "Visual", numhl = "" })

            -- Go debugging configuration (Delve)
            dap.adapters.delve = {
                type = "server",
                port = "${port}",
                executable = {
                    command = "dlv",
                    args = { "dap", "-l", "127.0.0.1:${port}" },
                },
            }

            dap.configurations.go = {
                {
                    type = "delve",
                    name = "Debug",
                    request = "launch",
                    program = "${file}",
                },
                {
                    type = "delve",
                    name = "Debug test",
                    request = "launch",
                    mode = "test",
                    program = "${file}",
                },
                {
                    type = "delve",
                    name = "Debug test (go.mod)",
                    request = "launch",
                    mode = "test",
                    program = "./${relativeFileDirname}",
                },
                {
                    type = "delve",
                    name = "Attach to process",
                    request = "attach",
                    processId = function()
                        return require("dap.utils").pick_process()
                    end,
                },
            }

            -- Rust, Zig, C/C++ debugging configuration (CodeLLDB)
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = "codelldb",
                    args = { "--port", "${port}" },
                },
            }

            -- Rust configuration
            dap.configurations.rust = {
                {
                    name = "Launch",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        local metadata = vim.fn.system("cargo metadata --format-version 1 --no-deps")
                        local parsed = vim.fn.json_decode(metadata)
                        local target_name = parsed.packages[1].targets[1].name
                        local target_dir = parsed.target_directory
                        return target_dir .. "/debug/" .. target_name
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                    runInTerminal = false,
                },
                {
                    name = "Attach to process",
                    type = "codelldb",
                    request = "attach",
                    processId = function()
                        return require("dap.utils").pick_process()
                    end,
                },
            }

            -- Zig configuration
            dap.configurations.zig = {
                {
                    name = "Launch",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        -- Look for zig-out/bin/ directory first
                        local cwd = vim.fn.getcwd()
                        local bin_path = cwd .. "/zig-out/bin/"
                        if vim.fn.isdirectory(bin_path) == 1 then
                            local files = vim.fn.glob(bin_path .. "*", false, true)
                            if #files > 0 then
                                return files[1]
                            end
                        end
                        -- Fallback to asking user
                        return vim.fn.input("Path to executable: ", cwd .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                },
            }

            -- C/C++ configuration
            dap.configurations.c = {
                {
                    name = "Launch",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                    runInTerminal = false,
                },
                {
                    name = "Attach to process",
                    type = "codelldb",
                    request = "attach",
                    processId = function()
                        return require("dap.utils").pick_process()
                    end,
                },
            }

            dap.configurations.cpp = dap.configurations.c

            -- Language-specific keybindings
            local function setup_language_debug_keys()
                local ft = vim.bo.filetype
                local bufnr = vim.api.nvim_get_current_buf()

                if ft == "go" then
                    vim.keymap.set("n", "<leader>dt", function()
                        require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
                    end, { desc = "Debug: Log Point", buffer = bufnr })
                elseif ft == "rust" then
                    vim.keymap.set("n", "<leader>dt", function()
                        vim.cmd("!cargo build")
                        require("dap").continue()
                    end, { desc = "Debug: Build & Debug", buffer = bufnr })
                elseif ft == "zig" then
                    vim.keymap.set("n", "<leader>dt", function()
                        vim.cmd("!zig build")
                        require("dap").continue()
                    end, { desc = "Debug: Build & Debug", buffer = bufnr })
                elseif ft == "c" or ft == "cpp" then
                    vim.keymap.set("n", "<leader>dt", function()
                        vim.cmd("!make")
                        require("dap").continue()
                    end, { desc = "Debug: Build & Debug", buffer = bufnr })
                end
            end

            -- Setup language-specific keys when entering supported filetypes
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "go", "rust", "zig", "c", "cpp" },
                callback = setup_language_debug_keys,
                desc = "Setup language-specific debug keybindings",
            })
        end,
    },
}