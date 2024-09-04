local api = vim.api
local fn = vim.fn
local g = vim.g

dofile(vim.g.based_cache .. "otsutab")

local txt = require("otsuui.otsutab.utils").txt
local btn = require("otsuui.otsutab.utils").btn
local strep = string.rep
local style_buf = require("otsuui.otsutab.utils").style_buf
local cur_buf = api.nvim_get_current_buf
local config = require("nvconfig").ui.tabufline

---------------------------------------------------------- btn onclick functions ----------------------------------------------

vim.cmd("function! OtbGoToBuf(bufnr,b,c,d) \n execute 'b'..a:bufnr \n endfunction")

vim.cmd([[
   function! OtbKillBuf(bufnr,b,c,d) 
        call luaeval('require("otsuui.otsutab").close_buffer(_A)', a:bufnr)
  endfunction]])

vim.cmd("function! OtbNewTab(a,b,c,d) \n tabnew \n endfunction")
vim.cmd("function! OtbGotoTab(tabnr,b,c,d) \n execute a:tabnr ..'tabnext' \n endfunction")
vim.cmd("function! OtbToggleTabs(a,b,c,d) \n let g:OtbTabsToggled = !g:OtbTabsToggled | redrawtabline \n endfunction")

-------------------------------------------------------- functions ------------------------------------------------------------

local function getNvimTreeWidth()
	for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
		if vim.bo[api.nvim_win_get_buf(win)].ft == "NvimTree" then
			return api.nvim_win_get_width(win) + 1
		end
	end
	return 0
end

------------------------------------- modules -----------------------------------------
local M = {}

local function available_space()
	local str = ""

	for _, key in ipairs(config.order) do
		if key ~= "buffers" then
			str = str .. M[key]()
		end
	end

	local modules = api.nvim_eval_statusline(str, { use_tabline = true })
	return vim.o.columns - modules.width
end

M.treeOffset = function()
	return "%#NvimTreeNormal#" .. strep(" ", getNvimTreeWidth())
end

M.buffers = function()
	local buffers = {}
	local has_current = false -- have we seen current buffer yet?

	for i, nr in ipairs(vim.t.bufs) do
		if ((#buffers + 1) * 23) > available_space() then
			if has_current then
				break
			end

			table.remove(buffers, 1)
		end

		has_current = cur_buf() == nr or has_current
		table.insert(buffers, style_buf(nr, i))
	end

	return table.concat(buffers) .. txt("%=", "Fill") -- buffers + empty space
end

g.OtbTabsToggled = 0

M.tabs = function()
	local result, tabs = "", fn.tabpagenr("$")

	if tabs > 1 then
		for nr = 1, tabs, 1 do
			local tab_hl = "TabO" .. (nr == fn.tabpagenr() and "n" or "ff")
			result = result .. btn(" " .. nr .. " ", tab_hl, "GotoTab", nr)
		end

		local new_tabtn = btn("  ", "TabNewBtn", "NewTab")
		local tabstoggleBtn = btn(" 󰅂 ", "TabTitle", "ToggleTabs")
		local small_btn = btn(" 󰅁 ", "TabTitle", "ToggleTabs")

		return g.OtbTabsToggled == 1 and small_btn or new_tabtn .. tabstoggleBtn .. result
	end

	return ""
end

return function()
	local result = {}

	if config.modules then
		for key, value in pairs(config.modules) do
			M[key] = value
		end
	end

	for _, v in ipairs(config.order) do
		table.insert(result, M[v]())
	end

	return table.concat(result)
end
