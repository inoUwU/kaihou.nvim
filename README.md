# kaihou.nvim

> [!WARNING]
> **⚠️ This project is still under development and has not been tested yet. Use at your own risk. ⚠️**

[日本語](docs/README.ja.md)

`kaihou.nvim` helps you "free" your current project from Windows Defender real-time scanning by managing Defender exclusion paths directly from Neovim.

## Features

- Windows-only safety guard
- Async, non-blocking PowerShell execution via `vim.system()`
- Project root detection using `vim.fs.root()` with smart fallbacks
- Registry-based Defender exclusion reads (no administrator privilege needed for check/list)
- Administrator privilege check before any Defender modification (toggle)
- Simple commands:
  - `:DefenderCheck` / `:KaihouCheck`
  - `:DefenderToggle` / `:KaihouToggle`
  - `:DefenderList` / `:KaihouList`
- No external dependencies
- Lazy.nvim compatible

## Requirements

- Neovim 0.10+
- Windows
- Windows Defender available

## Installation (lazy.nvim)

```lua
{
  "inoUwU/kaihou.nvim",
}
```

## Commands

- `:DefenderCheck` / `:KaihouCheck`
  - Checks whether the current project root is already in Defender exclusions.
  - Reads directly from the Windows Registry; no administrator privilege required.
- `:DefenderToggle` / `:KaihouToggle`
  - Adds/removes the current project root from Defender exclusions.
  - Requires administrator privileges to modify the registry.
- `:DefenderList` / `:KaihouList`
  - Lists current Defender exclusion paths using `vim.ui.select`.
  - Reads directly from the Windows Registry; no administrator privilege required.

## Project Root Detection

`kaihou.nvim` resolves the project root using:

- `.git`
- `package.json`
- `Cargo.toml`
- `pyproject.toml`

If no marker is found, it falls back to the current working directory.

## Notes

- On non-Windows systems, commands are safely skipped with warnings.
- Check and list operations read the registry directly and do not require administrator privileges.
- Toggle (add/remove) operations modify the registry and require administrator privileges.
- All operations are asynchronous and do not block the UI.

## License

MIT
