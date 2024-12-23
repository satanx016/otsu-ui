local M = {}

function M.load()
  vim.opt.statusline = "%!v:lua.require('otsu-ui.statusline." .. Otsuvim.config.ui.statusline.theme .. "')()"

  vim.api.nvim_create_autocmd("LspProgress", {
    group = require("otsu-ui.autocmds").augroup("statusline_redraw"),
    callback = function(args)
      if string.find(args.match, "end") then
        vim.cmd("redrawstatus")
      end
      vim.cmd("redrawstatus")
    end,
  })
end

return M
