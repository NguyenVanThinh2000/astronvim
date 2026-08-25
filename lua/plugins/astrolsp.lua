---@diagnostic disable: param-type-mismatch, missing-parameter
---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = {
        enabled = true,
        allow_filetypes = {},
        ignore_filetypes = {},
      },
      disabled = {
        -- Tắt format từ ESLint LSP để tránh xung đột với dprint/biome/prettier
        "eslint",
      },
      timeout_ms = 1000,
    },
    servers = {
      "vtsls", -- Bật TypeScript LSP (vtsls)
      "biome", -- Bật Biome LSP để soi và báo lỗi theo biome.json
    },
    ---@diagnostic disable: missing-fields
    config = {
      cssls = {
        settings = {
          css = {
            lint = {
              unknownAtRules = "ignore",
            },
          },
        },
      },
      vtsls = {
        settings = {
          typescript = {
            diagnostics = {
              ignoredCodes = { 6133, 6134 },
            },
          },
          javascript = {
            diagnostics = {
              ignoredCodes = { 6133, 6134 },
            },
          },
        },
      },
    },
    handlers = {
      -- eslint = false,
    },
    autocmds = {
      lsp_codelens_refresh = {
        cond = "textDocument/codeLens",
        {
          event = { "InsertLeave", "BufEnter" },
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    },
    mappings = {
      n = {
        gl = {
          function() vim.diagnostic.open_float() end,
          desc = "Hover diagnostics",
        },
        ["<C-]>"] = {
          function()
            local params = vim.lsp.util.make_position_params(nil, "utf-8")
            vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, _, _)
              if err then return end
              if not result or vim.tbl_isempty(result) then
                vim.notify("No definition found", vim.log.levels.INFO)
                vim.lsp.buf.references(nil, {})
                return
              end

              local current_file = vim.fn.expand "%:p"
              local current_line = vim.fn.line "."
              local def = result[1]
              local def_file = vim.uri_to_fname(def.targetUri)
              local def_line = def.targetSelectionRange.start.line + 1

              if current_file == def_file and current_line == def_line then
                require("telescope.builtin").lsp_references()
              else
                require("telescope.builtin").lsp_definitions()
              end
            end)
          end,
          desc = "Go to definition or show references if at definition",
          cond = "textDocument/definition",
        },
        ["<Leader>ca"] = {
          function() vim.lsp.buf.code_action() end,
          desc = "LSP code action",
          cond = "textDocument/codeAction",
        },

        ["<Leader>ri"] = {
          function()
            local ok, vtsls = pcall(require, "vtsls")
            if ok and vtsls.commands then
              vtsls.commands.remove_unused_imports(
                0,
                function() vim.notify("Removed unused imports", vim.log.levels.INFO) end,
                function(err) vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR) end
              )
            else
              vim.notify("vtsls plugin not loaded", vim.log.levels.WARN)
            end
          end,
          desc = "Remove unused imports (vtsls)",
          cond = function(client) return client.name == "vtsls" end,
        },
        ["<Leader>oi"] = {
          function()
            local ok, vtsls = pcall(require, "vtsls")
            if ok and vtsls.commands then
              vtsls.commands.organize_imports(
                0,
                function() vim.notify("Organized imports", vim.log.levels.INFO) end,
                function(err) vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR) end
              )
            else
              vim.notify("vtsls plugin not loaded", vim.log.levels.WARN)
            end
          end,
          desc = "Organize imports (vtsls)",
          cond = function(client) return client.name == "vtsls" end,
        },
        ["<Leader>ru"] = {
          function()
            local ok, vtsls = pcall(require, "vtsls")
            if ok and vtsls.commands then
              vtsls.commands.remove_unused(
                0,
                function() vim.notify("Remove unused", vim.log.levels.INFO) end,
                function(err) vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR) end
              )
            else
              vim.notify("vtsls plugin not loaded", vim.log.levels.WARN)
            end
          end,
          desc = "Remove unused (vtsls)",
          cond = function(client) return client.name == "vtsls" end,
        },
        ["<Leader>ai"] = {
          function()
            local ok, vtsls = pcall(require, "vtsls")
            if ok and vtsls.commands then
              vtsls.commands.add_missing_imports(
                0,
                function() vim.notify("Add missing imports", vim.log.levels.INFO) end,
                function(err) vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR) end
              )
            else
              vim.notify("vtsls plugin not loaded", vim.log.levels.WARN)
            end
          end,
          desc = "Add missing imports (vtsls)",
          cond = function(client) return client.name == "vtsls" end,
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    },
    on_attach = function(client, bufnr)
      local keymap_opts = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gk", "<Cmd>lua vim.lsp.buf.hover()<CR>", keymap_opts)

      if client.supports_method "textDocument/documentSymbol" then require("nvim-navic").attach(client, bufnr) end
    end,
  },
}
