local M = {}

function M.load()
	local config = require("nvconfig")
	vim.opt.statusline = "%!v:lua.require('otsu-ui.otsuline." .. config.ui.statusline.theme .. "')()"

	vim.api.nvim_create_autocmd("LspProgress", {
		group = vim.api.nvim_create_augroup("OtsulineRedraw", {}),
		callback = function(args)
			if string.find(args.match, "end") then
				vim.cmd("redrawstatus")
			end
			vim.cmd("redrawstatus")
		end,
	})
end

return M
