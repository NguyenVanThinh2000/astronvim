---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    {
      "jay-babu/mason-null-ls.nvim",
      opts = function(_, opts)
        if not opts.handlers then opts.handlers = {} end
        opts.handlers.biome = function() end
        opts.handlers.dprint = function() end
        opts.handlers.prettier = function() end
        opts.handlers.oxlint = function() end
        opts.handlers.eslint_d = function() end
        opts.handlers.eslint = function() end
        return opts
      end,
    },
    "nvimtools/none-ls-extras.nvim",
  },
  opts = function(_, opts)
    opts.update_on_change = true
    local null_ls = require "null-ls"
    local helpers = require "null-ls.helpers"
    local filetypes = {
      "css",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "json",
      "jsonc",
    }

    local root_dir = vim.fn.getcwd()

    local function get_root_package_json_str()
      local pkg_path = root_dir .. "/package.json"
      if vim.fn.filereadable(pkg_path) == 1 then
        local lines = vim.fn.readfile(pkg_path)
        return table.concat(lines, "\n")
      end
      return nil
    end

    local pkg_content = get_root_package_json_str()

    local function has_root_config(filenames, keywords)
      if filenames then
        for _, file in ipairs(filenames) do
          if vim.fn.filereadable(root_dir .. "/" .. file) == 1 then return true end
        end
      end

      if pkg_content and keywords then
        for _, kw in ipairs(keywords) do
          if pkg_content:find(kw, 1, true) then return true end
        end
      end

      return false
    end

    -- 1. Custom Biome Formatter
    local custom_biome_formatter = {
      name = "biome",
      method = null_ls.methods.FORMATTING,
      filetypes = filetypes,
      condition = function() return has_root_config({ "biome.json", "biome.jsonc" }, { "biome" }) end,
      generator = helpers.formatter_factory {
        command = "biome",
        args = { "check", "--write", "--stdin-file-path=$FILENAME" },
        to_stdin = true,
      },
    }

    -- 2. Custom Oxlint
    local custom_oxlint = {
      name = "oxlint",
      method = null_ls.methods.DIAGNOSTICS,
      filetypes = filetypes,
      condition = function()
        return has_root_config({
          ".oxlintrc",
          ".oxlintrc.json",
          "oxlint.json",
          "oxlint.jsonc",
          "oxlintrc.json",
        }, { "oxlint" })
      end,
      generator = helpers.generator_factory {
        command = "oxlint",
        args = { "--format", "unix", "$FILENAME" },
        from_stderr = false,
        to_temp_file = true,
        format = "line",
        check_exit_code = function(code) return code <= 1 end,
        on_output = function(line, _)
          local pattern = "([^:]+):(%d+):(%d+):%s+(.*)%s+%[([^%]]+)%]"
          local _, row, col, message, rule = string.match(line, pattern)
          if row and col then
            return {
              row = tonumber(row),
              col = tonumber(col),
              message = message .. " [" .. rule .. "]",
              severity = vim.diagnostic.severity.WARN,
            }
          end
        end,
      },
    }

    -- 3. Custom Dprint
    local custom_dprint = {
      name = "dprint",
      method = null_ls.methods.FORMATTING,
      filetypes = filetypes,
      condition = function() return has_root_config({ "dprint.json", ".dprint.json", "dprint.jsonc" }, { "dprint" }) end,
      generator = helpers.formatter_factory {
        command = "dprint",
        args = { "fmt", "--stdin", "$FILENAME" },
        to_stdin = true,
      },
    }

    -- 4. Prettier
    local prettier_formatter = null_ls.builtins.formatting.prettier
      and null_ls.builtins.formatting.prettier.with {
        condition = function()
          return has_root_config({
            ".prettierrc",
            ".prettierrc.json",
            ".prettierrc.yml",
            ".prettierrc.yaml",
            ".prettierrc.jsonc",
            ".prettierrc.js",
            ".prettierrc.cjs",
            ".prettierrc.mjs",
            "prettier.config.js",
            "prettier.config.cjs",
            "prettier.config.mjs",
            "prettier.config.ts",
          }, { "prettier" })
        end,
      }

    -- 5. ESLint_d
    local ok_eslint, eslint_mod = pcall(require, "none-ls.diagnostics.eslint_d")
    local eslint_diagnostics = ok_eslint
      and eslint_mod.with {
        filetypes = filetypes,
        condition = function()
          return has_root_config({
            "eslint.config.js",
            "eslint.config.mjs",
            "eslint.config.cjs",
            "eslint.config.ts",
            "eslint.config.mts",
            "eslint.config.cts",
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.yaml",
            ".eslintrc.yml",
            ".eslintrc.json",
          }, { "eslintConfig" })
        end,
        on_output = function(params)
          if type(params.output) ~= "string" then return eslint_mod._opts.on_output(params) end
          return {}
        end,
      }

    local sources = {}
    if custom_biome_formatter then table.insert(sources, custom_biome_formatter) end
    if custom_oxlint then table.insert(sources, custom_oxlint) end
    if custom_dprint then table.insert(sources, custom_dprint) end
    if prettier_formatter then table.insert(sources, prettier_formatter) end
    if eslint_diagnostics then table.insert(sources, eslint_diagnostics) end

    opts.sources = require("astrocore").list_insert_unique(opts.sources, sources)
    return opts
  end,
}
