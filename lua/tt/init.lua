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
			vim.api.nvim_win_set_height(terminal.window, config.config.height)
			vim.api.nvim_win_set_height(termlist.window, config.config.height)
		end

		if config.config.fixed_width then
			vim.api.nvim_win_set_width(termlist.window, config.config.termlist.width)
		end
	end,
})

return M
