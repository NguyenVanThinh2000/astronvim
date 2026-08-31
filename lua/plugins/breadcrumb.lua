-- File path breadcrumb displayed in the winbar
-- Shows: folder/subfolder/filename with icons

---@type LazySpec
return {
  "utilyre/barbecue.nvim",
  name = "barbecue",
  version = "*",
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- show file path components as breadcrumb
    show_dirname = true,
    show_basename = true,
    -- use modified indicator
    show_modified = true,
    modified_indicator = "●",
    -- separator between path components
    symbols = {
      modified = "●",
      ellipsis = "…",
      separator = ">",
    },
    -- exclude certain filetypes
    exclude_filetypes = { "netrw", "toggleterm", "terminal" },
    -- attach navic context (function/class location)
    show_navic = true,
    -- theme follows colorscheme automatically
    theme = "auto",
  },
}
