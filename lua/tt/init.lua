local config = require("tt.config")
local terminal = require("tt.terminal")
local termlist = require("tt.termlist")

local M = {}

M.setup = config.setup
M.terminal = terminal
M.termlist = termlist

local function bufIsIn(t, buf)
	for _, v in ipairs(t) do
		if v.buf == buf then
			return true
		end
	end

	return false
end

function M:IsOpen()
	if terminal.window ~= nil and vim.api.nvim_win_is_valid(terminal.window) then
		return true
	end

	return false
end

vim.api.nvim_create_autocmd("TermClose", {
	pattern = "*",
	callback = function(ev)
		if bufIsIn(terminal.TermList, ev.buf) then
			M.terminal:Close()

			if terminal.TermListIdx ~= 1 then
				terminal.TermListIdx = terminal.TermListIdx - 1
			end

			M.terminal:Open(terminal.TermList[terminal.TermListIdx])
		end
	end,
})

vim.api.nvim_create_autocmd("WinResized", {
	pattern = "*",
	callback = function(ev)
		if config.config.fixed_height then
			if terminal.window ~= nil and vim.api.nvim_win_is_valid(terminal.window) then
				vim.api.nvim_win_set_height(terminal.window, config.config.height)
			end
			if termlist.window ~= nil and vim.api.nvim_win_is_valid(termlist.window) then
				vim.api.nvim_win_set_height(termlist.window, config.config.height)
			end
		end

		if config.config.fixed_width then
			if config.config.termlist.width ~= nil then
				if termlist.window ~= nil and vim.api.nvim_win_is_valid(termlist.window) then
					vim.api.nvim_win_set_width(termlist.window, config.config.termlist.width)
				end
			else
				vim.notify("You have fixed width set with no termlist width set")
			end
		end
	end,
})

return M
