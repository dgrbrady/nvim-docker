local popup_ok, Popup = pcall(require, 'nui.popup')
if popup_ok == false then
    vim.notify('NUI not installed, please install it from MunifTanjim/nui.nvim')
    return
end

local keymaps = require('nvim-docker.popup-keymaps')
local state = require('nvim-docker.popup-state')
local tree = require('nvim-docker.tree')
local event = require('nui.utils.autocmd').event
local _M = {}

function _M.create_popup(top_text, bottom_text, cb)
    local popup = Popup({
        enter = true,
        focusable = true,
        border = {
            style = 'rounded',
            text = {
                top = top_text,
                top_align = 'center',
                bottom = bottom_text
            },
        },
        position = '50%',
        size = {
            width = '80%',
            height = '60%',
        },
    })

    popup:mount()

    -- unmount component when cursor leaves buffer
    popup:on(event.BufLeave, function()
        state.popup = nil
        state.tree = nil
        state.timer_stopped = true
        local function unmount()
            popup:unmount()
            state.timer:close()
        end
        pcall(unmount)
    end)

    tree.create_tree(popup)
    state.popup = popup
    cb(popup)
end

return _M
