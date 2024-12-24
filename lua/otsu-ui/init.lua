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

  if config.ui.dash.load_on_startup then
    require("otsu-ui.dash").open()
  end

  require("otsu-ui.autocmds")
end

return M
