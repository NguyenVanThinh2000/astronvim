vim.keymap.set("n", "<leader>Lr", "<cmd>Leet run<cr>", { desc = "Run leetcode" })
vim.keymap.set("n", "<leader>Ls", "<cmd>Leet submit<cr>", { desc = "Run leetcode" })
return {
  "kawre/leetcode.nvim",
  build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
  dependencies = {
    -- include a picker of your choice, see picker section for more details
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    -- configuration goes here
    lang = "javascript",
  },
}
