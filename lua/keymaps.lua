local keymap = vim.keymap
local opts = { noremap = true, silent = true }
-- local opt_remap = { remap = true }

-- show hover documentation
keymap.set("n", "gk", "<Cmd>lua vim.lsp.buf.hover()<cr>")
keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)

-- terminal
keymap.set({ "n", "t" }, "<C-j>", "<Cmd>ToggleTerm<CR>", opts)
keymap.set({ "i" }, "<C-j>", "<Esc><Cmd>ToggleTerm<CR>", opts)

-- -- neotree
-- keymap.set("n", "<leader>e", ":Neotree focus<cr>", opts)
-- keymap.set("n", "<C-b>", ":Neotree toggle<cr>", opts)

-- Key mappings for word-based actions: delete, select, and yank inner word
keymap.set("i", "jk", "<esc>")
keymap.set("n", "di", "diwi")
keymap.set("n", "dw", "diw")
keymap.set("n", "sw", "viw")
keymap.set("n", "yw", "viwy")

-- clear search highlights
keymap.set("n", "<leader>hh", ":nohl<CR>", opts)

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", opts) -- increment
keymap.set("n", "<leader>-", "<C-x>", opts) -- decrement

-- window management
keymap.set("n", "sv", "<C-w>v", opts) -- split window vertically
keymap.set("n", "sh", "<C-w>s", opts) -- split window horizontally
keymap.set("n", "se", "<C-w>=", opts) -- make split windows equal width & height
keymap.set("n", "sx", ":close<CR>", opts) -- close current split window

-- Save file
keymap.set("n", "<C-s>", ":w<cr>", opts)
keymap.set("n", "<leader>w", ":w<cr>", opts)
keymap.set("i", "<C-s>", "<ESC>:w<cr>", opts)

-- Duplicate line
keymap.set("n", "<A-S-j>", "yyp", opts)
-- Duplicate line in visual mode
keymap.set("v", "<A-S-j>", "yP", opts)

-- Move lines and group lines up, down for windows
keymap.set("n", "<A-k>", ":m .-2<cr>", opts)
keymap.set("n", "<A-j>", ":m .+1<cr>", opts)
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)

-- move quickly up and down
keymap.set("n", "<S-j>", ":+5<cr>", opts)
keymap.set("n", "<S-k>", ":-5<cr>", opts)

-- move to first or last charactor of the line
keymap.set("n", "<S-l>", "$", opts)
keymap.set("v", "<S-l>", "$h", opts)
keymap.set("n", "<S-h>", "^", opts)
keymap.set("v", "<S-h>", "^", opts)

-- paste over currently selected text without yanking it
keymap.set("v", "p", '"_dP', opts)
keymap.set("n", "dd", '"_dd', opts)

-- quit
keymap.set("n", "<leader>q", ":q!<cr>", opts)

-- select all
keymap.set("n", "<C-a>", "gg<S-v>G", opts)

---@type LazySpec
return {}
