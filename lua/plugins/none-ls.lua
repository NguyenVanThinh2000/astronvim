-- Customize None-ls sources
---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    -- Target the automatic handler manager
    "jay-babu/mason-null-ls.nvim",
    opts = function(_, opts)
      -- Force AstroNvim to skip automatic background setup for these engines.
      -- This ensures our conditional blocks below gain exclusive control!
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

    -- 1. Flawless Oxlint Source via helper engine factory
    local custom_oxlint = {
      name = "oxlint",
      method = null_ls.methods.DIAGNOSTICS,
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      -- Evaluates project config files dynamically at buffer execution runtime
      runtime_condition = function(params)
        local configs = { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts", "oxlint.json", "package.json" }
        for _, config in ipairs(configs) do
          if vim.fn.filereadable(params.root_dir .. "/" .. config) == 1 then return true end
        end
        return false
      end,
      generator = helpers.generator_factory {
        command = "oxlint",
        args = { "--format", "unix", "$FILENAME" },
        from_stderr = false,
        to_temp_file = true,
        format = "line",
        check_exit_code = function(code) return code <= 1 end,
        on_output = function(line, _params)
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

    -- 2. Flawless Dprint Source via formatter factory (Fixes line 380 crash)
    local custom_dprint = {
      name = "dprint",
      method = null_ls.methods.FORMATTING,
      filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "markdown" },
      runtime_condition = function(params)
        return vim.fn.filereadable(params.root_dir .. "/dprint.json") == 1
          or vim.fn.filereadable(params.root_dir .. "/.dprint.json") == 1
      end,
      generator = helpers.formatter_factory {
        command = "dprint",
        args = { "fmt", "--stdin", "$FILENAME" },
        to_stdin = true,
      },
    }

    -- 3. Safely capture builtins if they exist upstream
    local project_sources = { custom_dprint, custom_oxlint }

    if null_ls.builtins and null_ls.builtins.formatting and null_ls.builtins.formatting.biome then
      table.insert(
        project_sources,
        null_ls.builtins.formatting.biome.with {
          condition = function(utils_ctx) return utils_ctx.root_has_file { "biome.json", "biome.jsonc" } end,
        }
      )
    end

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

    -- Append everything cleanly into your AstroNvim configuration
    opts.sources = require("astrocore").list_insert_unique(opts.sources, project_sources)
  end,
}
