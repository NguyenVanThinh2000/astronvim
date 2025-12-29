-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    -- opts variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics

    -- Auto-detect and register formatters based on project config
    local formatters = {}

    -- Check if project uses Biome
    if vim.fn.filereadable(vim.fn.getcwd() .. "/biome.json") == 1 then
      table.insert(formatters, null_ls.builtins.formatting.biome)
    end

    -- Check if project uses Prettier
    if
      vim.fn.filereadable(vim.fn.getcwd() .. "/.prettierrc") == 1
      or vim.fn.filereadable(vim.fn.getcwd() .. "/.prettierrc.json") == 1
      or vim.fn.filereadable(vim.fn.getcwd() .. "/.prettierrc.js") == 1
      or vim.fn.filereadable(vim.fn.getcwd() .. "/prettier.config.js") == 1
    then
      table.insert(formatters, null_ls.builtins.formatting.prettier)
    end

    -- Only insert new sources, do not replace the existing ones
    -- (If you wish to replace, use `opts.sources = {}` instead of the `list_insert_unique` function)
    opts.sources = require("astrocore").list_insert_unique(opts.sources, formatters)
  end,
}
