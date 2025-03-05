
# Telescope Session Manager

A Neovim plugin for session management using **Telescope**. Quickly save and load sessions with a clean UI and fuzzy selection.

## ✨ Features
- 📂 **Save sessions** with a custom name (auto-appends `.vim`).
- 🔍 **Load sessions** using a Telescope picker.
- ⚡ **Quick keybindings** for seamless workflow.

## 📥 Installation

Using **lazy.nvim**:
```lua
{
  "erslee/session-manager.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("session-manager").setup()
  end
}
```

Using **packer.nvim**:
```lua
use {
  "erslee/session-manager.nvim",
  requires = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("session-manager").setup()
  end
}
```

## 🚀 Usage

### Commands:
- `:SaveSession` → Save a session with a custom name.
- `:LoadSession` → Open a Telescope picker to load a session.

### Keybindings:
- `<leader>mm` → Save session.
- `<leader>ls` → Load session.

## 🔧 Configuration
The plugin works out of the box! Just call `setup()` in your Neovim config.

## 📜 License
MIT License.

---
Made with ❤️ for Neovim users!
