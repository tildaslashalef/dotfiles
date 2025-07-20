---@diagnostic disable: undefined-global

return {
    -- Telescope: Fuzzy finder and search interface
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
       -- event = "VeryLazy", -- Load after everything else is ready
        version = false, -- telescope did only one release, so use HEAD for now
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "neovim/nvim-lspconfig" }, 
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                enabled = vim.fn.executable("make") == 1,
                config = function()
                    require("telescope").load_extension("fzf")
                end,
            },
        },
        keys = {
            -- Essential shortcuts only
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Search Project" },
            { "<leader>sf", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Search in File" },
            { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
            { "<leader>gf", "<cmd>Telescope git_files<cr>", desc = "Git Files" },
            {
                "<leader>sw",
                function()
                    require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })
                end,
                desc = "Search Word Under Cursor"
            },
        },
        opts = function()
            local actions = require("telescope.actions")

            return {
                defaults = {
                    prompt_prefix = "󰍉 ",
                    selection_caret = "󰅂 ",
                    multi_icon = "󰒆 ",
                    -- path_display = { "truncate" },
                    sorting_strategy = "ascending",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.55,
                            results_width = 0.8,
                        },
                        vertical = {
                            mirror = false,
                        },
                        width = 0.87,
                        height = 0.80,
                        preview_cutoff = 120,
                    },
                    mappings = {
                        i = {
                            ["<C-n>"] = actions.cycle_history_next,
                            ["<C-p>"] = actions.cycle_history_prev,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-c>"] = actions.close,
                            ["<Down>"] = actions.move_selection_next,
                            ["<Up>"] = actions.move_selection_previous,
                            ["<CR>"] = actions.select_default,
                            ["<C-x>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,
                            ["<C-u>"] = actions.preview_scrolling_up,
                            ["<C-d>"] = actions.preview_scrolling_down,
                            ["<PageUp>"] = actions.results_scrolling_up,
                            ["<PageDown>"] = actions.results_scrolling_down,
                            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["<C-l>"] = actions.complete_tag,
                            ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
                        },
                        n = {
                            ["<esc>"] = actions.close,
                            ["<CR>"] = actions.select_default,
                            ["<C-x>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,
                            ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["j"] = actions.move_selection_next,
                            ["k"] = actions.move_selection_previous,
                            ["H"] = actions.move_to_top,
                            ["M"] = actions.move_to_middle,
                            ["L"] = actions.move_to_bottom,
                            ["<Down>"] = actions.move_selection_next,
                            ["<Up>"] = actions.move_selection_previous,
                            ["gg"] = actions.move_to_top,
                            ["G"] = actions.move_to_bottom,
                            ["<C-u>"] = actions.preview_scrolling_up,
                            ["<C-d>"] = actions.preview_scrolling_down,
                            ["<PageUp>"] = actions.results_scrolling_up,
                            ["<PageDown>"] = actions.results_scrolling_down,
                            ["?"] = actions.which_key,
                        },
                    },
                },
                pickers = {
                    find_files = {
                        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                    },
                    live_grep = {
                        additional_args = function()
                            return { "--hidden" }
                        end
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                },
            }
        end,
        config = function(_, opts)
            -- Ensure LSP is available before setting up telescope
            local lspconfig_ok = pcall(require, "lspconfig")
            if not lspconfig_ok then
                vim.notify("LSP not ready, deferring telescope setup", vim.log.levels.WARN)
                vim.defer_fn(function()
                    require("telescope").setup(opts)
                end, 100)
                return
            end
            
            local telescope = require("telescope")
            telescope.setup(opts)
            
            -- Add which-key groups for essential operations
            require("which-key").add({
                { "<leader>f", group = "files" },
                { "<leader>s", group = "search" },
            })
            
            -- Removed extra file operations - use :enew or :e when needed

            -- Load extensions after setup with better error handling
            local function load_fzf_extension()
                local ok, err = pcall(telescope.load_extension, "fzf")
                if not ok then
                    vim.notify(
                        "Failed to load telescope-fzf-native extension: " .. tostring(err) ..
                        "\nTry running: :Lazy build telescope-fzf-native.nvim",
                        vim.log.levels.WARN
                    )
                    return false
                end
                return true
            end

            -- Try to load the extension, if it fails, provide helpful instructions
            if not load_fzf_extension() then
                -- Create a user command to rebuild the extension
                vim.api.nvim_create_user_command("TelescopeBuildFzf", function()
                    vim.cmd("Lazy build telescope-fzf-native.nvim")
                    vim.defer_fn(function()
                        if load_fzf_extension() then
                            vim.notify("telescope-fzf-native extension loaded successfully!", vim.log.levels.INFO)
                        end
                    end, 1000)
                end, { desc = "Build and load telescope-fzf-native extension" })

                vim.notify("Use :TelescopeBuildFzf to build and load the fzf extension", vim.log.levels.INFO)
            end
        end,
    },

    -- Neo-tree: File explorer
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        cmd = "Neotree",
        keys = {
            -- Essential explorer shortcut only
            { "<leader>e", "<cmd>Neotree toggle position=right<cr>", desc = "Explorer Toggle" },
        },
        deactivate = function()
            vim.cmd([[Neotree close]])
        end,
        init = function()
            if vim.fn.argc(-1) == 1 then
                local stat = vim.loop.fs_stat(vim.fn.argv(0))
                if stat and stat.type == "directory" then
                    require("neo-tree")
                end
            end
        end,
        opts = {
            sources = { "filesystem", "buffers", "git_status", "document_symbols" },
            open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
            filesystem = {
                bind_to_cwd = false,
                follow_current_file = { enabled = true },
                use_libuv_file_watcher = true,
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                    hide_gitignored = false,
                    hide_by_name = {
                        "node_modules"
                    },
                    never_show = {
                        ".DS_Store",
                        "thumbs.db"
                    },
                },
            },
            window = {
                position = "right",
                width = 40,
                mappings = {
                    ["<space>"] = "none",
                    
                    -- Essential daily operations only
                    ["<cr>"] = "open",
                    ["a"] = "add",           -- Create file
                    ["A"] = "add_directory", -- Create directory  
                    ["d"] = "delete",        -- Delete file/dir
                    ["r"] = "rename",        -- Rename file/dir
                    ["R"] = "refresh",       -- Refresh tree
                    ["H"] = "toggle_hidden", -- Show/hide dotfiles
                    ["Y"] = {
                        function(state)
                            local node = state.tree:get_node()
                            local path = node:get_id()
                            vim.fn.setreg("+", path, "c")
                        end,
                        desc = "Copy Path",
                    },
                    ["?"] = "show_help",
                },
            },
            default_component_configs = {
                indent = {
                    with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander",
                },
                git_status = {
                    symbols = {
                        -- Change type
                        added     = " ",
                        modified  = " ",
                        deleted   = " ",
                        renamed   = " ",
                        -- Status type
                        untracked = " ",
                        ignored   = " ",
                        unstaged  = " ",
                        staged    = " ",
                        conflict  = " ",
                    }
                },
            },
        },
        config = function(_, opts)
            local function on_move(data)
                -- Standalone LSP rename functionality
                local clients = vim.lsp.get_active_clients()
                for _, client in ipairs(clients) do
                    if client.supports_method("workspace/willRenameFiles") then
                        local resp = client.request_sync("workspace/willRenameFiles", {
                            files = {
                                {
                                    oldUri = vim.uri_from_fname(data.source),
                                    newUri = vim.uri_from_fname(data.destination),
                                },
                            },
                        })
                        if resp and resp.result ~= nil then
                            vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
                        end
                    end
                end
            end

            local events = require("neo-tree.events")
            opts.event_handlers = opts.event_handlers or {}
            vim.list_extend(opts.event_handlers, {
                { event = events.FILE_MOVED,   handler = on_move },
                { event = events.FILE_RENAMED, handler = on_move },
            })
            require("neo-tree").setup(opts)
            
            -- Explorer group simplified
            require("which-key").add({
                { "<leader>e", group = "explorer" },
            })
            
            vim.api.nvim_create_autocmd("TermClose", {
                pattern = "*lazygit",
                callback = function()
                    if package.loaded["neo-tree.sources.git_status"] then
                        require("neo-tree.sources.git_status").refresh()
                    end
                end,
            })
        end,
    },

    -- Bufferline: Buffer tabs
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        keys = {
            -- Essential buffer management shortcuts only
            { "<leader>bb", "<cmd>e #<cr>",                   desc = "Switch to other buffer" },
            { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete other buffers" },
            { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",   desc = "Prev buffer" },
            { "<S-l>",      "<cmd>BufferLineCycleNext<cr>",   desc = "Next buffer" },
        },
        opts = {
            options = {
                close_command = function(n)
                    local ok, mini_bufremove = pcall(require, "mini.bufremove")
                    if ok then
                        mini_bufremove.delete(n, false)
                    else
                        vim.cmd("bdelete " .. n)
                    end
                end,
                right_mouse_command = function(n)
                    local ok, mini_bufremove = pcall(require, "mini.bufremove")
                    if ok then
                        mini_bufremove.delete(n, false)
                    else
                        vim.cmd("bdelete " .. n)
                    end
                end,
                diagnostics = "nvim_lsp",
                always_show_bufferline = false,
                diagnostics_indicator = function(_, _, diag)
                    local icons = {
                        Error = "󰅚 ",
                        Warn = "󰀪 ",
                        Info = "󰋽 ",
                        Hint = "󰌶 ",
                    }
                    local ret = (diag.error and icons.Error .. diag.error .. " " or "")
                        .. (diag.warning and icons.Warn .. diag.warning or "")
                    return vim.trim(ret)
                end,
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "Neo-tree",
                        highlight = "Directory",
                        text_align = "right",
                        separator = true,
                    },
                },
            },
        },
        config = function(_, opts)
            require("bufferline").setup(opts)
            
            -- Add which-key groups for Buffer operations
            require("which-key").add({
                { "<leader>b", group = "buffers" },
            })
            
            -- Fix bufferline when restoring a session
            vim.api.nvim_create_autocmd("BufAdd", {
                callback = function()
                    vim.schedule(function()
                        pcall(function()
                            require("bufferline").refresh()
                        end)
                    end)
                end,
            })
        end,
    },

    -- Lualine: Status line
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        init = function()
            vim.g.lualine_laststatus = vim.o.laststatus
            if vim.fn.argc(-1) > 0 then
                -- set an empty statusline till lualine loads
                vim.o.statusline = " "
            else
                -- hide the statusline on the starter page
                vim.o.laststatus = 0
            end
        end,
        opts = function()
            vim.o.laststatus = vim.g.lualine_laststatus or 3

            -- Default icons fallback
            local icons = {
                diagnostics = {
                    Error = "󰅚 ",
                    Warn = "󰀪 ",
                    Info = "󰋽 ",
                    Hint = "󰌶 ",
                },
                git = {
                    added = "󰐕 ",
                    modified = "󰜥 ",
                    removed = "󰍵 ",
                },
            }

            return {
                options = {
                    theme = "gruvbox",
                    globalstatus = true,
                    disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch" },

                    lualine_c = {
                        {
                            "filename",
                            path = 1, -- Show relative path
                            shorting_target = 40,
                        },
                        {
                            "diagnostics",
                            symbols = {
                                error = icons.diagnostics.Error,
                                warn = icons.diagnostics.Warn,
                                info = icons.diagnostics.Info,
                                hint = icons.diagnostics.Hint,
                            },
                        },
                        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                    },
                    lualine_x = {
                        {
                            "diff",
                            symbols = {
                                added = icons.git.added,
                                modified = icons.git.modified,
                                removed = icons.git.removed,
                            },
                            source = function()
                                local gitsigns = vim.b.gitsigns_status_dict
                                if gitsigns then
                                    return {
                                        added = gitsigns.added,
                                        modified = gitsigns.changed,
                                        removed = gitsigns.removed,
                                    }
                                end
                            end,
                        },
                        {
                            function()
                                local ok, copilot_api = pcall(require, "copilot.api")
                                local ok_client, copilot_client = pcall(require, "copilot.client")
                                
                                if not ok or not ok_client then
                                    return ""
                                end

                                -- Check if copilot is disabled first
                                if copilot_client.is_disabled() then
                                    return "󰚩" -- Disabled icon (crossed out or different)
                                end

                                local status = copilot_api.status.data
                                if not status then
                                    return "󰚩"
                                end

                                if status.status == "InProgress" then
                                    return "󰚩"
                                elseif status.status == "Warning" then
                                    return "󰚩"
                                elseif status.status == "Normal" then
                                    return "󰘦"
                                else
                                    return "󰚩"
                                end
                            end,
                            color = function()
                                local ok, copilot_api = pcall(require, "copilot.api")
                                local ok_client, copilot_client = pcall(require, "copilot.client")
                                
                                if not ok or not ok_client then
                                    return { fg = "#6c7086" }
                                end

                                -- Check if copilot is disabled first
                                if copilot_client.is_disabled() then
                                    return { fg = "#f38ba8" } -- Red color for disabled
                                end

                                local status = copilot_api.status.data
                                if not status then
                                    return { fg = "#6c7086" }
                                end

                                if status.status == "InProgress" then
                                    return { fg = "#f9e2af" }
                                elseif status.status == "Warning" then
                                    return { fg = "#fab387" }
                                elseif status.status == "Normal" then
                                    return { fg = "#a6e3a1" }
                                else
                                    return { fg = "#6c7086" }
                                end
                            end,
                            padding = { left = 1, right = 1 },
                        },
                    },
                    lualine_y = {
                        { "progress", separator = " ",                  padding = { left = 1, right = 0 } },
                        { "location", padding = { left = 0, right = 1 } },
                    },
                    lualine_z = {
                        function()
                            return " " .. os.date("%R")
                        end,
                    },
                },
                extensions = { "neo-tree", "lazy" },
            }
        end,
    },

    -- Dashboard/Start screen
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        enabled = true,
        init = false,
        opts = function()
            local dashboard = require("alpha.themes.dashboard")
            local logo = [[
        ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
        ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
        ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
        ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
        ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
        ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]]

            dashboard.section.header.val = vim.split(logo, "\n")

            -- stylua: ignore
            dashboard.section.buttons.val = {
                dashboard.button("f", "󰈞 " .. " Find file", "<cmd> Telescope find_files <cr>"),
                dashboard.button("n", "󰈔 " .. " New file", "<cmd> ene <BAR> startinsert <cr>"),
                dashboard.button("r", "󰄉 " .. " Recent files", "<cmd> Telescope oldfiles <cr>"),
                dashboard.button("g", "󰊄 " .. " Find text", "<cmd> Telescope live_grep <cr>"),
                dashboard.button("c", "󰒓 " .. " Config", "<cmd> e $MYVIMRC | cd %:p:h <cr>"),
                dashboard.button("s", "󰁯 " .. " Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),
                dashboard.button("x", "󰏖 " .. " Lazy Extras", "<cmd> LazyExtras <cr>"),
                dashboard.button("l", "󰒲 " .. " Lazy", "<cmd> Lazy <cr>"),
                dashboard.button("q", "󰗼 " .. " Quit", "<cmd> qa <cr>"),
            }
            for _, button in ipairs(dashboard.section.buttons.val) do
                button.opts.hl = "GruvboxGreen"
                button.opts.hl_shortcut = "GruvboxYellow"
            end
            dashboard.section.header.opts.hl = "GruvboxGreen"
            dashboard.section.buttons.opts.hl = "GruvboxFg1"
            dashboard.section.footer.opts.hl = "GruvboxBlue"
            dashboard.opts.layout[1].val = 8
            return dashboard
        end,
        config = function(_, dashboard)
            vim.api.nvim_set_hl(0, "GruvboxGreen", { fg = "#b8bb26", bold = true })
            vim.api.nvim_set_hl(0, "GruvboxYellow", { fg = "#fabd2f", bold = true })
            vim.api.nvim_set_hl(0, "GruvboxOrange", { fg = "#fe8019", bold = true })
            vim.api.nvim_set_hl(0, "GruvboxBlue", { fg = "#83a598", italic = true })
            vim.api.nvim_set_hl(0, "GruvboxAqua", { fg = "#8ec07c", italic = true })
            vim.api.nvim_set_hl(0, "GruvboxFg1", { fg = "#ebdbb2" })


            -- close Lazy and re-open when the dashboard is ready
            if vim.o.filetype == "lazy" then
                vim.cmd.close()
                vim.api.nvim_create_autocmd("User", {
                    once = true,
                    pattern = "AlphaReady",
                    callback = function()
                        ---@diagnostic disable-next-line: different-requires
                        require("lazy").show()
                    end,
                })
            end

            require("alpha").setup(dashboard.opts)

            vim.api.nvim_create_autocmd("User", {
                once = true,
                pattern = "LazyDone",
                callback = function()
                    ---@diagnostic disable-next-line: different-requires
                    local stats = require("lazy").stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    dashboard.section.footer.val = "⚡ Neovim loaded "
                        .. stats.loaded
                        .. "/"
                        .. stats.count
                        .. " plugins in "
                        .. ms
                        .. "ms"
                    pcall(vim.cmd.AlphaRedraw)
                end,
            })
        end,
    },

    -- Noice: Enhanced UI for messages, cmdline and popupmenu
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        any = {
                            { find = "%d+L, %d+B" },
                            { find = "; after #%d+" },
                            { find = "; before #%d+" },
                        },
                    },
                    view = "mini",
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = true,
                lsp_doc_border = false,
            },
        },
        -- Removed excess noice shortcuts - plugin works fine with defaults
    },


    -- Enhanced search and replace (Spectre)
    {
        "nvim-pack/nvim-spectre",
        cmd = "Spectre",
        opts = { open_cmd = "noswapfile vnew" },
        keys = {
            { "<leader>sr", function() require("spectre").toggle() end,                                 desc = "Replace in files (Spectre)" },
            { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end,      desc = "Search current word" },
            { "<leader>sw", function() require("spectre").open_visual() end,                            mode = "v",                         desc = "Search current word" },
            { "<leader>sp", function() require("spectre").open_file_search({ select_word = true }) end, desc = "Search on current file" },
        },
    },
}
