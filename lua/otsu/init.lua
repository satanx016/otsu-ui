local new_cmd = vim.api.nvim_create_user_command
local config = require("nvconfig").ui

vim.opt.statusline = "%!v:lua.require('otsu.stl." .. config.statusline.theme .. "')()"

if config.tabufline.enabled then
  require "otsu.tabufline.lazyload"
end

-- Command to toggle NvDash
new_cmd("Nvdash", function()
  if vim.g.nvdash_displayed then
    require("otsu.tabufline").close_buffer()
  else
    require("otsu.nvdash").open()
  end
end, {})

-- load nvdash only on empty file
if config.nvdash.load_on_startup then
  vim.schedule(function()
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, 1, false)
    local no_buf_content = vim.api.nvim_buf_line_count(0) == 1 and buf_lines[1] == ""
    local bufname = vim.api.nvim_buf_get_name(0)

    if bufname == "" and no_buf_content then
      require("otsu.nvdash").open()
    end
  end, 0)
end

-- command to toggle cheatsheet
new_cmd("NvCheatsheet", function()
  if vim.g.nvcheatsheet_displayed then
    require("otsu.tabufline").close_buffer()
  else
    require("otsu.cheatsheet." .. config.cheatsheet.theme)()
  end
end, {})

-- redraw dashboard on VimResized event
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    if vim.bo.filetype == "nvdash" then
      vim.opt_local.modifiable = true
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
      require("otsu.nvdash").open()
    elseif vim.bo.filetype == "nvcheatsheet" then
      vim.opt_local.modifiable = true
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
      require("otsu.cheatsheet." .. config.cheatsheet.theme)()
    end
  end,
})

-- redraw statusline on LspProgressUpdate event & fixes #145
vim.api.nvim_create_autocmd("User", {
  pattern = "LspProgressUpdate",
  callback = function()
    vim.cmd "redrawstatus"
  end,
})
