local popup_ok, Popup = pcall(require, 'nui.popup')
if popup_ok == false then
    vim.notify('NUI not installed, please install it from MunifTanjim/nui.nvim')
    return
end

local state = require('nvim-docker.popup-state')
local tree = require('nvim-docker.tree')
local event = require('nui.utils.autocmd').event
local _M = {}

local function create_popup(config)
     local popup = Popup({
        enter = true,
        focusable = true,
        border = {
            style = 'rounded',
            text = {
                top = config.top_text,
                top_align = 'center',
                bottom = '<l>: Expand, <L>: Expand All, <h>: Collapse, <H>: Collapse All'
            },
        },
        position = '50%',
        size = {
            width = '80%',
            height = '60%',
        },
    })

    popup:mount()

    local timer = vim.loop.new_timer()

    -- unmount component when cursor leaves buffer
    popup:on(event.BufLeave, function()
        state.popup = nil
        state.tree = nil
        local function unmount()
            timer:close()
            popup:unmount()
        end
        pcall(unmount)
    end)

    tree.create_tree(popup, config, state)

    state.popup = popup

    -- background refresh the tree every 5000ms
    timer:start(0, 5000, vim.schedule_wrap(config.render))
   
end

_M.create_popup = create_popup

return _M
