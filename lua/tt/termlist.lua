local config = require("tt.config")

local M = {}

M.window = nil
M.bufid = nil

M.terminalListNS = vim.api.nvim_create_namespace("customTerminalList")
vim.api.nvim_set_hl(M.terminalListNS, "TermListNormal", { link = "Normal" })

local function getBufNames()
	local terminal = require("tt.terminal")
	local ret = {}

	local i = 1
	for _, v in ipairs(terminal.TermList) do
		if vim.api.nvim_buf_is_valid(v.buf) then
			ret[i] = string.format(" %2d %s ", i, v.name)

			local length = string.len(ret[i])

			local padding = config.config.termlist.width - length

			ret[i] = ret[i] .. string.rep(" ", padding)

			i = i + 1
		end
	end

	return ret
end

local function refreshTermList()
	local terminal = require("tt.terminal")

	if M.bufid ~= nil and vim.api.nvim_buf_is_valid(M.bufid) then
		-- only checking if it's valid so we can delete it
		vim.api.nvim_buf_delete(M.bufid, { force = true, unload = true })
	end

	if M.window == nil or not vim.api.nvim_win_is_valid(M.window) then
		if terminal.window == nil then
			M.window = nil
			return
		end

		vim.api.nvim_set_current_win(terminal.window)

		local sr = vim.o.splitright

		vim.o.splitright = config.config.termlist.side == "right"

		vim.cmd(string.format(":%dvsplit", config.config.termlist.width))

		vim.o.splitright = sr

		M.window = vim.api.nvim_get_current_win()
		M.bufid = vim.api.nvim_get_current_buf()
	end

	vim.api.nvim_set_current_win(M.window)

	M.bufid = vim.api.nvim_create_buf(false, true)

	vim.bo[M.bufid].filetype = "termlist"
	vim.bo[M.bufid].bufhidden = "hide"
	vim.bo[M.bufid].buftype = "nofile"

	local bufs = getBufNames()

	vim.api.nvim_buf_set_option(M.bufid, "readonly", false)
	vim.api.nvim_buf_set_option(M.bufid, "modifiable", true)
	vim.api.nvim_buf_set_lines(M.bufid, 0, 0, false, {})
	vim.api.nvim_buf_set_lines(M.bufid, 0, -1, false, bufs)
	vim.api.nvim_buf_set_option(M.bufid, "modified", false)

	vim.api.nvim_buf_set_keymap(
		M.bufid,
		"n",
		"<cr>",
		'<cmd>lua require("tt.termlist"):OpenTermUnderCursor()<cr>',
		{ noremap = true }
	)

	vim.api.nvim_buf_set_keymap(
		M.bufid,
		"n",
		"r",
		'<cmd>lua require("tt.termlist"):RenameTermUnderCursor()<cr>',
		{ noremap = true }
	)

	vim.api.nvim_buf_set_keymap(
		M.bufid,
		"n",
		"n",
		'<cmd>lua require("tt.terminal"):NewTerminal()        <cr>',
		{ noremap = true }
	)

	vim.api.nvim_buf_set_keymap(
		M.bufid,
		"n",
		"dd",
		'<cmd>lua require("tt.termlist"):DeleteTermUnderCursor()<cr>',
		{ noremap = true }
	)

	M.window = vim.api.nvim_get_current_win()

	vim.wo[M.window].number = false
	vim.wo[M.window].relativenumber = false
	vim.wo[M.window].wrap = false
	vim.wo[M.window].list = false
	vim.wo[M.window].signcolumn = "no"
	vim.wo[M.window].statuscolumn = ""

	if config.config.winbar.list == nil or config.config.winbar.list == true then
		vim.api.nvim_win_set_option(M.window, "winbar", config.config.winbar.list_title or "Terminals")
	end

	vim.api.nvim_win_set_hl_ns(M.window, M.terminalListNS)

	vim.api.nvim_buf_add_highlight(
		M.bufid,
		-1,
		"TermListCurrent",
		terminal.TermListIdx - 1,
		0,
		config.config.termlist.width
	)

	vim.api.nvim_win_set_width(M.window, config.config.termlist.width)

	vim.cmd("stopinsert")
	vim.cmd("wincmd p")

	vim.api.nvim_buf_set_option(M.bufid, "modifiable", false)
	vim.api.nvim_buf_set_option(M.bufid, "readonly", true)

	vim.api.nvim_win_set_buf(M.window, M.bufid)

	vim.api.nvim_win_set_height(M.window, config.config.height)
end

function M:UpdateTermList()
	if not config.config.termlist.enabled then
		return
	end

	refreshTermList()
end

function M:OpenTermUnderCursor()
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

	local terminal = require("tt.terminal")
	terminal.TermListIdx = row

	terminal:Open(terminal.TermList[row])

	if not config.config.focus_on_select then
		vim.api.nvim_set_current_win(M.window)
		vim.cmd("stopinsert")
	end

	vim.api.nvim_win_set_cursor(0, { row, 0 })
end

function M:DeleteTermUnderCursor()
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

	local terminal = require("tt.terminal")

	terminal.TermListIdx = row - 1

	terminal:Delete(terminal.TermList[row])

	vim.api.nvim_win_set_cursor(0, { row, 0 })
end

function M:RenameTermUnderCursor()
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

	local terminal = require("tt.terminal")

	vim.ui.input({
		prompt = "New name: ",
	}, function(input)
		if input ~= nil then
			terminal.TermList[row].name = input
			return
		end
	end)

	M:UpdateTermList()

	vim.api.nvim_win_set_cursor(0, { row, 0 })
end

function M:Close()
	if vim.api.nvim_win_is_valid(M.window) then
		vim.api.nvim_win_hide(M.window)
	end

	M.window = nil
end

return M
