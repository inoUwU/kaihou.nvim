# kaihou.nvim

> [!WARNING]
> **⚠️ This project is still under development and has not been tested yet. Use at your own risk. ⚠️**

[日本語](docs/README.ja.md)

`kaihou.nvim` helps you "free" your current project from Windows Defender real-time scanning by managing Defender exclusion paths directly from Neovim.

## Features

- Windows-only safety guard
- Async, non-blocking PowerShell execution via `vim.system()`
- Project root detection using `vim.fs.root()` with smart fallbacks
- Administrator privilege check before any Defender modification
- Simple commands:
  - `:DefenderCheck` / `:KaihouCheck`
  - `:DefenderToggle` / `:KaihouToggle`
  - `:DefenderList` / `:KaihouList`
- Optional auto-check on `VimEnter`
- No external dependencies
- Lazy.nvim compatible

## Requirements

- Neovim 0.10+
- Windows
- Windows Defender available (`Get-MpPreference`, `Add-MpPreference`, `Remove-MpPreference`)

## Installation (lazy.nvim)

```lua
{
  "inoUwU/kaihou.nvim",
  config = function()
    require("kaihou").setup({
      auto_check = true,
    })
  end,
}
```

## Setup

```lua
require("kaihou").setup({
  auto_check = true,
})
```

### Options

- `auto_check` (boolean, default: `true`)
  - If enabled, runs `:DefenderCheck` logic automatically on `VimEnter`.

## Commands

- `:DefenderCheck` / `:KaihouCheck`
  - Checks whether the current project root is already in Defender exclusions.
- `:DefenderToggle` / `:KaihouToggle`
  - Adds/removes the current project root from Defender exclusions.
  - Requires administrator privileges to modify Defender preferences.
- `:DefenderList` / `:KaihouList`
  - Lists current Defender exclusion paths using `vim.ui.select`.

## Project Root Detection

`kaihou.nvim` resolves the project root using:

- `.git`
- `package.json`
- `Cargo.toml`
- `pyproject.toml`

If no marker is found, it falls back to the current working directory.

## Notes

- On non-Windows systems, commands are safely skipped with warnings.
- Defender modifications are skipped when Neovim is not running with administrator privileges.
- All operations are asynchronous and do not block the UI.

## License

MIT
