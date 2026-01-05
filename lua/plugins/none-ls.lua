-- Customize None-ls sources
-- NOTE: Formatters moved to conform.nvim

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    -- Keep none-ls but only for diagnostics/linting, not formatting
    -- Formatting is now handled by conform.nvim
    opts.sources = opts.sources or {}
    -- Add diagnostics sources here if needed in the future
  end,
}
