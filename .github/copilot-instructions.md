# Project Guidelines

## Code Style
- Language is Lua targeting Neovim 0.10+ APIs.
- Prefer module-local helpers and a local `M` table export (`lua/kaihou/core.lua`, `lua/kaihou/ui.lua`, `lua/kaihou/init.lua`).
- Keep control flow explicit with early returns for platform/error checks.
- Use Neovim APIs directly (`vim.system`, `vim.notify`, `vim.ui.select`, `vim.api.nvim_create_user_command`) and avoid external dependencies.
- Keep comments minimal and practical; avoid excessive abstraction for small modules.

## Architecture
- `plugin/kaihou.lua`: entrypoint, idempotent load guard, command/autocmd registration trigger.
- `lua/kaihou/init.lua`: public API (`setup`, `check`, `toggle`, `list`) and config wiring.
- `lua/kaihou/core.lua`: domain logic for Windows/PowerShell/admin checks, root detection, Defender operations.
- `lua/kaihou/ui.lua`: user-facing messaging and selection UI only.
- Maintain this separation: core should not depend on UI concerns.

## Build and Test
- No build step and no test suite are currently defined.
- Basic syntax check command:
  - `nvim --headless -u NONE "+set rtp+=." "+lua require('kaihou')" +q`
- Optional local smoke check in Neovim after loading plugin:
  - `:DefenderCheck`
  - `:DefenderList`
  - `:DefenderToggle` (requires admin rights on Windows)

## Project Conventions
- Windows-only behavior is intentional; non-Windows paths must fail safely with warnings.
- All external operations must remain non-blocking via `vim.system(..., callback)`.
- Root detection pattern set is fixed unless requirements change: `.git`, `package.json`, `Cargo.toml`, `pyproject.toml`.
- Use command names and UX already documented in `README.md`.
- Keep Lazy.nvim compatibility (`require("kaihou").setup({...})`) as a first-class path.

## Integration Points
- PowerShell cmdlets used by core logic:
  - `Get-MpPreference`
  - `Add-MpPreference`
  - `Remove-MpPreference`
- Neovim integration points:
  - User commands: `DefenderCheck`, `DefenderToggle`, `DefenderList`
  - `VimEnter` autocmd gated by `auto_check`

## Security
- Never attempt Defender modification without administrator privilege check.
- Escape PowerShell string inputs before command construction (single-quote escaping pattern in `core.lua`).
- Treat Defender command stderr/stdout as user-visible diagnostics through safe notifications.
