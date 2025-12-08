# Neovim Setup Guide

Hướng dẫn setup các công cụ và configuration cho Neovim.

## LSP - Language Server Protocol

### TypeScript/JavaScript - vtsls

#### Cài đặt Server

Vtsls là Language Server cho TypeScript/JavaScript được xây dựng từ VSCode TypeScript extension.

```bash
npm install -g @vtsls/language-server
```

**Yêu cầu:**
- Node.js >= 16

**Kiểm tra cài đặt:**
```bash
which vtsls  # Nên có output như: /path/to/vtsls
vtsls --version
```

#### Configuration Files

**1. lua/plugins/vtsls.lua** - Setup plugin và lspconfig
```lua
---@type LazySpec
return {
  "yioneko/nvim-vtsls",
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  init = function()
    -- Register lspconfig for vtsls
    local lspconfig = require "lspconfig"
    local configs = require "lspconfig.configs"

    if not configs.vtsls then
      configs.vtsls = {
        default_config = {
          name = "vtsls",
          cmd = { "vtsls", "--stdio" },
          filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
          root_dir = lspconfig.util.root_pattern("tsconfig.json", "package.json", ".git", "."),
          single_file_support = true,
          init_options = {
            hostInfo = "neovim",
          },
        },
      }
    end

    -- Setup vtsls plugin
    if pcall(require, "vtsls") then
      require("vtsls").config {
        refactor_auto_rename = true,
      }
    end
  end,
}
```

**2. lua/plugins/mlua.lua** - vtsls settings trong AstroLSP config
```lua
vtsls = {
  -- Ensure vtsls is properly configured
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = false },
        variableTypes = { enabled = false },
        propertyDeclarationTypes = { enabled = false },
        functionLikeReturnTypes = { enabled = false },
        enumMemberValues = { enabled = true },
      },
    },
  },
  on_attach = function(_, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "<leader>ru", "<cmd>lua require('vtsls').commands.remove_unused_imports(0)<cr>", opts)
  end,
}
```

**3. lua/plugins/astrolsp.lua** - LSP keybindings
```lua
-- Trong section: opts.mappings.n
["<Leader>ca"] = {
  function() vim.lsp.buf.code_action() end,
  desc = "LSP code action",
  cond = "textDocument/codeAction",
},
["<Leader>roi"] = {
  function()
    local ok, vtsls = pcall(require, "vtsls")
    if ok and vtsls.commands then
      vtsls.commands.remove_unused_imports(0, function()
        vim.notify("Removed unused imports", vim.log.levels.INFO)
      end, function(err)
        vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR)
      end)
    else
      vim.notify("vtsls plugin not loaded", vim.log.levels.WARN)
    end
  end,
  desc = "Remove unused imports (vtsls)",
  cond = function(client) return client.name == "vtsls" end,
},
["<Leader>roa"] = {
  function()
    local ok, vtsls = pcall(require, "vtsls")
    if ok and vtsls.commands then
      vtsls.commands.organize_imports(0, function()
        vim.notify("Organized imports", vim.log.levels.INFO)
      end, function(err)
        vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR)
      end)
    else
      vim.notify("vtsls plugin not loaded", vim.log.levels.WARN)
    end
  end,
  desc = "Organize imports (vtsls)",
  cond = function(client) return client.name == "vtsls" end,
},
```

#### Keybindings

| Keybinding | Mô tả | Ghi chú |
|-----------|-------|--------|
| `<leader>ca` | LSP code action | Mở menu code actions |
| `<leader>roi` | Remove unused imports | Xóa imports không dùng |
| `<leader>roa` | Organize imports | Sắp xếp/tổ chức imports |
| `<leader>ru` | Remove unused imports | Alias khác (mlua.lua) |
| `gk` | Hover documentation | Xem documentation |
| `<leader>rn` | Rename symbol | Đổi tên biến/hàm |

#### Cách sử dụng

1. **Kiểm tra vtsls đã attach:**
   ```vim
   :LspInfo
   ```
   Tìm `vtsls` trong danh sách clients

2. **Mở file TypeScript/JavaScript:**
   ```bash
   nvim app.ts
   # hoặc
   nvim app.tsx
   # hoặc
   nvim index.js
   ```

3. **Thực hiện commands:**
   - Gõ `<space>roi` để remove unused imports
   - Gõ `<space>roa` để organize imports
   - Bạn sẽ thấy notification khi command thực thi

#### Troubleshooting

**Problem: `:LspInfo` không hiển thị vtsls**
- Solution: Chạy `:LspRestart` để restart LSP
- Hoặc khởi động lại Neovim

**Problem: Commands không hoạt động**
- Kiểm tra: `which vtsls` (phải tìm được binary)
- Kiểm tra: `:LspInfo` (vtsls phải attached)
- Kiểm tra log: `:LspLog`

**Problem: vtsls không được cài đặt**
```bash
# Cài lại
npm install -g @vtsls/language-server

# Verify
which vtsls
vtsls --version
```

#### Available vtsls Commands

Theo [nvim-vtsls documentation](https://github.com/yioneko/nvim-vtsls):

- `remove_unused_imports` - Xóa imports không dùng
- `organize_imports` - Sắp xếp imports theo thứ tự
- `sort_imports` - Sắp xếp imports
- `fix_all` - Fix tất cả lỗi có thể fix được
- `remove_unused` - Xóa biến/code không dùng
- `add_missing_imports` - Thêm imports thiếu
- `restart_tsserver` - Restart tsserver
- `select_ts_version` - Chọn phiên bản TypeScript
- `goto_project_config` - Mở tsconfig.json
- `goto_source_definition` - Đến source definition
- `file_references` - Hiển thị file references

#### References

- [vtsls GitHub](https://github.com/yioneko/vtsls)
- [nvim-vtsls GitHub](https://github.com/yioneko/nvim-vtsls)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

---

## Lua LSP

### lua-language-server

Đã được cấu hình qua Mason tool installer.

**Keybindings:** Giống như vtsls

---

## Notes

- Tất cả LSP keybindings được quản lý ở `lua/plugins/astrolsp.lua`
- Vtsls plugin cần file `.ts`, `.tsx`, `.js`, `.jsx` để được load
- Ensure vtsls server binary tồn tại trước khi sử dụng


---

## Quick Reference - Cài đặt nhanh

### 1. Cài vtsls server
```bash
npm install -g @vtsls/language-server
```

### 2. Restart Neovim hoặc chạy
```vim
:LspRestart
```

### 3. Test với TypeScript/JavaScript file
```bash
nvim app.ts
:LspInfo  # Kiểm tra vtsls đã attach
<space>roi  # Remove unused imports
<space>roa  # Organize imports
```

### Keybindings cheat sheet
```
<space>ca   - Code action (tất cả LSP)
<space>roi  - Remove unused imports (vtsls)
<space>roa  - Organize imports (vtsls)
<space>ru   - Remove unused imports (alias)
gk          - Hover documentation
<space>rn   - Rename symbol
gl          - Show diagnostics
<C-]>       - Go to declaration
```

---

