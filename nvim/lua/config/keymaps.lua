---@diagnostic disable: undefined-global

-- ===================================================================
-- NEOVIM KEYMAPS CONFIGURATION
-- ===================================================================
-- Core keymaps only - plugin-specific keymaps are in their respective plugin files

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

-- Clear search with <esc>
map("n", "<esc>", "<cmd>nohlsearch<cr><esc>", { desc = "Clear highlights" })

-- Better search behavior
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

-- Better default experience
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Better word wrap navigation
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- ===================================================================
-- WINDOW OPERATIONS
-- ===================================================================

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

-- Window operations (Removed - use default <C-w> commands)

-- ===================================================================
-- MOVEMENT AND EDITING
-- ===================================================================

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Buffer navigation moved to bufferline plugin config

-- ===================================================================
-- LEADER KEY OPERATIONS
-- ===================================================================

-- Plugin management
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy Plugin Manager" })

-- File operations
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save", silent = true })
vim.keymap.set("n", "<leader>wa", "<cmd>wa<cr>", { desc = "Save all buffers", silent = true })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit", silent = true })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Clear search, diff update and redraw
map("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Redraw / clear hlsearch / diff update" })

-- ===================================================================
-- CODE OPERATIONS
-- ===================================================================

-- Core diagnostic operations
map("n", "<leader>cd", function() vim.diagnostic.open_float() end, { desc = "Show diagnostics" })

-- Commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- Highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })

-- Keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- ===================================================================
-- UI TOGGLES (Simplified - use :set commands when needed)
-- ===================================================================
-- Removed excessive UI toggles - use vim commands like :set wrap, :set spell, etc.

-- ===================================================================
-- TAB OPERATIONS (Removed - use buffers instead of tabs)
-- ===================================================================
-- Use <S-h>/<S-l> for buffer navigation instead of tabs

-- ===================================================================
-- TERMINAL MODE MAPPINGS
-- ===================================================================

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

