---@type LazySpec
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    -- dependencies = {
    --   "nvim-lua/plenary.nvim",
    --   "MunifTanjim/nui.nvim",
    --   "nvim-tree/nvim-web-devicons", -- optional, but recommended
    -- },
    lazy = false, -- neo-tree will lazily load itself
    opts = {
      close_if_last_window = false,
      filesystem = {
        filtered_items = {
          visible = false, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false, -- only works on Windows for hidden files/directories
          hide_by_name = {
            --"node_modules"
          },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            --"*/src/*/tsconfig.json",
          },
          always_show = { -- remains visible even if other settings would normally hide it
            --".gitignored",
          },
          always_show_by_pattern = { -- uses glob style patterns
            --".env*",
          },
          never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
            --".DS_Store",
            --"thumbs.db"
          },
          never_show_by_pattern = { -- uses glob style patterns
            --".null-ls_*",
          },
        },
      },
      buffers = {
        follow_current_file = {
          enabled = false,
          leave_dirs_open = true,
        },
      },
    },
  },
}
