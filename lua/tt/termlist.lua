local terminal = require("tt.terminal")
local config = require("tt.config")

local M = {}

M.window = nil
M.bufid = nil

local function getBufNames()
	local ret = {}

	local i = 1
	local hlLine = terminal.TermListIdx
	for _, v in ipairs(terminal.TermList) do
		if vim.api.nvim_buf_is_valid(v) then
			ret[i] = string.format(" %2d %s ", i, v.name)

			local length = string.len(ret[i])

			local padding = TermConfig.config.termlist_width - length

			ret[i] = ret[i] .. string.rep(" ", padding)

			i = i + 1
		end
	end

	return ret, hlLine
end

local function updateBufs(bufnr)
	local bufs, hlLine = getBufNames()

	if not bufnr or bufnr == nil or #bufs == 0 then
		return
	end

	vim.api.nvim_buf_add_highlight(bufnr, -1, "TermListCurrent", hlLine - 1, 1, 999)

	vim.api.nvim_buf_set_option(bufnr, "readonly", false)
	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
	vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { "" })
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, bufs)
	vim.api.nvim_buf_set_option(bufnr, "readonly", true)
	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)

	if M.window ~= nil then
		if vim.api.nvim_win_is_valid(M.window) then
			vim.api.nvim_win_set_width(M.window, TermConfig.config.termlist_width)
			vim.api.nvim_win_set_hl_ns(M.window, TerminalListNS)
		end
	end
end

local function refreshTermList(winid)
	if M.bufid ~= nil and vim.api.nvim_buf_is_valid(M.bufid) then
		vim.api.nvim_buf_delete(M.bufid, { force = true, unload = false })
	end

	if not winid or not vim.api.nvim_win_is_valid(winid) then
		return
	end

	vim.api.nvim_set_current_win(winid)

	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)

	updateBufs(bufnr)

	vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
	vim.api.nvim_buf_set_option(bufnr, "readonly", false)

	M.bufid = bufnr

	if M.window == nil or not vim.api.nvim_win_is_valid(M.window) then
		local sr = vim.o.splitright

		vim.o.splitright = TermConfig.config.termlist_side == "right"

		vim.cmd(string.format("%dvsplit +buffer\\ %d", TermConfig.config.termlist_width, bufnr))

		vim.o.splitright = sr
	else
		vim.api.nvim_set_current_win(M.window)
	end

	vim.opt_local.filetype = "termlist"
	vim.bo[bufnr].bufhidden = true
	vim.bo[bufnr].buftype = "nofile"

	local bufs, hlLine = getBufNames()

	vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, {})
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, bufs)
	vim.api.nvim_buf_set_option(bufnr, "modified", false)

	vim.api.nvim_buf_set_keymap(bufnr, "n", "<cr>", "<cmd>lua TF.OpenTermUnderCursor()<cr>", { noremap = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "r", "<cmd>lua TF.RenameTermUnderCursor()<cr>", { noremap = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "n", "<cmd>lua TF.TermNew()<cr>", { noremap = true })
	vim.api.nvim_buf_set_keymap(bufnr, "n", "dd", "<cmd>lua TF.DeleteTermUnderCursor()<cr>", { noremap = true })

	M.window = vim.api.nvim_get_current_win()

	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.opt_local.wrap = false
	vim.opt_local.list = false
	vim.opt_local.signcolumn = "no"
	vim.opt_local.statuscolumn = ""

	if TermConfig.config.winbar_list == nil or TermConfig.config.winbar_list == true then
		vim.api.nvim_win_set_option(M.window, "winbar", TermConfig.config.winbar_list_title or "Terminals")
	end

	vim.api.nvim_win_set_hl_ns(M.window, TerminalListNS)

	vim.api.nvim_buf_add_highlight(bufnr, -1, "TermListCurrent", hlLine - 1, 0, TermConfig.config.termlist_width)

	vim.cmd("stopinsert")
	vim.cmd("wincmd p")

	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
	vim.api.nvim_buf_set_option(bufnr, "readonly", true)
end

function M:UpdateTermList()
	if not config.config.termlist.enabled then
		return
	end
	if M.window == nil then
		vim.cmd(":botright vsplit")

		M.window = vim.api.nvim_get_current_win()

		vim.api.nvim_win_set_width(M.window, config.config.termlist.width)
	end

	-- TODO: don't need to pass in window, it's a global
	refreshTermList(M.window)
end
