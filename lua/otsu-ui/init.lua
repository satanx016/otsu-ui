local M = {}

function M.setup()
	require("otsu-ui.otsucolumn").load()
	require("otsu-ui.otsuline").load()
	require("otsu-ui.otsutab").lazyload()

	require("otsu-ui.autocmds")
end

return M
