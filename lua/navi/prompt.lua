local api = vim.api

local M = {}

function M.open(parent_buffer, cursor_start, cursor_end)
    if cursor_end == nil then
        cursor_end = cursor_start
    end

    print(parent_buffer, cursor_start, cursor_end)

    local buf = api.nvim_create_buf(false, true)

    local content = {}

    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    api.nvim_buf_attach(buf, true, {
        on_lines = function()
            content = api.nvim_buf_get_lines(buf, 0, api.nvim_buf_line_count(buf), true)
        end,
        on_detach = function()
            vim.schedule(function()
                api.nvim_buf_set_lines(parent_buffer, cursor_start, cursor_end, false, content)
            end)
        end,
    })

    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    local win_height = math.ceil(height * 0.1 - 4)
    local win_width = math.ceil(width * 0.5)

    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)
    
    local opts = {
        style = "minimal",
        border = "single",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col
    }

    win = api.nvim_open_win(buf, true, opts)

    api.nvim_buf_set_keymap(buf, "i", "<CR>", "", {callback = function() api.nvim_win_close(win, false) end})
end

return M
