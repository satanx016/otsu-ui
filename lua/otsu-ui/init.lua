local M = {}
local config = Otsuvim.config

function M.setup()
  if config.ui.statusline.enabled then
    require("otsu-ui.statusline").load()
  end

  if config.ui.tufline.enabled then
    require("otsu-ui.tufline").lazyload()
  end

  require("otsu-ui.statuscolumn").load()

  require("otsu-ui.autocmds")
end

return M
