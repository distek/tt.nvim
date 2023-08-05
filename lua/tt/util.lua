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

function M:updateWinbar()
	local terminal = require("tt.terminal")

	if terminal.window == nil or not vim.api.nvim_win_is_valid(terminal.window) then
		return
	end

	local count = #terminal.TermList

	if terminal.window == nil or terminal.window < 0 then
		return
	end

	local wb = ""

	for i, term in ipairs(terminal.TermList) do
        if not vim.api.nvim_buf_is_valid(term.buf) then
            goto continue
        end
		if term.buf == terminal.TermList[terminal.TermListIdx].buf then
			wb = wb .. "%#TabLineSel#▎"
			wb = wb .. "%#TabLineSel# "
		else
			wb = wb .. "%#TabLine#▎%#TabLine# "
		end

		wb = wb .. "%" .. term.buf .. "@v:lua.require'tt'.HandleClickTab@ "
		wb = wb .. term.name .. " %X"
		wb = wb .. "%" .. term.buf .. "@v:lua.require'tt'.HandleClickClose@"
		wb = wb .. " 𝝬%X"
		if count > 1 and i ~= count then
			wb = wb .. " %#TabLineFill# "
		else
			wb = wb .. " "
		end
		wb = wb .. "%#Normal#"
        ::continue::
	end

	wb = wb .. "%#TabLineFill#"

	vim.wo[terminal.window].winbar = wb
end

function M:termFromBuf(buf)
	local terminal = require("tt.terminal")
	for _, v in ipairs(terminal.TermList) do
		if v.buf == buf then
			return v
		end
	end

	return nil
end


return M
