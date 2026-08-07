return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      list = {
        selection = {
          preselect = true,
          auto_insert = true,
        },
      },
      menu = {
        auto_show = true,
      },
    },
    sources = {
      default = { "snippets", "lsp", "path", "buffer" },
    },
  },
}
