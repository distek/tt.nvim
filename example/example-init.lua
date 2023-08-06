local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
                "git",
                "clone",
                "--filter=blob:none",
                "https://github.com/folke/lazy.nvim.git",
                "--branch=stable", -- latest stable release
                lazypath,
        })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
        {
                dir = "/tmp/tt.nvim",
                config = function()
                        require("tt").setup({
                                focus_on_select = false,
                                termlist = {
                                        enabled = true,
                                        side = "right",
                                        width = 25,
                                },
                                winbar = {
                                        tabs = true,
                                        list = false,
                                },

                                fixed_height = false,
                                fixed_width = false, -- handled by edgy
                                height = 15,
                        })
                end,
        },
})

local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

map("t", "<A-Tab>", function()
        if require("tt"):IsOpen() then
                require("tt.terminal"):FocusNext()
        end
end, { desc = "Focus next terminal" })

map("t", "<A-S-Tab>", function()
        if require("tt"):IsOpen() then
                require("tt.terminal"):FocusPrevious()
        end
end, { desc = "Focus previous terminal" })

map("n", "<A-Tab>", function()
        if require("tt"):IsOpen() then
                require("tt.terminal"):FocusNext()
        end
end, { desc = "Focus next terminal" })

map("n", "<A-S-Tab>", function()
        if require("tt"):IsOpen() then
                require("tt.terminal"):FocusPrevious()
        end
end, { desc = "Focus previous terminal" })

map({ "n", "t" }, "<C-w>j", "<C-\\><C-n><C-w>j", {})
map({ "n", "t" }, "<C-w>h", "<C-\\><C-n><C-w>h", {})
map({ "n", "t" }, "<C-w>k", "<C-\\><C-n><C-w>k", {})
map({ "n", "t" }, "<C-w>l", "<C-\\><C-n><C-w>l", {})

map({ "n", "t" }, "<C-w>t", function()
        require("tt.terminal"):Toggle()
end, { desc = "Focus previous terminal" })

