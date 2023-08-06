local config = require("tt.config")
local terminal = require("tt.terminal")
local termlist = require("tt.termlist")
local util = require("tt.util")

local M = {}

M.setup = config.setup
M.terminal = terminal
M.termlist = termlist

function M.IsOpen()
	if terminal.window ~= nil and vim.api.nvim_win_is_valid(terminal.window) then
		return true
	end

	return false
end

function M.HandleClickTab(minwid, clicks, btn, mods)
	local term = util:termFromBuf(minwid)

	if term ~= nil then
		terminal:Open(term)
	end
end

function M.HandleClickClose(minwid, clicks, btn, mods)
	local term = util:termFromBuf(minwid)

	if term ~= nil then
		if vim.api.nvim_buf_is_valid(term.buf) then
			if #terminal.TermList ~= 1 then
				terminal:FocusNext()
			else
				terminal:Close()
			end

			terminal:Delete(term)
		end
	end
end

vim.api.nvim_create_autocmd("TermClose", {
	callback = function(ev)
		-- Defer so the TermClose "finishes" before we act
		vim.defer_fn(function()
			local term = util:termFromBuf(ev.buf)
			if term ~= nil then
				if vim.api.nvim_buf_is_valid(term.buf) then
					if #terminal.TermList ~= 1 then
						terminal:FocusNext()
					else
						terminal:Close()
					end

					terminal:Delete(term)
				end
			end
		end, 1)
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

-- Force insert mode when entering toggleterm
-- I would _love_ to know how to do this better
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "BufWinEnter", "TermEnter" }, {
	pattern = { "*" },
	callback = function(ev)
		if config.config.force_insert_on_focus ~= nil and config.config.force_insert_on_focus then
			if vim.bo[ev.buf].filetype == "toggleterm" then
				vim.defer_fn(function()
					vim.cmd("startinsert")
				end, 1)
			end
		end
	end,
})

return M
