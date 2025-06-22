---@diagnostic disable: undefined-global

-- ===================================================================
-- NEOVIM KEYMAPS CONFIGURATION
-- ===================================================================
-- Single source of truth for all keymaps
-- Organized by category with clear documentation

local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
        opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- ===================================================================
-- CORE VIM KEYMAPS
-- ===================================================================
-- Basic vim improvements, navigation, editing

-- Clear search with <esc>
map("n", "<esc>", "<cmd>nohlsearch<cr><esc>", { desc = "Clear highlights" })

-- Better search behavior - https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Disable arrow keys in normal mode
-- map("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
-- map("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
-- map("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
-- map("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Better default experience
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Better word wrap navigation
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Window resizing
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Clear search, diff update and redraw
map("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Redraw / clear hlsearch / diff update" })

-- Commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- Highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })

-- Keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- ===================================================================
-- LEADER KEY OPERATIONS
-- ===================================================================
-- All <leader> prefixed keymaps organized by category

-- Force <leader>w to save file (bypass lazy.nvim check)
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save", silent = true })
vim.keymap.set("n", "<leader>wa", "<cmd>wa<cr>", { desc = "Save all buffers", silent = true })

-- Lazy Plugin Manager
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>L", function()
    ---@diagnostic disable-next-line: different-requires
    require("lazy").home()
end, { desc = "Lazy Plugin Manager" })

-- ===================================================================
-- FILE OPERATIONS (<leader>f*)
-- ===================================================================
-- Note: Telescope file operations are defined in plugins/ui.lua

map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })

-- ===================================================================
-- SEARCH OPERATIONS (<leader>s*)
-- ===================================================================
-- Note: Telescope search operations are defined in plugins/ui.lua

map("n", "<leader>sr", function() require("spectre").toggle() end, { desc = "Search/Replace (Spectre)" })
map({ "n", "v" }, "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, { desc = "Search word under cursor" })

-- ===================================================================
-- GIT OPERATIONS
-- ===================================================================

-- Git main operations
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit (full git interface)" })
map("n", "<leader>gd", function() require("gitsigns").diffthis() end, { desc = "Git diff current file" })
map("n", "<leader>gD", function() require("gitsigns").diffthis("~") end, { desc = "Git diff project" })
map("n", "<leader>gb", function() require("gitsigns").blame_line({ full = true }) end, { desc = "Git blame current line" })

-- Git hunks operations
map({ "n", "v" }, "<leader>ghs", function() require("gitsigns").stage_hunk() end, { desc = "Stage hunk" })
map("n", "<leader>ghu", function() require("gitsigns").undo_stage_hunk() end, { desc = "Unstage hunk" })
map({ "n", "v" }, "<leader>ghr", function() require("gitsigns").reset_hunk() end, { desc = "Reset hunk" })
map("n", "<leader>ghp", function() require("gitsigns").preview_hunk() end, { desc = "Preview hunk" })
map("n", "<leader>ghd", function() require("gitsigns").diffthis() end, { desc = "Diff hunk" })

-- ===================================================================
-- CODE OPERATIONS (<leader>c*)
-- ===================================================================

map("n", "<leader>ca", function() vim.lsp.buf.code_action() end, { desc = "Code actions" })
map("n", "<leader>cr", function() vim.lsp.buf.rename() end, { desc = "Rename" })
map({ "n", "v" }, "<leader>cf", function() require("conform").format() end, { desc = "Format" })
map({ "n", "v" }, "<leader>cF", function() require("conform").format({ formatters = { "injected" } }) end, { desc = "Format Injected Langs" })
map("n", "<leader>cd", function() vim.diagnostic.open_float() end, { desc = "Show diagnostics" })
map("n", "<leader>cl", function() require("lint").try_lint() end, { desc = "Trigger linting" })
map("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })

-- Trouble.nvim
map("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })

-- ===================================================================
-- BUFFER OPERATIONS (<leader>b*)
-- ===================================================================

map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to other buffer" })
map("n", "<leader>bd", function() require("mini.bufremove").delete(0, false) end, { desc = "Delete buffer" })
map("n", "<leader>bD", function() require("mini.bufremove").delete(0, true) end, { desc = "Delete buffer (force)" })
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Toggle pin" })
map("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Delete non-pinned buffers" })
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Delete other buffers" })
map("n", "<leader>br", "<cmd>BufferLineCloseRight<cr>", { desc = "Delete buffers to the right" })
map("n", "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", { desc = "Delete buffers to the left" })

-- ===================================================================
-- EXPLORER OPERATIONS (<leader>e*)
-- ===================================================================

map("n", "<leader>ee", function() vim.cmd("Neotree toggle") end, { desc = "Toggle Explorer" })
map("n", "<leader>ef", function() vim.cmd("Neotree focus filesystem") end, { desc = "Focus Filesystem" })
map("n", "<leader>eb", function() vim.cmd("Neotree buffers") end, { desc = "Show Buffers" })
map("n", "<leader>eg", function() vim.cmd("Neotree git_status") end, { desc = "Git Status" })
map("n", "<leader>es", function() vim.cmd("Neotree document_symbols") end, { desc = "Document Symbols" })
map("n", "<leader>ec", function() vim.cmd("Neotree close") end, { desc = "Close Explorer" })
map("n", "<leader>er", function() vim.cmd("Neotree reveal") end, { desc = "Reveal Current File" })
map("n", "<leader>eR", function() vim.cmd("Neotree refresh") end, { desc = "Refresh Explorer" })

-- Explorer file operations
map("n", "<leader>enf", function()
    local input = vim.fn.input("New file name: ")
    if input ~= "" then
        local current_dir = vim.fn.expand("%:p:h")
        local file_path = current_dir .. "/" .. input
        vim.cmd("edit " .. file_path)
    end
end, { desc = "New File" })

map("n", "<leader>end", function()
    local input = vim.fn.input("New directory name: ")
    if input ~= "" then
        local current_dir = vim.fn.expand("%:p:h")
        local dir_path = current_dir .. "/" .. input
        vim.fn.mkdir(dir_path, "p")
        vim.notify("Created directory: " .. dir_path)
    end
end, { desc = "New Directory" })

-- ===================================================================
-- TESTING OPERATIONS (<leader>t*)
-- ===================================================================

map("n", "<leader>tr", function() require("neotest").run.run() end, { desc = "Test: Run nearest" })
map("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Test: Run file" })
map("n", "<leader>tF", function() require("neotest").run.run(vim.fn.getcwd()) end, { desc = "Test: Run all" })
map("n", "<leader>tl", function() require("neotest").run.run_last() end, { desc = "Test: Run last" })
map("n", "<leader>td", function() require("neotest").run.run({strategy = "dap"}) end, { desc = "Test: Debug nearest" })
map("n", "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, { desc = "Test: Show output" })
map("n", "<leader>tO", function() require("neotest").output_panel.toggle() end, { desc = "Test: Toggle output panel" })
map("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Test: Toggle summary" })
map("n", "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, { desc = "Test: Watch file" })
map("n", "<leader>tW", function() require("neotest").watch.toggle(vim.fn.getcwd()) end, { desc = "Test: Watch all" })
map("n", "<leader>tS", function() require("neotest").run.stop() end, { desc = "Test: Stop" })

-- Test navigation
map("n", "[t", function() require("neotest").jump.prev({ status = "failed" }) end, { desc = "Test: Previous failed" })
map("n", "]t", function() require("neotest").jump.next({ status = "failed" }) end, { desc = "Test: Next failed" })

-- Test coverage
map("n", "<leader>tc", "<cmd>Coverage<cr>", { desc = "Test: Load coverage" })
map("n", "<leader>tC", "<cmd>CoverageToggle<cr>", { desc = "Test: Toggle coverage" })

-- ===================================================================
-- DEBUGGING OPERATIONS (<leader>d*)
-- ===================================================================

-- Basic debugging controls
map("n", "<F5>", function() require("dap").continue() end, { desc = "Debug: Continue" })
map("n", "<F10>", function() require("dap").step_over() end, { desc = "Debug: Step Over" })
map("n", "<F11>", function() require("dap").step_into() end, { desc = "Debug: Step Into" })
map("n", "<F12>", function() require("dap").step_out() end, { desc = "Debug: Step Out" })

-- Breakpoint management
map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Debug: Toggle Breakpoint" })
map("n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Debug: Conditional Breakpoint" })
map("n", "<leader>dc", function() require("dap").clear_breakpoints() end, { desc = "Debug: Clear Breakpoints" })

-- Session management
map("n", "<leader>dd", function() require("dap").continue() end, { desc = "Debug: Start/Continue" })
map("n", "<leader>ds", function() require("dap").close() end, { desc = "Debug: Stop" })
map("n", "<leader>dr", function() require("dap").restart() end, { desc = "Debug: Restart" })

-- REPL and evaluation
map("n", "<leader>dR", function() require("dap").repl.open() end, { desc = "Debug: Open REPL" })
map("n", "<leader>dl", function() require("dap").run_last() end, { desc = "Debug: Run Last" })
map("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Debug UI" })
map({ "n", "v" }, "<leader>de", function() require("dapui").eval() end, { desc = "Debug Eval" })

-- ===================================================================
-- TERMINAL OPERATIONS (<leader>tt*)
-- ===================================================================

map("n", "<leader>tt", "<cmd>terminal<cr>", { desc = "Open terminal" })
map("n", "<leader>ttf", "<cmd>split | terminal<cr>", { desc = "Terminal in split" })
map("n", "<leader>tth", "<cmd>split | terminal<cr>", { desc = "Horizontal terminal" })
map("n", "<leader>ttv", "<cmd>vsplit | terminal<cr>", { desc = "Vertical terminal" })

-- ===================================================================
-- UI TOGGLES (<leader>u*)
-- ===================================================================

map("n", "<leader>ub", function()
    vim.o.background = vim.o.background == "dark" and "light" or "dark"
end, { desc = "Toggle background" })

map("n", "<leader>uc", function()
    vim.o.conceallevel = vim.o.conceallevel > 0 and 0 or 2
end, { desc = "Toggle conceal" })

map("n", "<leader>uf", function()
    vim.g.autoformat = not vim.g.autoformat
    vim.notify("Autoformat " .. (vim.g.autoformat and "enabled" or "disabled"))
end, { desc = "Toggle format on save" })

map("n", "<leader>us", function()
    vim.o.spell = not vim.o.spell
end, { desc = "Toggle spelling" })

map("n", "<leader>uw", function()
    vim.o.wrap = not vim.o.wrap
end, { desc = "Toggle word wrap" })

map("n", "<leader>uL", function()
    vim.o.relativenumber = not vim.o.relativenumber
end, { desc = "Toggle relative line numbers" })

map("n", "<leader>ul", function()
    vim.o.number = not vim.o.number
end, { desc = "Toggle line numbers" })

map("n", "<leader>ud", function()
    local enabled = vim.diagnostic.is_enabled()
    if enabled then
        vim.diagnostic.enable(false)
        vim.notify("Diagnostics disabled", vim.log.levels.INFO)
    else
        vim.diagnostic.enable(true)
        vim.notify("Diagnostics enabled", vim.log.levels.INFO)
    end
end, { desc = "Toggle diagnostics" })

map("n", "<leader>un", function()
    require("notify").dismiss({ silent = true, pending = true })
end, { desc = "Dismiss notifications" })

map("n", "<leader>up", function()
    vim.g.minipairs_disable = not vim.g.minipairs_disable
end, { desc = "Toggle auto pairs" })

-- ===================================================================
-- SESSION MANAGEMENT (<leader>q*)
-- ===================================================================

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore Session" })
map("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore Last Session" })
map("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't Save Current Session" })

-- ===================================================================
-- WINDOW OPERATIONS (<leader>W*)
-- ===================================================================

map("n", "<leader>Ww", "<C-W>p", { desc = "Other window", remap = true })
map("n", "<leader>Wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>W-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>W|", "<C-W>v", { desc = "Split window right", remap = true })

-- ===================================================================
-- TAB OPERATIONS (<leader><tab>*)
-- ===================================================================

map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- ===================================================================
-- DIAGNOSTICS/QUICKFIX (<leader>x*)
-- ===================================================================

-- Native vim lists
map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

-- Trouble.nvim enhanced lists
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
map("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
map("n", "<leader>xc", "<cmd>TroubleClose<cr>", { desc = "Close Trouble Window" })

-- Diagnostic navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })


-- ===================================================================
-- PLUGIN-SPECIFIC KEYMAPS
-- ===================================================================
-- Direct plugin keymaps and special cases

-- Terminal mode mappings
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- Oil.nvim
map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

