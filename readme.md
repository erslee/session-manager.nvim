
# Session Manager

A Neovim plugin for session management. Quickly save and load sessions with a clean UI.

## ✨ Features
- 📂 **Save sessions** with a custom name (auto-appends `.vim`).
- 🔍 **Load sessions** choose session to load from a list.
- ⚡ **Quick keybindings** for seamless workflow.

## 📥 Installation

Using **lazy.nvim**:
```lua
{
  "erslee/session-manager.nvim",
  config = function()
    require("session-manager").setup({
	  session_prefix = "._Session",
    })
  end
}
```

Using **packer.nvim**:
```lua
use {
  "erslee/session-manager.nvim",
  config = function()
    require("session-manager").setup({
	  session_prefix = "._Session",
    })
  end
}
```

## 🚀 Usage

### Commands:
- `:SaveSession` → Save a session with a custom name.
- `:LoadSession` → Open a picker to load a session.

### Keybindings:
- `<leader>mm` → Save session.
- `<leader>ms` → Load session.

## 🔧 Configuration
The plugin works out of the box! Just call `setup()` in your Neovim config.

## 📜 License
MIT License.

---
Made with ❤️ for Neovim users!
