-- Conform.nvim formatter setup

---@type LazySpec
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {},
    formatters = {
      biome = {
        command = "biome",
        args = { "check", "--write", "--unsafe", "$FILENAME" },
        stdin = false,
      },
      prettier = {
        command = "prettier",
        args = { "--write", "$FILENAME" },
        stdin = false,
      },
      stylua = {
        command = "stylua",
        args = { "--search-parent-directories", "--stdin-filepath", "$FILENAME", "-" },
        stdin = true,
      },
    },
    -- Format on save
    format_on_save = function(bufnr)
      -- Disable formatting for files in certain paths
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      if bufname:match "/node_modules/" then return end

      return {
        timeout_ms = 2000,
        lsp_fallback = true,
      }
    end,
    -- Notify on error
    notify_on_error = true,
  },
  config = function(_, opts)
    local conform = require "conform"

    -- Dynamic formatters based on project config
    local function get_formatters()
      local has_biome = vim.fn.filereadable(vim.fn.getcwd() .. "/biome.json") == 1

      local formatters_config = {
        javascript = has_biome and { "biome" } or { "prettier" },
        javascriptreact = has_biome and { "biome" } or { "prettier" },
        typescript = has_biome and { "biome" } or { "prettier" },
        typescriptreact = has_biome and { "biome" } or { "prettier" },
        json = has_biome and { "biome" } or { "prettier" },
        jsonc = has_biome and { "biome" } or { "prettier" },
        css = has_biome and { "biome" } or { "prettier" },
        graphql = has_biome and { "biome" } or { "prettier" },
        html = { "prettier" },
        markdown = { "prettier" },
        yaml = { "prettier" },
        lua = { "stylua" },
      }

      return formatters_config
    end

    opts.formatters_by_ft = get_formatters()
    conform.setup(opts)

    -- Update formatters when changing directories
    vim.api.nvim_create_autocmd("DirChanged", {
      callback = function()
        opts.formatters_by_ft = get_formatters()
        conform.setup(opts)
      end,
    })
  end,
  init = function() vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" end,
}
