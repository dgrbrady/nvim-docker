local _M = {
  timer = vim.loop.new_timer(),
  timer_stopped = false,
  popup_exists = false,
}
return _M
