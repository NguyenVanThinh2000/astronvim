local snippet_path = vim.fn.stdpath "config" .. "/lua/snippets"
pcall(function()
  require("luasnip.loaders.from_vscode").lazy_load {
    paths = { snippet_path },
  }
end)
