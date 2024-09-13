local config = require("nvconfig").ui

-- init otsuline
vim.opt.statusline = "%!v:lua.require('otsuui.otsuline." .. config.statusline.theme .. "')()"

-- init otsutab
if config.tabufline.enabled then
  require "otsuui.otsutab.lazyload"
end

-- init otsucolumn
vim.opt.statuscolumn = [[%!v:lua.require'otsuui.otsucolumn'.statuscolumn()]]
