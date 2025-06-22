---@diagnostic disable: undefined-global

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Set leader mappings before loading lazy.nvim
vim.g.mapleader = ","
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- Import our custom plugins
        { import = "plugins" },

        -- Import optional modules based on configuration
        {
            import = "modules.debugging",
            enabled = vim.g.enable_debugging_module,
            cond = function()
                return vim.g.enable_debugging_module
            end,
        },
        {
            import = "modules.testing",
            enabled = vim.g.enable_testing_module,
            cond = function()
                return vim.g.enable_testing_module
            end,
        },
        {
            import = "modules.documentation",
            enabled = vim.g.enable_docs_module,
            cond = function()
                return vim.g.enable_docs_module
            end,
        },
    },
    defaults = {
        -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
        -- have outdated releases, which may break your Neovim install.
        version = false, -- always use the latest git commit
        -- If you know what you're doing, you can set this to "stable"
    },
    install = { colorscheme = { "gruvbox" } },
    checker = {
        enabled = true, -- automatically check for plugin updates
        notify = false, -- don't notify about updates
    },
    performance = {
        cache = {
            enabled = true,
        },
        reset_packpath = true, -- reset the package path to improve startup time
        rtp = {
            -- disable some rtp plugins
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
    ui = {
        -- a number <1 is a percentage., >1 is a fixed size
        size = { width = 0.8, height = 0.8 },
        wrap = true, -- wrap the lines in the ui
        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        border = "none",
        title = nil, ---@type string only works when border is not "none"
        title_pos = "center", ---@type "center" | "left" | "right"
        -- Show pills on top of the Lazy window
        pills = true, ---@type boolean
        icons = {
            cmd = "󰘳 ",
            config = "󰒓",
            event = "󰉁",
            ft = "󰈙 ",
            init = "󰚰 ",
            import = "󰋊 ",
            keys = "󰌋 ",
            lazy = "󰒲 ",
            loaded = "󰄳",
            not_loaded = "󰚌",
            plugin = "󰏖 ",
            runtime = "󰧑 ",
            require = "󰢱 ",
            source = "󰴆 ",
            start = "󰐊",
            task = "󰔟 ",
            list = {
                "󰄳",
                "󰅂",
                "󰓎",
                "󰍴",
            },
        },
    },
    -- Custom keymaps for Lazy interface
    keys = {
        -- Use comma leader for Lazy interface too
        { "<leader>l", "<cmd>Lazy<cr>", desc = "Lazy" },
    },
})
