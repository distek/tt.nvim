local config = require("tt.config")
local util = require("tt.util")
local M = {}

M.window = nil

M.lastHeight = config.config.height

M.TermList = {}
M.TermListIdx = nil

local freshTerm = {
	name = nil,
	buf = nil,
}

local function create(name, command)
	local newTerm = vim.deepcopy(freshTerm)

	if command == nil or command == "" then
		command = vim.o.shell
	end

	if name == nil or name == "" then
		newTerm.name = vim.o.shell
	else
		newTerm.name = name
	end

	vim.cmd(string.format(":botright split +term\\ %s", command))

	newTerm.buf = vim.api.nvim_get_current_buf()

	vim.bo[newTerm.buf].buflisted = false
	vim.bo[newTerm.buf].filetype = "toggleterm"

	local winid = vim.api.nvim_get_current_win()

	vim.api.nvim_win_hide(winid)

	table.insert(M.TermList, newTerm)

	return newTerm
end

function M:NewTerminal(name, command)
	name = name == nil and "" or name
	command = command == nil and "" or command

	M:Open(create(name, command))
end

function M:Open(term)
	if type(term) == "string" and term == "last" then
		term = M.TermList[M.TermListIdx]
	elseif type(term) == "number" then
		term = util.termFromBuf(term)
	end

	if config.config.pre_cb ~= nil then
		config.config.pre_cb(term)
	end

	if term == nil then
		term = create("", "")
	end

	if M.window ~= nil then
		if vim.api.nvim_win_is_valid(M.window) then
			vim.api.nvim_win_set_buf(M.window, term.buf)
			util:setWinhl(M.window, config.config.terminal.winhighlight)

			util:setCurrentIdx()

			require("tt.termlist"):UpdateTermList()
			return
		end
	end

	vim.cmd(":botright split")

	M.window = vim.api.nvim_get_current_win()

	vim.api.nvim_win_set_buf(M.window, term.buf)

	util:setWinhl(M.window, config.config.terminal.winhighlight)

	util:setCurrentIdx()

	vim.api.nvim_win_set_height(M.window, M.lastHeight ~= nil and M.lastHeight or config.config.height)

	require("tt.termlist"):UpdateTermList()

	if config.config.post_cb ~= nil then
		config.config.post_cb(M.window, term)
	end
end

function M:Close()
	if M.window ~= nil and vim.api.nvim_win_is_valid(M.window) then
		if config.config.fixed_height then
			M.lastHeight = vim.api.nvim_win_get_height(M.window)
		end

		vim.api.nvim_win_hide(M.window)
	end

	M.window = nil

	require("tt.termlist"):Close()
end

function M:Toggle()
	if M.window == nil then
		if #M.TermList ~= 0 then
			M:Open(M.TermList[M.TermListIdx])
		else
			M:NewTerminal()
		end
		return
	end

	M:Close()
end

function M:Delete(term)
	for i, v in ipairs(M.TermList) do
		if v.buf == term.buf then
			local b = table.remove(M.TermList, i)

			vim.api.nvim_buf_delete(b.buf, { force = true, unload = true })

			if #M.TermList > 0 then
				M:FocusNext()
			else
				M:Close()
			end

			util:setCurrentIdx()

			require("tt.termlist"):UpdateTermList()

			return
		end
	end
end

function M:FocusNext()
	util:setCurrentIdx()

	if #M.TermList > M.TermListIdx then
		M.TermListIdx = M.TermListIdx + 1
	else
		M.TermListIdx = 1
	end

	M:Open(M.TermList[M.TermListIdx])

	require("tt.termlist"):UpdateTermList()
end

function M:FocusPrevious()
	util:setCurrentIdx()

	if M.TermListIdx > 1 then
		M.TermListIdx = M.TermListIdx - 1
	else
		M.TermListIdx = #M.TermList
	end

	M:Open(M.TermList[M.TermListIdx])

	require("tt.termlist"):UpdateTermList()
end

return M
