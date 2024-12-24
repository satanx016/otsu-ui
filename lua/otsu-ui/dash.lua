dofile(vim.g.based_cache .. "dash")

local M = {}
local config = Otsuvim.config.ui.dash
local augroup = require("otsu-ui.autocmds").augroup("dash")
local ns = vim.api.nvim_create_namespace("otsu-dash")
local win, buf
local opts = {
  showtabline = 0,
  laststatus = 0,
  bufhidden = "wipe",
  colorcolumn = "",
  foldcolumn = "0",
  matchpairs = "",
  cursorcolumn = false,
  cursorline = false,
  list = false,
  number = false,
  relativenumber = false,
  spell = false,
  swapfile = false,
  readonly = false,
  filetype = "dash",
  signcolumn = "no",
}

local saved_opts = {}
local function load_opts()
  for opt, val in pairs(opts) do
    saved_opts[opt] = vim.opt_local[opt]:get()
    vim.opt_local[opt] = val
  end
end

local function restore_opts()
  for opt in pairs(opts) do
    vim.opt_local[opt] = saved_opts[opt]
  end
end

function M.open()
  buf, win = vim.api.nvim_create_buf(false, true), vim.api.nvim_get_current_win()

  vim.api.nvim_win_set_buf(win, buf)
  load_opts()

  M.draw()

  vim.api.nvim_create_autocmd({ "WinResized", "VimResized" }, {
    group = augroup,
    buffer = buf,
    callback = function()
      M.draw()
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = augroup,
    callback = function(e)
      if e.buf == buf then
        restore_opts()
        vim.api.nvim_del_augroup_by_name(augroup)
      end
    end,
  })
end

local lazy_stats = function()
  local stats = require("lazy").stats()
  local ms = math.floor(stats.startuptime)
  return tostring(stats.loaded .. "/" .. stats.count), tostring(ms .. "ms")
end

local floor = math.floor
function M.draw()
  vim.bo[buf].ma = true

  local header, buttons, dash = config.header, config.buttons, {}
  local winh = vim.api.nvim_win_get_height(win)
  local winw = vim.api.nvim_win_get_width(win)

  local function hsp(n)
    for _ = 1, n or 1 do
      table.insert(dash, { { txt = " " } })
    end
  end

  -- header
  hsp(4)
  for _, v in pairs(header) do
    table.insert(dash, { { txt = v, hl = "DashHeader" } })
  end
  -- buttons
  hsp(2)
  for _, v in pairs(buttons) do
    hsp(1)
    table.insert(dash, {
      { txt = v.icon .. " " .. v.txt .. string.rep(" ", (40 - string.len(v.txt))), hl = "DashBtnTxt" },
      { txt = v.key, hl = "DashBtnKey" },
    })
  end
  -- footer
  hsp(3)
  local ft_pcount, ft_time = lazy_stats()
  table.insert(dash, { { txt = "  Otsuvim loaded " .. ft_pcount .. " plugins in " .. ft_time, hl = "DashFooter" } })

  local empty_str = {}
  for i = 1, #dash > winh and #dash + 10 or winh do
    empty_str[i] = string.rep("", winw)
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, empty_str)

  for i in ipairs(dash) do
    local whole_text = ""
    for _, v in pairs(dash[i]) do
      whole_text = whole_text .. v.txt
    end
    local start = floor((winw - vim.api.nvim_strwidth(whole_text)) / 2)
    local offset = 0
    for _, v in pairs(dash[i]) do
      local opt = {
        virt_text_win_col = start + offset,
        virt_text = { { v.txt, v.hl } },
      }
      vim.api.nvim_buf_set_extmark(buf, ns, i, 0, opt)
      offset = offset + vim.api.nvim_strwidth(v.txt)
    end
  end

  vim.bo[buf].ma = false
end

return M
