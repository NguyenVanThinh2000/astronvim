if vim.g.vscode then return {} end -- don't do anything in non-vscode instances

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.mlua",
  callback = function() vim.bo.filetype = "mlua" end,
})

local lspconfig = require "lspconfig"
local configs = require "lspconfig.configs"

if not configs.mlua_ls then
  configs.mlua_ls = {
    default_config = {
      cmd = { "node", "/home/thinhnguyen/.config/mlua-ls/server.js", "--stdio" },
      filetypes = { "mlua" },
      root_dir = lspconfig.util.root_pattern(".git", "."),
    },
  }
end

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  opts = {
    config = {
      lua_ls = {
        filetypes = { "lua" },
      },
      mlua_ls = {
        on_attach = function(_, bufnr) print("mlua_ls attached to buffer " .. bufnr) end,
      },
    },
  },
}
