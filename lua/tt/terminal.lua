local config = require("tt.config")
local termlist = require("tt.termlist")
local M = {}

-- This will be set to the current window
M.window = nil

M.TermList = {}
M.TermListIdx = nil

local freshTerm = {
	name = nil,
	buf = nil,
	-- winid = nil,
}

TerminalNS = vim.api.nvim_create_namespace("customTerminal")
TerminalListNS = vim.api.nvim_create_namespace("customTerminalList")

local function setCurrentIdx()
	if M.window == nil then
		return
	end

	local buf = vim.api.nvim_win_get_buf(M.window)

	for i, v in ipairs(M.TermList) do
		if v.buf == buf then
			M.TermListIdx = i
			return
		end
	end
end

local function create(name, command)
	local newTerm = vim.deepcopy(freshTerm)

	if command == nil or command == "" then
		command = vim.o.shell
	end

	vim.cmd(string.format(":botright split +term\\ %s", command))

	newTerm.buf = vim.api.nvim_get_current_buf()

	vim.bo[newTerm.buf].buflisted = false
	vim.bo[newTerm.buf].filetype = "toggleterm"

	local winid = vim.api.nvim_get_current_win()

	vim.api.nvim_win_hide(winid)

	newTerm.name = name or vim.o.shell

	table.insert(M.TermList, newTerm)
end

-- Append new terminal to list and open it
function M:NewTerminal(name, command)
	create(name, command)

	M:Open(M.TermList[#M.TermList])
end

function M:Open(term)
	if config.config.pre_cb ~= nil then
		config.config.pre_cb(term)
	end

	if term == nil then
		create("", "")

		return
	end

	if M.window ~= nil then
		vim.api.nvim_win_set_buf(M.window, term.buf)
		return
	end

	vim.cmd(":botright split")

	local winid = vim.api.nvim_get_current_win()

	vim.api.nvim_win_set_buf(winid, term.buf)

	vim.api.nvim_win_set_height = config.config.height

	M.window = winid

	setCurrentIdx()

	if config.config.post_cb then
		config.config.post_cb(winid, term)
	end
end

function M:Close()
	vim.api.nvim_win_hide(M.window)

	M.window = nil
end

function M:Toggle()
	if M.window == nil then
		M:Open(M.TermList[M.TermListIdx])
		return
	end

	M:Close()
end

function M:Delete(term)
	for i, v in ipairs(M.TermList) do
		if v.buf == term.buf then
			local b = table.remove(M.TermList, i)

			if #M.TermList > 0 then
				M:FocusNext()
			else
				M:Close()
			end

			vim.api.nvim_buf_delete(b.buf)

			setCurrentIdx()
			return
		end
	end
end

function M:FocusNext()
	setCurrentIdx()

	if #M.TermList > M.TermListIdx then
		M.TermListIdx = M.TermListIdx + 1
	else
		M.TermListIdx = 1
	end

	M:Open(M.TermList[M.TermListIdx])
end

function M:FocusPrevious()
	setCurrentIdx()

	if M.TermListIdx > 1 then
		M.TermListIdx = M.TermListIdx - 1
	else
		M.TermListIdx = #M.TermList
	end

	M:Open(M.TermList[M.TermListIdx])

	termlist:UpdateTermList()
end

return M
