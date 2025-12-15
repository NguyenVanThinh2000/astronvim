-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = false, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
      cssls = {
        settings = {
          css = {
            lint = {
              unknownAtRules = "ignore",
            },
          },
        },
      },
    },
    -- customize how language servers are attached
    handlers = {
      -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
      -- function(server, opts) require("lspconfig")[server].setup(opts) end

      -- the key is the server that is being setup with `lspconfig`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
      -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_codelens_refresh = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/codeLens",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "InsertLeave", "BufEnter" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
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
                -- No definition found
                vim.notify("No definition found", vim.log.levels.INFO)
                vim.lsp.buf.references(nil, {})
                return
              end

              -- Get current position
              local current_file = vim.fn.expand "%:p"
              local current_line = vim.fn.line "."
              -- Get definition position
              local def = result[1]
              local def_file = vim.uri_to_fname(def.targetUri)
              local def_line = def.targetSelectionRange.start.line + 1

              if current_file == def_file and current_line == def_line then
                -- At definition, show references
                -- vim.lsp.buf.references(nil, {})
                require("telescope.builtin").lsp_references()
              else
                -- Not at definition, go to definition
                -- vim.lsp.buf.definition()
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
          desc = "Remove unused (vtsls)",
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
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    on_attach = function(_client, bufnr)
      local opts = { noremap = true, silent = true }
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
      vim.api.nvim_buf_set_keymap(bufnr, "n", "gk", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
    end,
  },
}
