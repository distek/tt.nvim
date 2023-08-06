local M = {}

M.config = {
	termlist = {
		enabled = nil,
		name = nil,
		width = nil,
		winhighlight = nil,
		winbar = nil,
		focus_on_select = nil,
	},

	terminal = {
		winhighlight = nil,
		winbar = nil,
		force_insert_on_focus = nil,
	},

	height = nil,

	fixed_height = nil,
	fixed_width = nil,

	pre_cb = nil,
	post_cb = nil,
}

local defaultConfig = {
	termlist = {
		enabled = true,
		name = "Terminals",
		width = 25,
		winhighlight = "Normal:Normal",
		winbar = true,
		focus_on_select = true,
	},

	terminal = {
		winhighlight = "Normal:Normal",
		winbar = false,
		force_insert_on_focus = true,
	},

	height = 15,

	fixed_height = false,
	fixed_width = true,
}

M.setup = function(config)
	if config ~= nil and config ~= {} then
		M.config = vim.tbl_deep_extend("force", defaultConfig, config)
	else
		M.config = defaultConfig
	end
end

return M
