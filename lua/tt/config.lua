local M = {}

M.config = {
	focus_on_select = nil,
	termlist = {
		enabled = nil,
		side = nil,
		width = nil,
	},
	winbar = {
		tabs = nil,
		list = nil,
	},

	height = nil,

	fixed_height = nil,
	fixed_width = nil,
	pre_cb = nil,
	post_cb = nil,
}

local defaultConfig = {
	focus_on_select = true,
	termlist = {
		enabled = true,
		side = "right",
		width = 25,
	},
	winbar = {
		tabs = false,
		list = true,
	},

	fixed_height = false,
	fixed_width = true,
	height = 15,
}

M.setup = function(config)
	if config and config ~= {} then
		M.config = vim.tbl_deep_extend("force", defaultConfig, config)
	else
		M.config = defaultConfig
	end
end

return M
