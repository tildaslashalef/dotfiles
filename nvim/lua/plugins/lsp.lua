---@diagnostic disable: undefined-global

return {
    -- Mason: LSP installer and manager
    {
        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
        opts = {
            ensure_installed = {
                -- Language servers (Go + Zig + C + Lua only)
                "gopls",
                "zls",
                "clangd",
                "lua-language-server",

                -- Formatters
                "gofumpt",
                "goimports",
                "clang-format",
                "stylua",

                -- Linters
                "luacheck",
            },
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "󰄳",
                    package_pending = "󰔟",
                    package_uninstalled = "󰚌"
                }
            }
        },
    },

    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        opts = {
            -- Options for vim.diagnostic.config()
            diagnostics = {
                underline = true,
                update_in_insert = false,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●",
                    -- Only show errors and warnings, hide hints and info
                    -- severity = { min = vim.diagnostic.severity.WARN },
                },
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "󰅚",
                        [vim.diagnostic.severity.WARN] = "󰀪",
                        [vim.diagnostic.severity.HINT] = "󰌶",
                        [vim.diagnostic.severity.INFO] = "󰋽",
                    },
                },
            },
            -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
            inlay_hints = {
                enabled = true,
            },
            -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
            codelens = {
                enabled = false,
            },
            -- Enable lsp cursor word highlighting
            document_highlight = {
                enabled = true,
            },
            -- add any global capabilities here
            capabilities = {},
            -- options for vim.lsp.buf.format
            format = {
                formatting_options = nil,
                timeout_ms = nil,
            },
            -- LSP Server Settings
            servers = {
                -- Go language server
                gopls = {
                    settings = {
                        gopls = {
                            gofumpt = true,
                            codelenses = {
                                gc_details = false,
                                generate = true,
                                regenerate_cgo = true,
                                run_govulncheck = true,
                                test = true,
                                tidy = true,
                                upgrade_dependency = true,
                                vendor = true,
                            },
                            hints = {
                                assignVariableTypes = true,
                                compositeLiteralFields = true,
                                compositeLiteralTypes = true,
                                constantValues = true,
                                functionTypeParameters = true,
                                parameterNames = true,
                                rangeVariableTypes = true,
                            },
                            analyses = {
                                fieldalignment = true,
                                nilness = true,
                                unusedparams = true,
                                unusedwrite = true,
                                useany = true,
                            },
                            usePlaceholders = true,
                            completeUnimported = true,
                            staticcheck = true,
                            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                            semanticTokens = true,
                        },
                    },
                },

                -- Zig language server
                zls = {
                    settings = {
                        zls = {
                            enable_inlay_hints = true,
                            enable_snippets = true,
                            warn_style = true,
                            enable_semantic_tokens = true,
                            operator_completions = true,
                            include_at_in_builtins = true,
                            max_detail_length = 1048576,
                        }
                    }
                },

                -- C language server
                clangd = {
                    keys = {
                        { "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C)" },
                    },
                    root_dir = function(fname)
                        return require("lspconfig.util").root_pattern(
                            "Makefile",
                            "configure.ac",
                            "configure.in",
                            "config.h.in",
                            "meson.build",
                            "meson_options.txt",
                            "build.ninja"
                        )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
                            fname
                        ) or require("lspconfig.util").find_git_ancestor(fname)
                    end,
                    capabilities = {
                        offsetEncoding = { "utf-16" },
                    },
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--completion-style=detailed",
                        "--function-arg-placeholders",
                        "--fallback-style=llvm",
                    },
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                },

                -- Lua language server
                lua_ls = {
                    settings = {
                        Lua = {
                            workspace = {
                                checkThirdParty = false,
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                            misc = {
                                parameters = {
                                    "--log-level=trace",
                                },
                            },
                            hint = {
                                enable = true,
                                setType = false,
                                paramType = true,
                                paramName = "Disable",
                                semicolon = "Disable",
                                arrayIndex = "Disable",
                            },
                            doc = {
                                privateName = { "^_" },
                            },
                            type = {
                                castNumberToInteger = true,
                            },
                            diagnostics = {
                                disable = { "incomplete-signature-doc", "trailing-space" },
                                groupSeverity = {
                                    strong = "Warning",
                                    strict = "Warning",
                                },
                                groupFileStatus = {
                                    ["ambiguity"] = "Opened",
                                    ["await"] = "Opened",
                                    ["codestyle"] = "None",
                                    ["duplicate"] = "Opened",
                                    ["global"] = "Opened",
                                    ["luadoc"] = "Opened",
                                    ["redefined"] = "Opened",
                                    ["strict"] = "Opened",
                                    ["strong"] = "Opened",
                                    ["type-check"] = "Opened",
                                    ["unbalanced"] = "Opened",
                                    ["unused"] = "Opened",
                                },
                                unusedLocalExclude = { "_*" },
                            },
                            format = {
                                enable = false,
                                defaultConfig = {
                                    indent_style = "space",
                                    indent_size = "2",
                                    continuation_indent_size = "2",
                                },
                            },
                        },
                    },
                },
            },
            -- Additional server setup functions
            setup = {},
        },
        config = function(_, opts)
            -- Safe utility function loading
            local function safe_require(module)
                local ok, result = pcall(require, module)
                if not ok then
                    return nil
                end
                return result
            end

            -- Setup diagnostic signs using modern API
            if type(opts.diagnostics.signs) ~= "boolean" then
                vim.diagnostic.config({
                    signs = {
                        text = opts.diagnostics.signs.text
                    }
                })
            end

            -- Custom on_attach function for LSP features
            local function on_attach(client, buffer)
                -- Enable inlay hints if supported
                if opts.inlay_hints.enabled and client.supports_method("textDocument/inlayHint") then
                    vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
                end

                -- Enable code lens if supported
                if opts.codelens.enabled and client.supports_method("textDocument/codeLens") then
                    vim.lsp.codelens.refresh()
                    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                        buffer = buffer,
                        callback = vim.lsp.codelens.refresh,
                    })
                end

                -- Enable document highlight if supported
                if opts.document_highlight.enabled and client.supports_method("textDocument/documentHighlight") then
                    local highlight_augroup = vim.api.nvim_create_augroup("lsp_highlight", { clear = false })
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = buffer,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })
                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = buffer,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })
                end
            end

            vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

            local servers = opts.servers
            local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                has_cmp and cmp_nvim_lsp.default_capabilities() or {},
                opts.capabilities or {}
            )

            local function setup(server)
                local server_opts = vim.tbl_deep_extend("force", {
                    capabilities = vim.deepcopy(capabilities),
                    on_attach = on_attach,
                }, servers[server] or {})

                if opts.setup[server] then
                    if opts.setup[server](server, server_opts) then
                        return
                    end
                elseif opts.setup["*"] then
                    if opts.setup["*"](server, server_opts) then
                        return
                    end
                end
                require("lspconfig")[server].setup(server_opts)
            end

            -- get all the servers that are available through mason-lspconfig
            local have_mason, mlsp = pcall(require, "mason-lspconfig")
            local all_mslp_servers = {}
            if have_mason then
                all_mslp_servers = mlsp.get_available_servers()
            end

            local ensure_installed = {} ---@type string[]
            for server, server_opts in pairs(servers) do
                if server_opts then
                    server_opts = server_opts == true and {} or server_opts
                    -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
                    if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
                        setup(server)
                    else
                        ensure_installed[#ensure_installed + 1] = server
                    end
                end
            end

            if have_mason then
                mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
            end

            -- Handle deno/ts_ls conflict
            local lspconfig = require("lspconfig")
            if lspconfig.denols and lspconfig.ts_ls then
                local is_deno = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")
                -- Simple conflict resolution - prefer deno in deno projects
                vim.api.nvim_create_autocmd("BufReadPre", {
                    callback = function()
                        local root = vim.fn.getcwd()
                        if is_deno(root) then
                            vim.g.disable_ts_ls = true
                        end
                    end,
                })
            end
            
            -- Add which-key groups for LSP/Code operations
            require("which-key").add({
                { "<leader>c", group = "code" },
            })
            
            -- LSP Keymaps
            local map = vim.keymap.set
            map("n", "<leader>ca", function() vim.lsp.buf.code_action() end, { desc = "Code actions" })
            map("n", "<leader>cr", function() vim.lsp.buf.rename() end, { desc = "Rename" })
            map({ "n", "v" }, "<leader>cf", function() require("conform").format() end, { desc = "Format" })
            map("n", "<leader>cd", function() vim.diagnostic.open_float() end, { desc = "Show diagnostics" })
        end,
    },

    -- Formatters
    {
        "stevearc/conform.nvim",
        dependencies = { "mason.nvim" },
        lazy = true,
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>cF",
                function()
                    require("conform").format({ formatters = { "injected" } })
                end,
                mode = { "n", "v" },
                desc = "Format Injected Langs",
            },
        },
        init = function()
            -- Simple formatting setup
            vim.api.nvim_create_user_command("Format", function()
                require("conform").format({ bufnr = vim.api.nvim_get_current_buf() })
            end, {})
        end,
        opts = {
            formatters_by_ft = {
                go = { "goimports", "gofumpt" },
                zig = { "zigfmt" },
                c = { "clang-format" },
                lua = { "stylua" },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
            formatters = {
                goimports = {
                    prepend_args = { "-local", "github.com/tildaslashalef" }, -- Adjust as needed
                },
                ["clang-format"] = {
                    prepend_args = { "--style=llvm" },
                },
            },
        },
    },

    -- Linting
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                -- Only essential linting for our supported languages
                lua = { "luacheck" },
            }

            local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = lint_augroup,
                callback = function()
                    lint.try_lint()
                end,
            })

            vim.keymap.set("n", "<leader>cl", function()
                lint.try_lint()
            end, { desc = "Trigger linting for current file" })
        end,
    },

    -- Enhanced LSP UI
    {
        "glepnir/lspsaga.nvim",
        event = "LspAttach",
        config = function()
            require("lspsaga").setup({
                ui = {
                    border = "rounded",
                    devicon = true,
                    title = true,
                    expand = "",
                    collapse = "",
                    code_action = "💡",
                    incoming = " ",
                    outgoing = " ",
                    hover = " ",
                    kind = {},
                },
                lightbulb = {
                    enable = false, -- Disable to avoid conflicts
                },
                symbol_in_winbar = {
                    enable = false, -- We use other plugins for this
                },
                outline = {
                    win_position = "right",
                    win_with = "",
                    win_width = 30,
                    auto_preview = true,
                    auto_refresh = true,
                    auto_close = true,
                    custom_sort = nil,
                    keys = {
                        jump = "o",
                        expand_collapse = "u",
                        quit = "q",
                    },
                },
            })
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        }
    },
}
