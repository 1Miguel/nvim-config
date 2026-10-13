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

vim.keymap.set("n", "<C-h>", "<Cmd>TmuxNavigateLeft<CR>", { desc = "Tmux: Left" })
vim.keymap.set("n", "<C-j>", "<Cmd>TmuxNavigateDown<CR>", { desc = "Tmux: Down" })
vim.keymap.set("n", "<C-k>", "<Cmd>TmuxNavigateUp<CR>", { desc = "Tmux: Up" })
vim.keymap.set("n", "<C-l>", "<Cmd>TmuxNavigateRight<CR>", { desc = "Tmux: Right" })
vim.keymap.set("n", "<C-\\>", "<Cmd>TmuxNavigatePrevious<CR>", { desc = "Tmux: Previous" })

vim.keymap.set({ "n", "x" }, "<leader>sv", function()
  require("grug-far").open({ visualSelectionUsage = "auto-detect" })
end, { desc = "grug-far: Search within range" })

vim.keymap.set({ "n", "x" }, "<leader>sf", function()
  require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "grug-far: Search within range" })
