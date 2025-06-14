---@diagnostic disable: undefined-global

-- Shared Utilities Module
-- Common utility functions used across the configuration
-- Usage: local utils = require("utils")

local M = {}

-- Safe require function that doesn't error if module doesn't exist
function M.safe_require(module)
    local ok, result = pcall(require, module)
    if ok then
        return result
    else
        vim.notify("Failed to load module: " .. module, vim.log.levels.WARN)
        return nil
    end
end

-- Check if a plugin is loaded
function M.is_plugin_loaded(plugin_name)
    local lazy_ok, lazy = pcall(require, "lazy")
    if not lazy_ok then
        return false
    end
    
    local plugins = lazy.plugins()
    for _, plugin in ipairs(plugins) do
        if plugin.name == plugin_name and plugin.loaded then
            return true
        end
    end
    return false
end

-- Get the root directory of the current project
function M.get_project_root()
    local root_patterns = { '.git', '.gitignore', 'package.json', 'Cargo.toml', 'go.mod', 'build.zig', 'CMakeLists.txt' }
    local current_dir = vim.fn.expand('%:p:h')
    
    for _, pattern in ipairs(root_patterns) do
        local root = vim.fn.finddir(pattern, current_dir .. ';')
        if root ~= '' then
            return vim.fn.fnamemodify(root, ':h')
        end
        
        local file = vim.fn.findfile(pattern, current_dir .. ';')
        if file ~= '' then
            return vim.fn.fnamemodify(file, ':h')
        end
    end
    
    return current_dir
end

-- Create a floating window with given content
function M.create_float(content, title)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        border = 'rounded',
        title = title or 'Float',
        title_pos = 'center',
    })
    
    if type(content) == 'table' then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    else
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, '\n'))
    end
    
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>close<CR>', { noremap = true, silent = true })
    
    return buf, win
end

-- Toggle a terminal window
function M.toggle_terminal(cmd, opts)
    opts = opts or {}
    local term_buf = nil
    local term_win = nil
    
    -- Check if terminal buffer exists
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == 'terminal' then
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if buf_name:match(cmd or 'term') then
                term_buf = buf
                break
            end
        end
    end
    
    -- Check if terminal window is open
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            if buf == term_buf then
                term_win = win
                break
            end
        end
    end
    
    if term_win then
        -- Terminal is open, close it
        vim.api.nvim_win_close(term_win, true)
    else
        -- Terminal is not open, create or show it
        if not term_buf then
            -- Create new terminal
            vim.cmd('split | terminal ' .. (cmd or ''))
            term_buf = vim.api.nvim_get_current_buf()
        else
            -- Show existing terminal
            vim.cmd('split')
            vim.api.nvim_win_set_buf(0, term_buf)
        end
        
        -- Resize if specified
        if opts.size then
            vim.cmd('resize ' .. opts.size)
        end
        
        -- Enter terminal mode if specified
        if opts.enter_insert ~= false then
            vim.cmd('startinsert')
        end
    end
end

-- Get the current git branch
function M.get_git_branch()
    local handle = io.popen('git branch --show-current 2>/dev/null')
    if not handle then return nil end
    
    local branch = handle:read('*a')
    handle:close()
    
    if branch and #branch > 0 then
        return vim.trim(branch)
    end
    return nil
end

-- Check if current directory is a git repository
function M.is_git_repo()
    local handle = io.popen('git rev-parse --is-inside-work-tree 2>/dev/null')
    if not handle then return false end
    
    local result = handle:read('*a')
    handle:close()
    
    return vim.trim(result) == 'true'
end

-- Debounce function calls
function M.debounce(func, timeout)
    local timer = nil
    return function(...)
        local args = {...}
        if timer then
            vim.loop.timer_stop(timer)
            vim.loop.timer_close(timer)
        end
        timer = vim.loop.new_timer()
        vim.loop.timer_start(timer, timeout, 0, function()
            vim.loop.timer_stop(timer)
            vim.loop.timer_close(timer)
            timer = nil
            vim.schedule(function()
                func(table.unpack(args))
            end)
        end)
    end
end

-- Throttle function calls
function M.throttle(func, timeout)
    local last_call = 0
    return function(...)
        local now = vim.loop.hrtime()
        if now - last_call >= timeout * 1000000 then
            last_call = now
            func(...)
        end
    end
end

-- Check if we're in a specific file type project
function M.is_project_type(type_patterns)
    local root = M.get_project_root()
    for _, pattern in ipairs(type_patterns) do
        local file_path = root .. '/' .. pattern
        if vim.fn.filereadable(file_path) == 1 or vim.fn.isdirectory(file_path) == 1 then
            return true
        end
    end
    return false
end

-- Language detection helpers
M.is_go_project = function() return M.is_project_type({'go.mod', 'go.sum', 'main.go'}) end
M.is_rust_project = function() return M.is_project_type({'Cargo.toml', 'Cargo.lock'}) end
M.is_zig_project = function() return M.is_project_type({'build.zig', 'build.zig.zon'}) end
M.is_node_project = function() return M.is_project_type({'package.json', 'node_modules'}) end
M.is_cmake_project = function() return M.is_project_type({'CMakeLists.txt', 'cmake'}) end

-- Auto-detect and suggest module enabling
function M.suggest_modules()
    local suggestions = {}
    
    -- Check if project could benefit from debugging
    if M.is_go_project() or M.is_rust_project() or M.is_zig_project() or M.is_cmake_project() then
        if not vim.g.enable_debugging_module then
            table.insert(suggestions, {
                module = 'debugging',
                reason = 'Systems programming project detected',
                enable = 'vim.g.enable_debugging_module = true'
            })
        end
    end
    
    -- Check if project has tests
    local test_patterns = {
        'test/', 'tests/', '*_test.go', '*_test.rs', '*.test.ts', '*.test.js',
        'src/test/', 'src/tests/', 'test.zig'
    }
    
    for _, pattern in ipairs(test_patterns) do
        if vim.fn.glob(pattern) ~= '' then
            if not vim.g.enable_testing_module then
                table.insert(suggestions, {
                    module = 'testing',
                    reason = 'Test files detected',
                    enable = 'vim.g.enable_testing_module = true'
                })
            end
            break
        end
    end
    
    return suggestions
end

-- Format bytes to human readable string
function M.format_bytes(bytes)
    local units = {'B', 'KB', 'MB', 'GB', 'TB'}
    local unit_index = 1
    local size = bytes
    
    while size >= 1024 and unit_index < #units do
        size = size / 1024
        unit_index = unit_index + 1
    end
    
    return string.format("%.1f %s", size, units[unit_index])
end

-- Get system information
function M.get_system_info()
    return {
        os = vim.loop.os_uname().sysname,
        arch = vim.loop.os_uname().machine,
        nvim_version = vim.version(),
        config_path = vim.fn.stdpath("config"),
        data_path = vim.fn.stdpath("data"),
        cache_path = vim.fn.stdpath("cache"),
    }
end

return M