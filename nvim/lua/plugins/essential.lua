---@diagnostic disable: undefined-global

return {
    -- Better vim.notify
    {
        "rcarriga/nvim-notify",
        keys = {
            {
                "<leader>un",
                function()
                    require("notify").dismiss({ silent = true, pending = true })
                end,
                desc = "Dismiss all Notifications",
            },
        },
        opts = {
            timeout = 3000,
            background_colour = "#000000",
            stages = "fade_in_slide_out",
            top_down = false,  -- Show notifications from bottom to top
            max_height = function()
                return math.floor(vim.o.lines * 0.25)  -- Smaller height to be less intrusive
            end,
            max_width = function()
                return math.floor(vim.o.columns * 0.25)  -- Smaller width for bottom right
            end,
            on_open = function(win)
                vim.api.nvim_win_set_config(win, { zindex = 100 })
            end,
        },
        init = function()
            vim.notify = require("notify")
        end,
    },

    -- Better vim.ui
    {
        "stevearc/dressing.nvim",
        lazy = true,
        init = function()
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.select = function(...)
                ---@diagnostic disable-next-line: different-requires
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.select(...)
            end
            ---@diagnostic disable-next-line: duplicate-set-field
            vim.ui.input = function(...)
                ---@diagnostic disable-next-line: different-requires
                require("lazy").load({ plugins = { "dressing.nvim" } })
                return vim.ui.input(...)
            end
        end,
    },

    -- Better buffer delete
    {
        "echasnovski/mini.bufremove",
        keys = {
            {
                "<leader>bd",
                function()
                    local bd = require("mini.bufremove").delete
                    if vim.bo.modified then
                        local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()),
                            "&Yes\n&No\n&Cancel")
                        if choice == 1 then -- Yes
                            vim.cmd.write()
                            bd(0)
                        elseif choice == 2 then -- No
                            bd(0, true)
                        end
                    else
                        bd(0)
                    end
                end,
                desc = "Delete Buffer",
            },
            {
                "<leader>bD",
                function()
                    require("mini.bufremove").delete(0, true)
                end,
                desc = "Delete Buffer (Force)",
            },
        },
    },

    -- Session management
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = { options = vim.opt.sessionoptions:get() },
        keys = {
            { "<leader>qs", function() require("persistence").load() end,                desc = "Restore Session" },
            { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
            { "<leader>qd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
        },
        config = function(_, opts)
            require("persistence").setup(opts)
            
            -- Add which-key groups for Session/Quit operations
            require("which-key").add({
                { "<leader>q", group = "quit/session" },
            })
        end,
    },

    -- Library used by other plugins
    { "nvim-lua/plenary.nvim", lazy = true },

    -- Makes some plugins dot-repeatable like leap
    { "tpope/vim-repeat",      event = "VeryLazy" },

    -- Better around/inside textobjects
    {
        "echasnovski/mini.ai",
        event = "VeryLazy",
        opts = function()
            local ai = require("mini.ai")
            return {
                n_lines = 500,
                custom_textobjects = {
                    o = ai.gen_spec.treesitter({
                        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                    }, {}),
                    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
                    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
                    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
                    d = { "%f[%d]%d+" }, -- digits
                    e = {      -- Word with case
                        {
                            "%u[%l%d]+%f[^%l%d]",
                            "%f[%S][%l%d]+%f[^%l%d]",
                            "%f[%P][%l%d]+%f[^%l%d]",
                            "^[%l%d]+%f[^%l%d]",
                        },
                        "^().*()$",
                    },
                    u = ai.gen_spec.function_call(),                 -- u for "Usage"
                    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
                },
            }
        end,
    },

    -- Fast and feature-rich surround actions
    {
        "echasnovski/mini.surround",
        keys = function(_, keys)
            -- Populate the keys based on the user's options
            local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
            local opts = require("lazy.core.plugin").values(plugin, "opts", false)
            local mappings = {
                { opts.mappings.add,            desc = "Add surrounding",                     mode = { "n", "v" } },
                { opts.mappings.delete,         desc = "Delete surrounding" },
                { opts.mappings.find,           desc = "Find right surrounding" },
                { opts.mappings.find_left,      desc = "Find left surrounding" },
                { opts.mappings.highlight,      desc = "Highlight surrounding" },
                { opts.mappings.replace,        desc = "Replace surrounding" },
                { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
            }
            mappings = vim.tbl_filter(function(m)
                return m[1] and #m[1] > 0
            end, mappings)
            return vim.list_extend(mappings, keys)
        end,
        opts = {
            mappings = {
                add = "gsa",    -- Add surrounding in Normal and Visual modes
                delete = "gsd", -- Delete surrounding
                find = "gsf",   -- Find surrounding (to the right)
                find_left = "gsF", -- Find surrounding (to the left)
                highlight = "gsh", -- Highlight surrounding
                replace = "gsr", -- Replace surrounding
                update_n_lines = "gsn", -- Update `n_lines`
            },
        },
    },

    -- Auto pairs
    {
        "echasnovski/mini.pairs",
        event = "VeryLazy",
        opts = {},
        keys = {
            {
                "<leader>up",
                function()
                    vim.g.minipairs_disable = not vim.g.minipairs_disable
                    if vim.g.minipairs_disable then
                        vim.notify("Disabled auto pairs", vim.log.levels.WARN, { title = "Option" })
                    else
                        vim.notify("Enabled auto pairs", vim.log.levels.INFO, { title = "Option" })
                    end
                end,
                desc = "Toggle auto pairs",
            },
        },
    },

    -- Better Comment/Uncomment
    {
        "echasnovski/mini.comment",
        event = "VeryLazy",
        opts = {
            options = {
                custom_commentstring = function()
                    return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo
                    .commentstring
                end,
            },
        },
    },

    -- Icons
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
        opts = {
            default = true,
        },
    },

    -- Git integration
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
                end

                -- Essential git hunks only (simplified from 12 shortcuts)
                map("n", "]h", gs.next_hunk, "Next Hunk")
                map("n", "[h", gs.prev_hunk, "Prev Hunk")
            end,
        },
        config = function(_, opts)
            require("gitsigns").setup(opts)
            
            -- Add which-key groups for Git operations
            require("which-key").add({
                { "<leader>g", group = "git" },
            })
        end,
    },

    -- Trouble.nvim - Pretty diagnostics, references, telescope results, quickfix and location list
    {
        "folke/trouble.nvim",
        cmd = { "Trouble" },
        opts = {
            modes = {
                preview_float = {
                    mode = "diagnostics",
                    preview = {
                        type = "float",
                        relative = "editor",
                        border = "rounded",
                        title = "Preview",
                        title_pos = "center",
                        position = { 0, -2 },
                        size = { width = 0.3, height = 0.3 },
                        zindex = 200,
                    },
                },
            },
        },
        keys = {
            -- Essential diagnostics only
            { "[d", vim.diagnostic.goto_prev, desc = "Previous diagnostic" },
            { "]d", vim.diagnostic.goto_next, desc = "Next diagnostic" },
        },
        config = function(_, opts)
            require("trouble").setup(opts)
            
            -- Simplified diagnostics - no extra groups needed
        end,
    },
}
