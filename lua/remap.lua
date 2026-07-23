-- set spacebar as leader key
vim.g.mapleader = " "

-- buffers walkthrough
vim.keymap.set("n", "<leader>n", ":bn<cr>")
vim.keymap.set("n", "<leader>p", ":bp<cr>")
vim.keymap.set("n", "<leader>x", ":bd<cr>")

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Terminal open bindings
vim.api.nvim_create_autocmd("TermOpen", {
        group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
        callback = function()
                -- disable number at terminal ... not to make it awkward
                -- use window-local options so global preferences are preserved
                vim.wo.number = false
                vim.wo.relativenumber = false
        end,
})
