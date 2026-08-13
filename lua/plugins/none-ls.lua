---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "jay-babu/mason-null-ls.nvim",
    opts = function(_, opts)
      if not opts.handlers then opts.handlers = {} end
      opts.handlers.biome = function() end
      opts.handlers.dprint = function() end
      opts.handlers.prettier = function() end
      opts.handlers.oxlint = function() end
    end,
  },
  opts = function(_, opts)
    local null_ls = require "null-ls"
    local helpers = require "null-ls.helpers"

    -- 1. Custom Oxlint
    local custom_oxlint = {
      name = "oxlint",
      method = null_ls.methods.DIAGNOSTICS,
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      condition = function(utils)
        return utils.root_has_file { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts", "oxlint.json" }
      end,
      generator = helpers.generator_factory {
        command = "oxlint",
        args = { "--format", "unix", "$FILENAME" },
        from_stderr = false,
        to_temp_file = true,
        format = "line",
        check_exit_code = function(code) return code <= 1 end,
        on_output = function(line, params)
          local pattern = "([^:]+):(%d+):(%d+):%s+(.*)%s+%[([^%]]+)%]"
          local _, row, col, message, rule = string.match(line, pattern)
          if row and col then
            return {
              row = row,
              col = col,
              message = message .. " [" .. rule .. "]",
              severity = vim.diagnostic.severity.WARN,
            }
          end
        end,
      },
    }

    -- 2. Custom Dprint
    local custom_dprint = {
      name = "dprint",
      method = null_ls.methods.FORMATTING,
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "markdown" },
      condition = function(utils) return utils.root_has_file { "dprint.json", ".dprint.json" } end,
      generator = helpers.formatter_factory {
        command = "dprint",
        args = { "fmt", "--stdin", "$FILENAME" },
        to_stdin = true,
      },
    }

    -- 3. Biome (Sử dụng builtin)
    local biome_formatter = null_ls.builtins.formatting.biome.with {
      condition = function(utils) return utils.root_has_file { "biome.json", "biome.jsonc" } end,
    }

    local project_sources = { custom_dprint, custom_oxlint, biome_formatter }

    -- 4. Prettier (Builtin)
    if null_ls.builtins and null_ls.builtins.formatting and null_ls.builtins.formatting.prettier then
      table.insert(
        project_sources,
        null_ls.builtins.formatting.prettier.with {
          condition = function(utils_ctx)
            return utils_ctx.root_has_file {
              ".prettierrc",
              ".prettierrc.json",
              ".prettierrc.yml",
              ".prettierrc.yaml",
              ".prettierrc.js",
              "prettier.config.js",
            }
          end,
        }
      )
    end

    opts.sources = require("astrocore").list_insert_unique(opts.sources, project_sources)
  end,
}
