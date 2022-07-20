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

function _M.create_popup(top_text, bottom_text)
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
    state.popup = popup

    -- mount/open the component
    state.popup:mount()

    -- unmount component when cursor leaves buffer
    state.popup:on(event.BufLeave, function()
        state.popup:unmount()
        state.timer_stopped = true
        state.timer:close()
    end)

    tree.create_tree()
end

_M.create_keymaps = keymaps.create_keymaps
return _M
