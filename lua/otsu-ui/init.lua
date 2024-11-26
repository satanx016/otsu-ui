local M = {}

function M.setup()
  require("otsu-ui.statuscolumn").load()
  require("otsu-ui.statusline").load()
  require("otsu-ui.tufline").lazyload()

  require("otsu-ui.autocmds")
end

return M
