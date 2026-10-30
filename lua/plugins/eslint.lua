---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type AstroLSPOpts
    opts = {
      config = {
        eslint = {
          root_dir = function(arg, on_dir)
            local fname = type(arg) == "number" and vim.api.nvim_buf_get_name(arg) or arg
            local config_files = {
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.cjs",
              ".eslintrc.yaml",
              ".eslintrc.yml",
              ".eslintrc.json",
              "eslint.config.js",
              "eslint.config.mjs",
              "eslint.config.cjs",
              "eslint.config.ts",
              "eslint.config.mts",
              "eslint.config.cts",
            }
            config_files = require("lspconfig.util").insert_package_json(config_files, "eslintConfig", fname)
            local config_file = vim.fs.find(config_files, { path = fname, upward = true })[1]
            if not config_file then return end

            local root = vim.fs.dirname(config_file)
            local has_eslint = vim.fs.find(
              { "node_modules/eslint/package.json", ".pnp.cjs", ".pnp.js" },
              { path = root, upward = true }
            )[1]
            if not has_eslint then return end
            if type(on_dir) == "function" then on_dir(root) end
            return root
          end,
          handlers = {
            ["eslint/noLibrary"] = function() return {} end,
          },
        },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, { "eslint" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, { "eslint-lsp" })
    end,
  },
  {
    "nvim-mini/mini.icons",
    optional = true,
    opts = function(_, opts)
      opts.file = opts.file or {}
      local eslint_files = {
        -- ESLint <=8 (Deprecated)
        ".eslintignore",
        ".eslintrc",
        ".eslintrc.cjs",
        ".eslintrc.js",
        ".eslintrc.json",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        -- ESLint >=9
        "eslint.config.cjs",
        "eslint.config.cts",
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.mts",
        "eslint.config.ts",
      }
      for _, filename in ipairs(eslint_files) do
        opts.file[filename] = { glyph = "󰱺", hl = "MiniIconsYellow" }
      end
    end,
  },
}
