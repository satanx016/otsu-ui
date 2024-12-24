dofile(vim.g.based_cache .. "dash")

local dash = { tui = {} }
local config = Otsuvim.config.ui.dash
local augroup = require("otsu-ui.autocmds").augroup("dash")
local ns = vim.api.nvim_create_namespace("otsu-dash")
local win, buf

function dash.open()
  buf, win = vim.api.nvim_create_buf(false, true), vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  dash.load_opts()

  local function hsp(n)
    for _ = 1, n or 1 do
      table.insert(dash.tui, { { txt = " " } })
    end
  end

  -- header
  hsp(4)
  for _, txt in pairs(config.header) do
    table.insert(dash.tui, { { txt = txt, hl = "DashHeader" } })
  end
  -- buttons
  hsp(2)
  for _, item in pairs(config.buttons) do
    hsp(1)
    table.insert(dash.tui, {
      { txt = item.icon .. " " .. item.txt .. string.rep(" ", (40 - string.len(item.txt))), hl = "DashBtnTxt" },
      { txt = item.key, hl = "DashBtnKey" },
    })
  end
  -- footer
  hsp(3)
  local footer_txt = function()
    local stats = require("lazy").stats()
    local ms = math.floor(stats.startuptime)
    return "  Otsuvim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"
  end
  table.insert(dash.tui, {
    {
      txt = footer_txt(),
      hl = "DashFooter",
    },
  })

  dash.draw()

  vim.api.nvim_create_autocmd({ "WinResized", "VimResized" }, {
    group = augroup,
    buffer = buf,
    callback = function()
      dash.draw()
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = augroup,
    buffer = buf,
    callback = function()
      dash.load_opts(true)
      vim.api.nvim_del_augroup_by_name(augroup)
    end,
  })
end

function dash.draw()
  local empty_buf, winh, winw = {}, vim.api.nvim_win_get_height(win), vim.api.nvim_win_get_width(win)
  for i = 1, #dash.tui > winh and #dash.tui + 10 or winh do
    empty_buf[i] = string.rep("", winw)
  end

  vim.bo[buf].ma = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, empty_buf)
  vim.bo[buf].ma = false

  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i in ipairs(dash.tui) do
    local line_txt = ""
    for _, v in pairs(dash.tui[i]) do
      line_txt = line_txt .. v.txt
    end

    local start, offset = math.floor((winw - vim.api.nvim_strwidth(line_txt)) / 2), 0
    for _, v in pairs(dash.tui[i]) do
      local opt = {
        virt_text_win_col = start + offset,
        virt_text = { { v.txt, v.hl } },
      }
      vim.api.nvim_buf_set_extmark(buf, ns, i, 0, opt)
      offset = offset + vim.api.nvim_strwidth(v.txt)
    end
  end
end

local saved_opts = {}
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
function dash.load_opts(restore)
  if restore then
    for opt in pairs(opts) do
      vim.opt_local[opt] = saved_opts[opt]
    end
  else
    for opt, val in pairs(opts) do
      saved_opts[opt] = vim.opt_local[opt]:get()
      vim.opt_local[opt] = val
    end
  end
end

return dash
