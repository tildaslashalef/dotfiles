---@diagnostic disable: undefined-global

return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            plugins = { spelling = true },
            spec = {
                -- ===================================================================
                -- CORE GROUPS (Only meta-functionality - not plugin-specific)
                -- ===================================================================
                -- Plugin-specific groups are now defined in their respective plugin files
                
                { "<leader>h",     group = "help" },
                { "<leader>u",     group = "ui/toggle" },
                { "<leader>W",     group = "windows" },
                { "<leader><tab>", group = "tabs" },

                -- ===================================================================
                -- HELP INTEGRATION
                -- ===================================================================
                -- Which-key help commands
                
                { "<leader>?",  function() require("which-key").show({ global = true }) end, desc = "Show All Keybindings" },
                { "<leader>hk", function() require("which-key").show({ global = true }) end, desc = "Show All Keybindings" },
                { "<leader>he", function() require("which-key").show({ keys = "<leader>e", loop = true }) end, desc = "Explorer Help" },
                { "<leader>hg", function() require("which-key").show({ keys = "<leader>g", loop = true }) end, desc = "Git Help" },
                { "<leader>hs", function() require("which-key").show({ keys = "<leader>s", loop = true }) end, desc = "Search Help" },
                { "<leader>hc", function() require("which-key").show({ keys = "<leader>c", loop = true }) end, desc = "Code Help" },
                { "<leader>hf", function() require("which-key").show({ keys = "<leader>f", loop = true }) end, desc = "File Help" },
            },
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
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