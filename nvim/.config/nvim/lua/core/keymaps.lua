-- Buffers
vim.keymap.set('n', '<Tab>', ':bnext<CR>', opts)
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', opts)
vim.keymap.set('n', '<leader>x', ':bdelete!<CR>', opts)
vim.keymap.set('n', '<leader>b', '<cmd> enew <CR>', opts)
vim.keymap.set('n', '<leader>n', ':tabnew<CR>', { noremap = true })
vim.keymap.set("n", "<leader>w", "<C-w>", { noremap = true })
vim.keymap.set("i", "<C-n>", "<Nop>", { noremap = true })
vim.keymap.set("n", "<C-b>", ":!node %<CR>", { noremap = true, silent = true })

--TREE


-- Навигация по окнам без Ctrl+w
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })


-- save file
vim.keymap.set('n', '<C-s>', '<cmd> w <CR>', opts)
vim.keymap.set('i', '<C-s>', '<cmd> w <CR>', opts)
vim.keymap.set('v', '<C-s>', '<cmd> w <CR>', opts)
vim.keymap.set('c', '<C-s>', '<cmd> w <CR>', opts)
-- My configs
vim.keymap.set('n', '<C-a>', 'ggVG', { noremap = true })
vim.keymap.set('n', 'dd', '"_dd', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>d', 'dd', { noremap = true })
vim.keymap.set('v', '<C-s>', '<cmd> w <CR>', opts)
vim.keymap.set('n', '<leader>R', ':browse oldfiles<CR>', {desc='Recent (builtin)'})
-- delete single character without copying into register
vim.keymap.set('n', 'x', '"_x', opts)
-- quit file
vim.keymap.set('n', '<C-q>', '<cmd> qa!<CR>', opts)
-- Insert mode
vim.keymap.set('i', '<C-q>', '<Esc><cmd>qa!<CR>', opts)

-- Visual mode
vim.keymap.set('v', '<C-q>', '<Esc><cmd>qa!<CR>', opts)

-- Command-line mode
vim.keymap.set('c', '<C-q>', '<C-c><cmd>qa!<CR>', opts)

-- Terminal mode
vim.keymap.set('t', '<C-q>', '<C-\\><C-n><cmd>qa!<CR>', opts)

-- Paths

vim.keymap.set('i', '<C-g>', '<C-x><C-f>', { silent = true })
-- Telescope

-- Ctrl+F → Telescope find_files (во всех режимах)
vim.keymap.set({ 'n', 'i', 'v' }, '<C-f>', function()
  vim.cmd('stopinsert')
  require('telescope').extensions.file_browser.file_browser({
    path = "%:p:h",  -- начать с директории текущего файла
    cwd  = vim.loop.cwd(), -- или с директории запуска nvim
    hidden = true,
    grouped = true,
    respect_gitignore = false,
  })
end, { desc = 'File browser with Telescope' })

-- Открыть Telescope "Recent files" на <leader>R
vim.keymap.set("n", "<leader>R", "<cmd>Telescope oldfiles<cr>", {
  noremap = true,
  silent = true,
  desc = "Telescope Recent files",
})
vim.keymap.set("n", "<leader>cu", function()
  local dir = vim.fn.expand("%:p:h")
  vim.cmd("lcd " .. dir)                      -- локально для окна
  vim.cmd("split | term cursor-agent chat")   -- тут спросит trust для dir
end, { desc = "cursor-agent chat (file dir)" })

