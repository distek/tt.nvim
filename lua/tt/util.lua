M = {}

function M:setCurrentIdx()
	local terminal = require("tt.terminal")

	if terminal.window == nil or not vim.api.nvim_win_is_valid(terminal.window) then
		return
	end

	terminal.TermListIdx = -1

	local buf = vim.api.nvim_win_get_buf(terminal.window)
	for i, v in ipairs(terminal.TermList) do
		if v.buf == buf then
			terminal.TermListIdx = i
			return
		end
	end
end

return M
