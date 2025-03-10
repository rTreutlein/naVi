local log = require("navi.log")
local api = vim.api

local M = {}

-- Opens a prompt window and calls the callback with the content of the prompt
function M.open(cfg, callback)
    local buf = api.nvim_create_buf(false, true)
    local content = {}
    local canceled = false

    -- Automatically enter insert mode upon opening prompt
    api.nvim_create_autocmd({ "BufEnter" }, {
        buffer = buf,
        callback = function()
            api.nvim_command("stopinsert")
            api.nvim_feedkeys("i", "n", true)
        end,
    })

    api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    -- Get prompt content on every line change, and call the callback when the prompt is closed
    api.nvim_buf_attach(buf, true, {
        on_lines = function()
            content = api.nvim_buf_get_lines(buf, 0, api.nvim_buf_line_count(buf), true)
        end,
        on_detach = function()
            if canceled then
                return
            end

            vim.schedule(function()
                callback(table.concat(content, "\n"))
            end)
        end,
    })

    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    local win_height = math.ceil(height * 0.1 - 4)
    local win_width = math.ceil(width * 0.5)

    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    -- when zoomed in too much, prompt will break due to win_height being less than zero
    if win_height < 1 then
        win_height = 1
    end

    log.d(vim.inspect({
        message = "Prompt window dimensions",
        width = width,
        height = height,
        win_height = win_height,
        win_width = win_width,
        row = row,
        col = col,
    }))

    local opts = {
        style = cfg.prompt_window.style,
        border = cfg.prompt_window.border,
        relative = cfg.prompt_window.relative,
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        title = " OpenAI prompt ",
    }

    local win = api.nvim_open_win(buf, true, opts)

    -- Submit prompt on <CR> aka enter and close the window
    api.nvim_buf_set_keymap(buf, "i", "<CR>", "", {
        callback = function()
            api.nvim_win_close(win, false)
            api.nvim_command("stopinsert")
        end,
    })
    -- Cancel the prompt on <ESC> and close the window
    api.nvim_buf_set_keymap(buf, "i", "<ESC>", "", {
        callback = function()
            canceled = true

            api.nvim_win_close(win, false)
            api.nvim_command("stopinsert")
        end,
    })
end

return M
