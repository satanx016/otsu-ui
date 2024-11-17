local function augroup(name)
  return vim.api.nvim_create_augroup("otsu-ui_" .. name, {})
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup("reload"),
  pattern = vim.uv.fs_realpath(vim.fn.stdpath("config") .. "/lua/otsuvim/config/otsurc.lua"),
  callback = function()
    -- reload otsurc
    require("plenary.reload").reload_module("otsuvim.config.otsurc")
    Otsuvim.config = require("otsuvim.config.otsurc")

    require("plenary.reload").reload_module("based")
    require("based").load_all_highlights()
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup("vsplit_help&man"),
  pattern = { "*.txt", "*(*)", "*.norg" },
  callback = function()
    if vim.bo.buftype == "help" or vim.bo.filetype == "man" then
      vim.cmd("wincmd L")
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ higroup = "MatchWord" })
  end,
})
