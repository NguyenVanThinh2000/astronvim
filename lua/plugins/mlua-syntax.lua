return {
  name = "mlua-syntax",
  dir = vim.fn.stdpath "config",
  config = function()
    vim.filetype.add {
      extension = {
        mlua = "mlua",
      },
    }

    -- Tạo highlight groups
    vim.api.nvim_set_hl(0, "mluaKeyword", { link = "Keyword" })
    vim.api.nvim_set_hl(0, "mluaFunction", { link = "Function" })
    vim.api.nvim_set_hl(0, "mluaString", { link = "String" })
    vim.api.nvim_set_hl(0, "mluaComment", { link = "Comment" })
    vim.api.nvim_set_hl(0, "mluaNumber", { link = "Number" })
    vim.api.nvim_set_hl(0, "mluaConstant", { link = "Constant" })
    vim.api.nvim_set_hl(0, "mluaOperator", { link = "Operator" })
    vim.api.nvim_set_hl(0, "mluaClass", { link = "Type" })
    vim.api.nvim_set_hl(0, "mluaAttribute", { link = "PreProc" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "mlua",
      callback = function()
        vim.opt_local.commentstring = "--%s"
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.expandtab = true

        -- Simple and safe syntax patterns
        local patterns = {
          -- Keywords
          {
            "mluaKeyword",
            "\\<\\(break\\|continue\\|do\\|else\\|for\\|if\\|elseif\\|goto\\|return\\|then\\|repeat\\|while\\|until\\|end\\|function\\|local\\|in\\|not\\|or\\|and\\)\\>",
          },
          {
            "mluaKeyword",
            "\\<\\(script\\|method\\|property\\|member\\|extends\\|override\\|handler\\|constructor\\|operator\\|emitter\\|static\\|readonly\\)\\>",
          },

          -- Constants
          { "mluaConstant", "\\<\\(false\\|nil\\|true\\|_G\\)\\>" },

          -- Numbers
          { "mluaNumber", "\\<\\d\\+\\>" },
          { "mluaNumber", "\\<\\d\\+\\.\\d\\+\\>" },
          { "mluaNumber", "\\<0x\\x\\+\\>" },

          -- Strings
          { "mluaString", '"[^"]*"' },
          { "mluaString", "'[^']*'" },
          { "mluaString", "\\[\\[.*\\]\\]" },

          -- Comments
          { "mluaComment", "--.*$" },

          -- Operators
          { "mluaOperator", "+" },
          { "mluaOperator", "-" },
          { "mluaOperator", "\\*" },
          { "mluaOperator", "/" },
          { "mluaOperator", "%" },
          { "mluaOperator", "\\^" },
          { "mluaOperator", "==" },
          { "mluaOperator", "~=" },
          { "mluaOperator", "<=" },
          { "mluaOperator", ">=" },
          { "mluaOperator", "<" },
          { "mluaOperator", ">" },
          { "mluaOperator", "\\.\\.\\." },
          { "mluaOperator", "\\.\\." },

          -- Attributes
          { "mluaAttribute", "@\\w\\+" },

          -- Function names (simple patterns)
          { "mluaFunction", "\\<function\\s\\+\\w\\+" },
          { "mluaFunction", "\\<method\\s\\+\\w\\+" },
          { "mluaFunction", "\\<handler\\s\\+\\w\\+" },
          { "mluaFunction", "\\<constructor\\s\\+\\w\\+" },
          { "mluaFunction", "\\<emitter\\s\\+\\w\\+" },

          -- Class names
          { "mluaClass", "\\<script\\s\\+\\w\\+" },
          { "mluaClass", "\\<extends\\s\\+\\w\\+" },
          { "mluaClass", "\\<property\\s\\+\\w\\+" },
        }

        -- Apply syntax highlighting safely
        for _, pattern in ipairs(patterns) do
          pcall(vim.fn.matchadd, pattern[1], pattern[2])
        end

        -- Auto-closing pairs
        local buf = vim.api.nvim_get_current_buf()
        local pairs_map = {
          ["("] = ")",
          ["["] = "]",
          ["{"] = "}",
          ['"'] = '"',
          ["'"] = "'",
        }

        for open, close in pairs(pairs_map) do
          vim.keymap.set("i", open, function() return open .. close .. "<Left>" end, { buffer = buf, expr = true })
        end
      end,
    })
  end,
}
