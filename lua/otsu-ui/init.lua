local M = {}

local config = require("nvconfig").ui

function M.setup()
	M.otsuline()
	M.otsutab()
	M.otsucolumn()
end

function M.otsuline()
	vim.opt.statusline = "%!v:lua.require('otsu-ui.otsuline." .. config.statusline.theme .. "')()"
end

function M.otsutab()
	if config.tabufline.enabled then
		require("otsu-ui.otsutab.lazyload")
	end
end

function M.otsucolumn()
	vim.opt.statuscolumn = [[%!v:lua.require'otsu-ui.otsucolumn'.statuscolumn()]]

	vim.opt.foldmethod = "expr"
	vim.opt.foldtext = ""
	vim.opt.foldlevel = 99
	vim.opt.fillchars = {
		foldopen = "",
		foldclose = "",
		fold = " ",
		foldsep = " ",
		diff = "╱",
		eob = " ",
	}
	vim.opt.foldexpr = "v:lua.require'otsu-ui.otsucolumn'.foldexpr()"
end

return M
