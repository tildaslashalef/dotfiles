---@diagnostic disable: undefined-global

return {
    -- GitHub Copilot: AI-powered code completion
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                panel = {
                    enabled = true,
                    auto_refresh = false,
                    keymap = {
                        jump_prev = "[[",
                        jump_next = "]]",
                        accept = "<CR>",
                        refresh = "gr",
                        open = "<M-CR>"
                    },
                    layout = {
                        position = "bottom", -- | top | left | right
                        ratio = 0.4
                    },
                },
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    debounce = 75,
                    keymap = {
                        accept = "<C-g>",
                        accept_word = false,
                        accept_line = false,
                        next = "<C-j>",
                        prev = "<C-k>",
                        dismiss = "<C-o>",
                    },
                },
                filetypes = {
                    yaml = false,
                    markdown = false,
                    help = false,
                    gitcommit = false,
                    gitrebase = false,
                    hgcommit = false,
                    svn = false,
                    cvs = false,
                    ["."] = false,
                },
                copilot_node_command = 'node', -- Node.js version must be > 18.x
                server_opts_overrides = {},
            })

            -- AI keybindings
            vim.keymap.set("n", "<leader>ai", function()
                local suggestion = require("copilot.suggestion")
                local client = require("copilot.client")
                
                -- Check if copilot is currently disabled
                if client.is_disabled() then
                    -- Enable copilot (auto-trigger is part of enabling)
                    vim.cmd("Copilot enable")
                    vim.notify("Copilot enabled", vim.log.levels.INFO)
                else
                    -- Disable copilot completely
                    vim.cmd("Copilot disable")
                    vim.notify("Copilot disabled", vim.log.levels.INFO)
                end
            end, { desc = "Toggle Copilot" })

            vim.keymap.set("n", "<leader>ap", function()
                require("copilot.panel").open()
            end, { desc = "Open Copilot Panel" })

            -- Manual trigger when auto-trigger is off
            vim.keymap.set("i", "<C-s>", function()
                require("copilot.suggestion").next()
            end, { desc = "Trigger/Next Copilot suggestion" })
        end,
    },

    -- Go language enhancements
    {
        "ray-x/go.nvim",
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup({
                goimport = "gopls", -- goimport command
                gofmt = "gofumpt",  -- gofmt cmd
                -- max_line_len = 120,
                tag_transform = false,
                test_dir = "",
                comment_placeholder = "   ",
                lsp_cfg = false,     -- false: do not call require('lspconfig').gopls.setup{} we'll handle this in lsp.lua
                lsp_gofumpt = true,
                lsp_on_attach = nil, -- use on_attach from lsp.lua
                dap_debug = false,   -- set this to true if you want to use dap
                dap_debug_keymap = false,
                dap_debug_gui = false,
                dap_debug_vt = false,
                -- build_tags = "tag1,tag2",
                textobjects = true,
                test_runner = "go", -- richgo, go, richgo, dlv, ginkgo
                verbose_tests = true,
                run_in_floaterm = false,
                luasnip = false,
            })
        end,
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
        keys = {
            -- Go-specific keybindings (using <leader>go prefix to avoid git conflicts)
            { "<leader>got", "<cmd>GoTest<cr>",       desc = "Go Test",           ft = "go" },
            { "<leader>goT", "<cmd>GoTestPkg<cr>",    desc = "Go Test Package",   ft = "go" },
            { "<leader>gob", "<cmd>GoBuild<cr>",      desc = "Go Build",          ft = "go" },
            { "<leader>gor", "<cmd>GoRun<cr>",        desc = "Go Run",            ft = "go" },
            { "<leader>goc", "<cmd>GoCoverage<cr>",   desc = "Go Coverage",       ft = "go" },
            { "<leader>goi", "<cmd>GoImplements<cr>", desc = "Go Implements",     ft = "go" },
            { "<leader>gos", "<cmd>GoFillStruct<cr>", desc = "Go Fill Struct",    ft = "go" },
            { "<leader>gof", "<cmd>GoFmt<cr>",        desc = "Go Format",         ft = "go" },
            { "<leader>goI", "<cmd>GoImport<cr>",     desc = "Go Import",         ft = "go" },
            { "<leader>goA", "<cmd>GoAlt<cr>",        desc = "Go Alternate File", ft = "go" },
            { "<leader>god", "<cmd>GoDoc<cr>",        desc = "Go Documentation",  ft = "go" },
            { "<leader>gop", "<cmd>GoPlay<cr>",       desc = "Go Playground",     ft = "go" },
        },
    },

    -- Rust language enhancements
    {
        "mrcjkb/rustaceanvim",
        version = '^6',
        ft = { "rust" },
        opts = {
            server = {
                on_attach = function(client, bufnr)
                    -- Rust-specific keybindings
                    vim.keymap.set("n", "<leader>rt", "<cmd>RustLsp testables<cr>",
                        { desc = "Rust Test", buffer = bufnr })
                    vim.keymap.set("n", "<leader>rr", "<cmd>RustLsp runnables<cr>", { desc = "Rust Run", buffer = bufnr })
                    vim.keymap.set("n", "<leader>rd", "<cmd>RustLsp debuggables<cr>",
                        { desc = "Rust Debug", buffer = bufnr })
                    vim.keymap.set("n", "<leader>re", "<cmd>RustLsp expandMacro<cr>",
                        { desc = "Rust Expand Macro", buffer = bufnr })
                    vim.keymap.set("n", "<leader>rc", "<cmd>RustLsp openCargo<cr>",
                        { desc = "Rust Open Cargo.toml", buffer = bufnr })
                    vim.keymap.set("n", "<leader>rp", "<cmd>RustLsp parentModule<cr>",
                        { desc = "Rust Parent Module", buffer = bufnr })
                    vim.keymap.set("n", "<leader>rj", "<cmd>RustLsp joinLines<cr>",
                        { desc = "Rust Join Lines", buffer = bufnr })
                    vim.keymap.set("n", "<leader>rH", "<cmd>RustLsp hover actions<cr>",
                        { desc = "Rust Hover Actions", buffer = bufnr })
                    vim.keymap.set("n", "<leader>rC", "<cmd>RustLsp openDocs<cr>",
                        { desc = "Rust Open Docs", buffer = bufnr })
                end,
                default_settings = {
                    -- rust-analyzer language server configuration
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                            loadOutDirsFromCheck = true,
                            runBuildScripts = true,
                        },
                        -- Add clippy lints for Rust.
                        checkOnSave = {
                            allFeatures = true,
                            command = "clippy",
                            extraArgs = { "--no-deps" },
                        },
                        procMacro = {
                            enable = true,
                            ignored = {
                                ["async-trait"] = { "async_trait" },
                                ["napi-derive"] = { "napi" },
                                ["async-recursion"] = { "async_recursion" },
                            },
                        },
                    },
                },
            },
        },
        config = function(_, opts)
            vim.g.rustaceanvim = vim.tbl_deep_extend("force", {}, opts or {})
        end,
    },

    -- Zig language support
    {
        "ziglang/zig.vim",
        ft = "zig",
        config = function()
            -- Zig-specific settings
            vim.g.zig_fmt_autosave = 0 -- We handle formatting via conform.nvim

            -- Zig-specific keybindings
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "zig",
                callback = function(args)
                    local bufnr = args.buf
                    vim.keymap.set("n", "<leader>zb", "<cmd>!zig build<cr>", { desc = "Zig Build", buffer = bufnr })
                    vim.keymap.set("n", "<leader>zr", "<cmd>!zig run %<cr>", { desc = "Zig Run", buffer = bufnr })
                    vim.keymap.set("n", "<leader>zt", "<cmd>!zig test %<cr>", { desc = "Zig Test", buffer = bufnr })
                    vim.keymap.set("n", "<leader>zf", "<cmd>!zig fmt %<cr>", { desc = "Zig Format", buffer = bufnr })
                    vim.keymap.set("n", "<leader>zc", "<cmd>!zig build-exe %<cr>",
                        { desc = "Zig Compile", buffer = bufnr })
                    vim.keymap.set("n", "<leader>zd", "<cmd>!zig build-exe -O Debug %<cr>",
                        { desc = "Zig Debug Build", buffer = bufnr })
                    vim.keymap.set("n", "<leader>zo", "<cmd>!zig build-exe -O ReleaseFast %<cr>",
                        { desc = "Zig Optimized Build", buffer = bufnr })
                end,
            })
        end,
    },

    -- Note: TypeScript treesitter parsers are configured in editor.lua

    -- Package.json support
    {
        "vuki656/package-info.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        ft = "json",
        config = function()
            require("package-info").setup()

            -- Package.json keybindings
            vim.keymap.set("n", "<leader>ns", "<cmd>lua require('package-info').show()<cr>",
                { desc = "Show package info" })
            vim.keymap.set("n", "<leader>nc", "<cmd>lua require('package-info').hide()<cr>",
                { desc = "Hide package info" })
            vim.keymap.set("n", "<leader>nt", "<cmd>lua require('package-info').toggle()<cr>",
                { desc = "Toggle package info" })
            vim.keymap.set("n", "<leader>nu", "<cmd>lua require('package-info').update()<cr>",
                { desc = "Update package" })
            vim.keymap.set("n", "<leader>nd", "<cmd>lua require('package-info').delete()<cr>",
                { desc = "Delete package" })
            vim.keymap.set("n", "<leader>ni", "<cmd>lua require('package-info').install()<cr>",
                { desc = "Install package" })
            vim.keymap.set("n", "<leader>np", "<cmd>lua require('package-info').change_version()<cr>",
                { desc = "Change package version" })
        end,
    },

    -- C/C++ enhancements
    {
        "p00f/clangd_extensions.nvim",
        ft = { "c", "cpp" },
        config = function()
            require("clangd_extensions").setup({
                inlay_hints = {
                    inline = vim.fn.has("nvim-0.10") == 1,
                    only_current_line = false,
                    only_current_line_autocmd = "CursorHold",
                    show_parameter_hints = true,
                    parameter_hints_prefix = "<- ",
                    other_hints_prefix = "=> ",
                    max_len_align = false,
                    max_len_align_padding = 1,
                    right_align = false,
                    right_align_padding = 7,
                    highlight = "Comment",
                    priority = 100,
                },
                ast = {
                    role_icons = {
                        type = "",
                        declaration = "",
                        expression = "",
                        specifier = "",
                        statement = "",
                        ["template argument"] = "",
                    },
                    kind_icons = {
                        Compound = "",
                        Recovery = "",
                        TranslationUnit = "",
                        PackExpansion = "",
                        TemplateTypeParm = "",
                        TemplateTemplateParm = "",
                        TemplateParamObject = "",
                    },
                    highlights = {
                        detail = "Comment",
                    },
                },
                memory_usage = {
                    border = "none",
                },
                symbol_info = {
                    border = "none",
                },
            })

            -- C/C++ specific keybindings
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "c", "cpp" },
                callback = function(args)
                    local bufnr = args.buf
                    vim.keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>",
                        { desc = "Switch Source/Header", buffer = bufnr })
                    vim.keymap.set("n", "<leader>cs", "<cmd>ClangdSymbolInfo<cr>",
                        { desc = "Symbol Info", buffer = bufnr })
                    vim.keymap.set("n", "<leader>ct", "<cmd>ClangdTypeHierarchy<cr>",
                        { desc = "Type Hierarchy", buffer = bufnr })
                    vim.keymap.set("n", "<leader>cm", "<cmd>ClangdMemoryUsage<cr>",
                        { desc = "Memory Usage", buffer = bufnr })
                    vim.keymap.set("n", "<leader>ca", "<cmd>ClangdAST<cr>", { desc = "AST", buffer = bufnr })
                end,
            })
        end,
    },

    -- CMake support
    {
        "Civitasv/cmake-tools.nvim",
        ft = { "c", "cpp", "cmake" },
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("cmake-tools").setup({
                cmake_command = "cmake",
                cmake_regenerate_on_save = true,
                cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
                cmake_build_options = {},
                cmake_build_directory = "build/${variant:buildType}",
                cmake_soft_link_compile_commands = true,
                cmake_compile_commands_from_lsp = false,
                cmake_kits_path = nil,
                cmake_variants_message = {
                    short = { show = true },
                    long = { show = true, max_length = 40 },
                },
                cmake_dap_configuration = {
                    name = "cpp",
                    type = "codelldb",
                    request = "launch",
                    stopOnEntry = false,
                    runInTerminal = true,
                    console = "integratedTerminal",
                },
                cmake_executor = {
                    name = "quickfix",
                    opts = {},
                    default_opts = {
                        quickfix = {
                            show = "always",
                            position = "belowright",
                            size = 10,
                            encoding = "utf-8",
                            auto_close_when_success = true,
                        },
                    },
                },
                cmake_runner = {
                    name = "terminal",
                    opts = {},
                    default_opts = {
                        quickfix = {
                            show = "always",
                            position = "belowright",
                            size = 10,
                            encoding = "utf-8",
                            auto_close_when_success = true,
                        },
                        terminal = {
                            name = "Main Terminal",
                            prefix_name = "[CMakeTools]: ",
                            split_direction = "horizontal",
                            split_size = 11,
                            single_terminal_per_instance = true,
                            single_terminal_per_tab = true,
                            keep_terminal_static_location = true,
                            auto_resize = true,
                            start_insert = false,
                        },
                    },
                },
                cmake_notifications = {
                    runner = { enabled = true },
                    executor = { enabled = true },
                    spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
                },
            })

            -- CMake keybindings
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "c", "cpp", "cmake" },
                callback = function(args)
                    local bufnr = args.buf
                    vim.keymap.set("n", "<leader>cb", "<cmd>CMakeBuild<cr>", { desc = "CMake Build", buffer = bufnr })
                    vim.keymap.set("n", "<leader>cr", "<cmd>CMakeRun<cr>", { desc = "CMake Run", buffer = bufnr })
                    vim.keymap.set("n", "<leader>cd", "<cmd>CMakeDebug<cr>", { desc = "CMake Debug", buffer = bufnr })
                    vim.keymap.set("n", "<leader>cc", "<cmd>CMakeClean<cr>", { desc = "CMake Clean", buffer = bufnr })
                    vim.keymap.set("n", "<leader>cg", "<cmd>CMakeGenerate<cr>",
                        { desc = "CMake Generate", buffer = bufnr })
                    vim.keymap.set("n", "<leader>cs", "<cmd>CMakeSettings<cr>",
                        { desc = "CMake Settings", buffer = bufnr })
                    vim.keymap.set("n", "<leader>ct", "<cmd>CMakeSelectBuildType<cr>",
                        { desc = "CMake Build Type", buffer = bufnr })
                    vim.keymap.set("n", "<leader>ck", "<cmd>CMakeSelectKit<cr>", { desc = "CMake Kit", buffer = bufnr })
                end,
            })
        end,
    },

    -- General completion enhancements
    {
        "hrsh7th/nvim-cmp",
        version = false, -- last release is way too old
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
        },
        opts = function()
            vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
            local cmp = require("cmp")
            local defaults = require("cmp.config.default")()
            return {
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    ["<S-CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    ["<C-CR>"] = function(fallback)
                        cmp.abort()
                        fallback()
                    end,
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                }, {
                    { name = "buffer" },
                }),
                formatting = {
                    format = function(_, item)
                        local icons = {
                            Text = "󰉿",
                            Method = "󰆧",
                            Function = "󰊕",
                            Constructor = "",
                            Field = "󰜢",
                            Variable = "󰀫",
                            Class = "󰠱",
                            Interface = "",
                            Module = "",
                            Property = "󰜢",
                            Unit = "󰑭",
                            Value = "󰎠",
                            Enum = "",
                            Keyword = "󰌋",
                            Snippet = "",
                            Color = "󰏘",
                            File = "󰈙",
                            Reference = "󰈇",
                            Folder = "󰉋",
                            EnumMember = "",
                            Constant = "󰏿",
                            Struct = "󰙅",
                            Event = "",
                            Operator = "󰆕",
                            TypeParameter = "",
                        }
                        if icons[item.kind] then
                            item.kind = icons[item.kind] .. " " .. item.kind
                        end
                        return item
                    end,
                },
                experimental = {
                    ghost_text = {
                        hl_group = "CmpGhostText",
                    },
                },
                sorting = defaults.sorting,
            }
        end,
        config = function(_, opts)
            for _, source in ipairs(opts.sources) do
                source.group_index = source.group_index or 1
            end
            require("cmp").setup(opts)
        end,
    },

    -- Snippets
    {
        "L3MON4D3/LuaSnip",
        build = (function()
            -- Build Step is needed for regex support in snippets
            -- This step is not supported in many windows environments
            -- Remove the below condition to re-enable on windows
            if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                return
            end
            return "make install_jsregexp"
        end)(),
        dependencies = {
            {
                "rafamadriz/friendly-snippets",
                config = function()
                    require("luasnip.loaders.from_vscode").lazy_load()
                end,
            },
        },
        opts = {
            history = true,
            delete_check_events = "TextChanged",
        },
        keys = {
            {
                "<tab>",
                function()
                    return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
                end,
                expr = true,
                silent = true,
                mode = "i",
            },
            { "<tab>",   function() require("luasnip").jump(1) end,  mode = "s" },
            { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
        },
    },
}
