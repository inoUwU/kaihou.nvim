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

  vim.api.nvim_create_user_command("DefenderCheck", function()
    ui.check_current_project()
  end, { desc = "Check Defender exclusion for current project" })

  vim.api.nvim_create_user_command("DefenderToggle", function()
    ui.toggle_current_project()
  end, { desc = "Toggle Defender exclusion for current project" })

  vim.api.nvim_create_user_command("DefenderList", function()
    ui.list_exclusions()
  end, { desc = "List Defender exclusion paths" })

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
