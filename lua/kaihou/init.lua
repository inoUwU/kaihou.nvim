local core = require("kaihou.core")
local ui = require("kaihou.ui")

local M = {}

local config = {}

local commands_created = false

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
