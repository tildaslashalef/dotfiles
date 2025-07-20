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
                
                -- Simplified groups - removed excessive categories

                -- ===================================================================
                -- HELP INTEGRATION (Simplified - use natural which-key)
                -- ===================================================================
                
                { "<leader>?",  function() require("which-key").show({ global = true }) end, desc = "Show All Keybindings" },
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