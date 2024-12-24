dofile(vim.g.based_cache .. "dash")

local dash = {}
local config = Otsuvim.config.ui.dash
local ns = vim.api.nvim_create_namespace("otsu-dash")

function dash.open()
  local cur_win = vim.api.nvim_get_current_win()
  if not dash.buf then
    dash.tui = {}
    dash.win = cur_win
    dash.buf = vim.api.nvim_create_buf(false, true)
  else
    vim.api.nvim_win_set_buf(cur_win, dash.buf)
    return
  end

  vim.api.nvim_win_set_buf(dash.win, dash.buf)
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

  for _, item in pairs(config.buttons) do
    vim.api.nvim_buf_set_keymap(dash.buf, "n", item.key, "<cmd>" .. item.action .. "<cr>", { desc = "dash action" })
  end

  local augroup = require("otsu-ui.autocmds").augroup("dash")

  vim.api.nvim_create_autocmd({ "WinResized", "VimResized" }, {
    group = augroup,
    buffer = dash.buf,
    callback = function()
      dash.draw()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = augroup,
    buffer = dash.buf,
    callback = function()
      vim.api.nvim_del_augroup_by_name(augroup)
      dash.load_opts(true)
      dash.win, dash.buf = nil, nil
    end,
  })
end

function dash.draw()
  local empty_buf, winh, winw = {}, vim.api.nvim_win_get_height(dash.win), vim.api.nvim_win_get_width(dash.win)
  for i = 1, #dash.tui > winh and #dash.tui + 10 or winh do
    empty_buf[i] = string.rep("", winw)
  end

  vim.bo[dash.buf].ma = true
  vim.api.nvim_buf_set_lines(dash.buf, 0, -1, false, empty_buf)
  vim.bo[dash.buf].ma = false

  vim.api.nvim_buf_clear_namespace(dash.buf, ns, 0, -1)
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
      vim.api.nvim_buf_set_extmark(dash.buf, ns, i, 0, opt)
      offset = offset + vim.api.nvim_strwidth(v.txt)
    end
  end
end

local saved_opts = {}
local opts = {
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

    vim.opt.showtabline = saved_opts["showtabline"]
    vim.opt.laststatus = saved_opts["laststatus"]
  else
    for opt, val in pairs(opts) do
      saved_opts[opt] = vim.opt_local[opt]:get()
      vim.opt_local[opt] = val
    end

    saved_opts["showtabline"] = vim.opt.showtabline:get()
    saved_opts["laststatus"] = vim.opt.laststatus:get()
    vim.opt.showtabline = 0
    vim.opt.laststatus = 0
  end
end

return dash
