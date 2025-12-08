---@type LazySpec
return {
  "yioneko/nvim-vtsls",
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  init = function()
    -- Register lspconfig for vtsls
    local lspconfig = require "lspconfig"
    local configs = require "lspconfig.configs"

    if not configs.vtsls then
      configs.vtsls = {
        default_config = {
          name = "vtsls",
          cmd = { "vtsls", "--stdio" },
          filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
          root_dir = lspconfig.util.root_pattern("tsconfig.json", "package.json", ".git", "."),
          single_file_support = true,
          init_options = {
            hostInfo = "neovim",
          },
        },
      }
    end

    -- Setup vtsls plugin
    if pcall(require, "vtsls") then require("vtsls").config {
      refactor_auto_rename = true,
    } end
  end,
}
