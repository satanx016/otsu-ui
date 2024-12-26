local dash = {}

local config = Otsuvim.config.ui.dash
local utils = require("otsu-ui.utils")
dofile(vim.g.based_cache .. "dash")

local ns = vim.api.nvim_create_namespace("otsu-dash")
local render_debounce = nil
local btn_locations = {}
local btn_width = 40

function dash.open()
  if dash.buf then -- prevent double instances
    return
  end

  dash.tui = {}
  dash.win = vim.api.nvim_get_current_win()
  dash.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(dash.win, dash.buf)
  dash.load_opts()

  local function hsp(n) -- Add `n` empty_line/horizontal spacing
    for _ = 1, n or 1 do
      table.insert(dash.tui, { { txt = " " } })
    end
  end

  -- Header
  hsp(4)
  for _, txt in pairs(config.header) do
    table.insert(dash.tui, { { txt = txt, hl = "DashHeader" } })
  end
  -- Buttons
  hsp(2)
  for _, item in pairs(config.buttons) do
    hsp(1)
    table.insert(dash.tui, {
      { txt = item.icon .. " " .. item.txt .. string.rep(" ", (btn_width - string.len(item.txt))), hl = "DashBtnTxt" },
      { txt = item.key, hl = "DashBtnKey" },
    })
  end
  -- Footer
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

  dash.render() -- fire the first render
  dash.events() -- load autocommands
  dash.keybinds() -- set keybinds
end

function dash.events()
  local augroup = require("otsu-ui.autocmds").augroup("dash")

  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = augroup,
    buffer = dash.buf,
    callback = function()
      vim.api.nvim_del_augroup_by_name(augroup)
      dash.load_opts(true)
      dash.win, dash.buf = nil, nil
    end,
  })

  vim.api.nvim_create_autocmd({ "WinResized", "VimResized" }, {
    group = augroup,
    buffer = dash.buf,
    callback = function()
      if render_debounce then
        vim.fn.timer_stop(render_debounce)
      end

      render_debounce = vim.fn.timer_start(100, function()
        vim.schedule(function() -- safely render on the main thread
          if vim.api.nvim_buf_is_valid(dash.buf) then
            dash.render()
          end
        end)
      end)
    end,
  })

  for i in ipairs(dash.tui) do -- populate btn_locations{}
    if dash.tui[i][1].hl == "DashBtnTxt" then
      table.insert(btn_locations, i + 1)
    end
  end

  local first_loc = math.min(unpack(btn_locations))
  local last_loc = math.max(unpack(btn_locations))
  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = dash.buf,
    callback = function() -- some calculations to keep the cursor inside the expected positions
      local cur_row = math.max(math.min(vim.fn.line("."), last_loc), first_loc)
      local cur_col = math.max(math.floor(vim.api.nvim_win_get_width(dash.win) / 2 - (btn_width + 4) / 2), 0) + 3
      vim.api.nvim_win_set_cursor(dash.win, { cur_row, cur_col })
    end,
  })
end

function dash.keybinds()
  local function motion_map(keys, direction)
    for _, key in pairs(keys) do
      vim.keymap.set("n", key, function()
        vim.api.nvim_win_set_cursor(dash.win, { vim.fn.line(".") + direction, 0 })
      end, { buffer = dash.buf })
    end
  end
  motion_map({ "j", "<down>" }, 2)
  motion_map({ "k", "<up>" }, -2)

  for _, item in pairs(config.buttons) do
    vim.api.nvim_buf_set_keymap(dash.buf, "n", item.key, "<cmd>" .. item.action .. "<cr>", { desc = "dash action" })
  end

  vim.keymap.set("n", "<cr>", function()
    vim.cmd(config.buttons[utils.table_index(btn_locations, vim.fn.line("."))].action)
  end, { buffer = dash.buf })
end

function dash.render()
  local empty_buf, winh, winw = {}, vim.api.nvim_win_get_height(dash.win), vim.api.nvim_win_get_width(dash.win)
  for i = 1, #dash.tui > winh and #dash.tui + 10 or winh do
    empty_buf[i] = string.rep(" ", winw)
  end

  vim.bo[dash.buf].ma = true
  vim.api.nvim_buf_set_lines(dash.buf, 0, -1, false, empty_buf)
  vim.bo[dash.buf].ma = false

  -- write/center/highlight dash elements
  vim.api.nvim_buf_clear_namespace(dash.buf, ns, 0, -1)
  for i in ipairs(dash.tui) do
    local merged_line_txt = ""
    for _, v in pairs(dash.tui[i]) do
      merged_line_txt = merged_line_txt .. v.txt
    end

    local start, offset = math.floor((winw - vim.api.nvim_strwidth(merged_line_txt)) / 2), 0
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

local saved_opts = { global = {}, _local = {} }
local opts = {
  global = {
    showtabline = 0,
    laststatus = 0,
  },
  _local = {
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
  },
}
function dash.load_opts(restore)
  if restore then -- restore the user options
    for opt in pairs(opts.global) do
      vim.opt[opt] = saved_opts.global[opt]
    end

    for opt in pairs(opts._local) do
      vim.opt_local[opt] = saved_opts._local[opt]
    end
  else -- set Dash options
    for opt, val in pairs(opts.global) do
      saved_opts.global[opt] = vim.opt_local[opt]:get()
      vim.opt[opt] = val
    end

    for opt, val in pairs(opts._local) do
      saved_opts._local[opt] = vim.opt_local[opt]:get()
      vim.opt_local[opt] = val
    end
  end
end

return dash
