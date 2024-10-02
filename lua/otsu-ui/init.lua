local M = {}

function M.setup()
	require("otsu-ui.otsucolumn").load()
	require("otsu-ui.otsuline").load()
	require("otsu-ui.otsutab").lazyload()

	M.reload_conf_on_save()
	M.highlight_on_yank()
end

function M.highlight_on_yank()
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			vim.highlight.on_yank({ higroup = "MatchWord" })
		end,
	})
end

function M.reload_conf_on_save()
	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = vim.uv.fs_realpath(vim.fn.stdpath("config") .. "/lua/otsuvim/config/otsurc.lua"),
		group = vim.api.nvim_create_augroup("ReloadOtsu", {}),
		callback = function()
			-- reload otsurc
			require("plenary.reload").reload_module("otsuvim.config.otsurc")
			Otsuvim.config = require("otsuvim.config.otsurc")

			require("plenary.reload").reload_module("based")
			require("based").load_all_highlights()
		end,
	})
end

return M
