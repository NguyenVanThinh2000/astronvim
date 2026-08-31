local cache_file = vim.fn.stdpath "cache" .. "/none_ls_sources_cache.json"

local function load_disk_cache()
  local f = io.open(cache_file, "r")
  if not f then return {} end
  local content = f:read "*a"
  f:close()
  if not content or content == "" then return {} end
  local ok, res = pcall(vim.json.decode, content)
  return (ok and type(res) == "table") and res or {}
end

local disk_cache = load_disk_cache()

local function save_disk_cache()
  local ok, encoded = pcall(vim.json.encode, disk_cache)
  if ok then
    local f = io.open(cache_file, "w")
    if f then
      f:write(encoded)
      f:close()
    end
  end
end

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
        -- opts.handlers.eslint_d = function() end
        -- opts.handlers.eslint = function() end
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
      "css",
      "scss",
    }

    local function check_root_config(filenames, keywords)
      local dir = vim.fn.getcwd()
      if filenames then
        for _, file in ipairs(filenames) do
          if vim.fn.filereadable(dir .. "/" .. file) == 1 then return true end
        end
      end

      if keywords then
        local pkg_path = dir .. "/package.json"
        if vim.fn.filereadable(pkg_path) == 1 then
          local lines = vim.fn.readfile(pkg_path)
          local pkg_content = table.concat(lines, "\n")
          for _, kw in ipairs(keywords) do
            if pkg_content:find(kw, 1, true) then return true end
          end
        end
      end

      return false
    end

    local function is_source_enabled(source_name, filenames, keywords)
      local dir = vim.fn.getcwd()

      if disk_cache[dir] and disk_cache[dir][source_name] ~= nil then return disk_cache[dir][source_name] end

      local enabled = check_root_config(filenames, keywords)

      if not disk_cache[dir] then disk_cache[dir] = {} end
      disk_cache[dir][source_name] = enabled
      save_disk_cache()

      return enabled
    end

    vim.api.nvim_create_user_command("NoneLsRefresh", function()
      local dir = vim.fn.getcwd()
      disk_cache[dir] = nil
      save_disk_cache()
      vim.notify("refresh config: " .. dir, vim.log.levels.INFO)
    end, { desc = "Rescan none-ls config for current project" })

    -- 1. Custom Biome Formatter
    local has_biome_config = is_source_enabled("biome", { "biome.json", "biome.jsonc" }, { "biome" })
    local custom_biome_formatter = {
      name = "biome",
      method = null_ls.methods.FORMATTING,
      filetypes = filetypes,
      condition = function() return has_biome_config end,
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
        return is_source_enabled("oxlint", {
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
      condition = function()
        return is_source_enabled("dprint", { "dprint.json", ".dprint.json", "dprint.jsonc" }, { "dprint" })
      end,
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
          return is_source_enabled("prettier", {
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
    -- local ok_eslint, eslint_mod = pcall(require, "none-ls.diagnostics.eslint_d")
    -- local eslint_diagnostics = ok_eslint
    --   and eslint_mod.with {
    --     filetypes = filetypes,
    --     condition = function()
    --       local enabled = is_source_enabled("eslint", {
    --         "eslint.config.js",
    --         "eslint.config.mjs",
    --         "eslint.config.cjs",
    --         "eslint.config.ts",
    --         "eslint.config.mts",
    --         "eslint.config.cts",
    --         ".eslintrc",
    --         ".eslintrc.js",
    --         ".eslintrc.cjs",
    --         ".eslintrc.yaml",
    --         ".eslintrc.yml",
    --         ".eslintrc.json",
    --       }, { "eslintConfig" })
    --       return enabled
    --     end,
    --     on_output = function(params)
    --       local raw = params.output
    --       local data = nil
    --
    --       if type(raw) == "table" then
    --         data = raw
    --       elseif type(raw) == "string" then
    --         local json_start = raw:find "%[%s*{"
    --         if json_start then
    --           local json_str = raw:sub(json_start)
    --           local ok, decoded = pcall(vim.json.decode, json_str)
    --           if ok and type(decoded) == "table" then data = decoded end
    --         end
    --       end
    --
    --       if not data then return {} end
    --
    --       local diagnostics = {}
    --       for _, file_res in ipairs(data) do
    --         if type(file_res) == "table" and file_res.messages then
    --           for _, m in ipairs(file_res.messages) do
    --             if m.line and m.column and m.message then
    --               table.insert(diagnostics, {
    --                 row = m.line,
    --                 col = m.column,
    --                 end_row = m.endLine or m.line,
    --                 end_col = m.endColumn or m.column,
    --                 message = m.message .. (m.ruleId and (" [" .. m.ruleId .. "]") or ""),
    --                 severity = m.severity == 1 and vim.diagnostic.severity.WARN or vim.diagnostic.severity.ERROR,
    --               })
    --             end
    --           end
    --         end
    --       end
    --
    --       return diagnostics
    --     end,
    --   }

    local sources = {}
    if custom_biome_formatter then table.insert(sources, custom_biome_formatter) end
    if custom_oxlint then table.insert(sources, custom_oxlint) end
    if custom_dprint then table.insert(sources, custom_dprint) end
    if prettier_formatter then table.insert(sources, prettier_formatter) end
    -- if eslint_diagnostics then table.insert(sources, eslint_diagnostics) end

    opts.sources = require("astrocore").list_insert_unique(opts.sources, sources)
    return opts
  end,
}
