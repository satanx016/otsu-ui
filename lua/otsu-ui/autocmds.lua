local M = {}

function M.augroup(name, opts)
  vim.api.nvim_create_augroup("otsu-ui_" .. name, opts or {})
  return "otsu-ui_" .. name
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = M.augroup("reload"),
  pattern = vim.uv.fs_realpath(vim.fn.stdpath("config") .. "/lua/otsuvim/config/otsurc.lua"),
  callback = function()
    require("plenary.reload").reload_module("otsuvim.config.otsurc")
    Otsuvim.config = require("otsuvim.config.otsurc")

    vim.opt.statusline = "%!v:lua.require('otsu-ui.statusline." .. Otsuvim.config.ui.statusline.theme .. "')()"

    require("plenary.reload").reload_module("based")
    require("based").load_all_highlights()
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = M.augroup("vsplit_help&man"),
  pattern = { "*.txt", "*(*)", "*.norg" },
  callback = function()
    if vim.bo.buftype == "help" or vim.bo.filetype == "man" then
      vim.cmd("wincmd L")
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = M.augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ higroup = "MatchWord" })
  end,
})

return M
