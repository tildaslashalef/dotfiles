---@diagnostic disable: undefined-global

return {

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
            -- Essential Go shortcuts only (simplified from 12 to 4)
            { "<leader>gt", "<cmd>GoTest<cr>",  desc = "Go Test",   ft = "go" },
            { "<leader>gr", "<cmd>GoRun<cr>",   desc = "Go Run",    ft = "go" },
            { "<leader>gb", "<cmd>GoBuild<cr>", desc = "Go Build",  ft = "go" },
            { "<leader>gf", "<cmd>GoFmt<cr>",   desc = "Go Format", ft = "go" },
        },
    },

    -- Zig language support
    {
        "ziglang/zig.vim",
        ft = "zig",
        config = function()
            -- Zig-specific settings
            vim.g.zig_fmt_autosave = 0 -- We handle formatting via conform.nvim

            -- Essential Zig shortcuts only (simplified from 7 to 4)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "zig",
                callback = function(args)
                    local bufnr = args.buf
                    vim.keymap.set("n", "<leader>zt", "<cmd>!zig test %<cr>", { desc = "Zig Test", buffer = bufnr })
                    vim.keymap.set("n", "<leader>zr", "<cmd>!zig run %<cr>", { desc = "Zig Run", buffer = bufnr })
                    vim.keymap.set("n", "<leader>zb", "<cmd>!zig build<cr>", { desc = "Zig Build", buffer = bufnr })
                    vim.keymap.set("n", "<leader>zf", "<cmd>!zig fmt %<cr>", { desc = "Zig Format", buffer = bufnr })
                end,
            })
        end,
    },

    -- Note: TypeScript treesitter parsers are configured in editor.lua

    -- C language enhancements (C only, no C++)
    {
        "p00f/clangd_extensions.nvim",
        ft = { "c" },
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

            -- Essential C shortcuts only (simplified)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "c" },
                callback = function(args)
                    local bufnr = args.buf
                    vim.keymap.set("n", "<leader>ct", "<cmd>!make test || echo 'No test target'<cr>", { desc = "C Test", buffer = bufnr })
                    vim.keymap.set("n", "<leader>cr", "<cmd>!make run || ./a.out<cr>", { desc = "C Run", buffer = bufnr })
                    vim.keymap.set("n", "<leader>cb", "<cmd>!make || clang %<cr>", { desc = "C Build", buffer = bufnr })
                    vim.keymap.set("n", "<leader>cf", "<cmd>!clang-format -i %<cr>", { desc = "C Format", buffer = bufnr })
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
