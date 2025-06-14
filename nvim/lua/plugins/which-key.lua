---@diagnostic disable: undefined-global

return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            plugins = { spelling = true },
            spec = {
                -- ===================================================================
                -- CORE GROUPS
                -- ===================================================================
                -- Main category groups for organization
                
                { "<leader>c",   group = "code" },
                { "<leader>d",   group = "debug" },
                { "<leader>f",   group = "file/find" },
                { "<leader>g",   group = "git" },
                { "<leader>q",   group = "quit/session" },
                { "<leader>s",   group = "search" },
                { "<leader>t",   group = "test" },
                { "<leader>u",   group = "ui" },
                { "<leader>W",   group = "windows" },
                { "<leader>x",   group = "diagnostics/quickfix" },
                { "<leader>b",   group = "buffers" },
                { "<leader>e",   group = "explorer" },
                { "<leader>T",   group = "terminal" },
                { "<leader><tab>", group = "tabs" },

                -- ===================================================================
                -- SUBGROUPS
                -- ===================================================================
                -- Nested groups for better organization
                
                { "<leader>gh",  group = "hunks" },
                { "<leader>en",  group = "new" },
                { "<leader>eo",  group = "operations" },
                { "<leader>sn",  group = "noice" },

                -- ===================================================================
                -- HELP INTEGRATION
                -- ===================================================================
                -- Which-key help commands
                
                { "<leader>?",  function() require("which-key").show({ global = true }) end, desc = "Show All Keybindings" },
                { "<leader>h",  group = "help" },
                { "<leader>hk", function() require("which-key").show({ global = true }) end, desc = "Show All Keybindings" },
                { "<leader>he", function() require("which-key").show({ keys = "<leader>e", loop = true }) end, desc = "Explorer Help" },
                { "<leader>hg", function() require("which-key").show({ keys = "<leader>g", loop = true }) end, desc = "Git Help" },
                { "<leader>hs", function() require("which-key").show({ keys = "<leader>s", loop = true }) end, desc = "Search Help" },
                { "<leader>hc", function() require("which-key").show({ keys = "<leader>c", loop = true }) end, desc = "Code Help" },
                { "<leader>hf", function() require("which-key").show({ keys = "<leader>f", loop = true }) end, desc = "File Help" },
            },
        },
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)

            -- ===================================================================
            -- FILETYPE-SPECIFIC GROUPS
            -- ===================================================================
            -- Setup filetype-specific group mappings using autocmds
            
            local function setup_filetype_mappings()
                -- Go language mappings
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = "go",
                    callback = function()
                        wk.add({
                            { "<leader>g", group = "go", buffer = 0 },
                        })
                    end,
                })

                -- Rust language mappings
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = "rust",
                    callback = function()
                        wk.add({
                            { "<leader>r", group = "rust", buffer = 0 },
                        })
                    end,
                })

                -- Zig language mappings
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = "zig",
                    callback = function()
                        wk.add({
                            { "<leader>z", group = "zig", buffer = 0 },
                        })
                    end,
                })

                -- TypeScript/JavaScript mappings
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
                    callback = function()
                        wk.add({
                            { "<leader>j", group = "typescript/javascript", buffer = 0 },
                        })
                    end,
                })

                -- C/C++ mappings
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = { "c", "cpp" },
                    callback = function()
                        wk.add({
                            { "<leader>cc", group = "c/cpp", buffer = 0 },
                        })
                    end,
                })

                -- Lua mappings
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = "lua",
                    callback = function()
                        wk.add({
                            { "<leader>l", group = "lua", buffer = 0 },
                        })
                    end,
                })

                -- Package manager (for package.json files)
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = "json",
                    callback = function()
                        local filename = vim.fn.expand("%:t")
                        if filename == "package.json" then
                            wk.add({
                                { "<leader>n", group = "npm", buffer = 0 },
                            })
                        end
                    end,
                })

                -- Markdown mappings
                vim.api.nvim_create_autocmd("FileType", {
                    pattern = "markdown",
                    callback = function()
                        wk.add({
                            { "<leader>m", group = "markdown", buffer = 0 },
                        })
                    end,
                })
            end

            -- Setup the filetype mappings
            setup_filetype_mappings()
        end,
    },
    
    -- ===================================================================
    -- MINI.ICONS SUPPORT
    -- ===================================================================
    -- Add mini.icons for better icon support
    
    {
        "echasnovski/mini.icons",
        lazy = true,
        opts = {},
        init = function()
            -- Mock nvim-web-devicons for compatibility
            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
    },
}