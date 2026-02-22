local core = require("kaihou.core")
local ui = require("kaihou.ui")

local M = {}

local config = {
  auto_check = true,
}

local commands_created = false
local autocmd_created = false

local function apply_config()
  core.setup(config)
end

function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
  apply_config()
end

function M._create_commands()
  if commands_created then
    return
  end

  local cmds = {
    { "Check", ui.check_current_project, "Check Defender exclusion for current project" },
    { "Toggle", ui.toggle_current_project, "Toggle Defender exclusion for current project" },
    { "List", ui.list_exclusions, "List Defender exclusion paths" },
  }

  for _, cmd in ipairs(cmds) do
    local suffix, fn, desc = cmd[1], cmd[2], cmd[3]
    vim.api.nvim_create_user_command("Defender" .. suffix, fn, { desc = desc })
    vim.api.nvim_create_user_command("Kaihou" .. suffix, fn, { desc = desc })
  end

  commands_created = true
end

function M._create_autocmd()
  if autocmd_created then
    return
  end

  local group = vim.api.nvim_create_augroup("kaihou_nvim", { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
      if config.auto_check then
        ui.check_current_project()
      end
    end,
    desc = "Auto-check Defender exclusion state",
  })

  autocmd_created = true
end

function M.check()
  ui.check_current_project()
end

function M.toggle()
  ui.toggle_current_project()
end

function M.list()
  ui.list_exclusions()
end

apply_config()

return M
