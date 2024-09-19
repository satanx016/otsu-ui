local M = {}

local config = require("nvconfig").ui

M.setup = function()
	M.otsuline()
	M.otsutab()
	M.otsucolumn()
end

M.otsuline = function()
	vim.opt.statusline = "%!v:lua.require('otsuui.otsuline." .. config.statusline.theme .. "')()"
end

M.otsutab = function()
	if config.tabufline.enabled then
		require("otsuui.otsutab.lazyload")
	end
end

M.otsucolumn = function()
	vim.opt.statuscolumn = [[%!v:lua.require'otsuui.otsucolumn'.statuscolumn()]]

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
	vim.opt.foldexpr = "v:lua.require'otsuui.otsucolumn'.foldexpr()"
end

return M
