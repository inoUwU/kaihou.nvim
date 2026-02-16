local core = require("kaihou.core")

local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "kaihou.nvim" })
end

function M.check_current_project()
  if not core.is_windows() then
    notify("kaihou.nvim works only on Windows", vim.log.levels.WARN)
    return
  end

  core.check_current_project(function(ok, state, err)
    if not ok then
      notify(err or "Failed to check Windows Defender exclusion", vim.log.levels.ERROR)
      return
    end

    if state.excluded then
      notify("Excluded: " .. state.root)
    else
      notify("Not excluded: " .. state.root, vim.log.levels.WARN)
    end
  end)
end

function M.toggle_current_project()
  if not core.is_windows() then
    notify("kaihou.nvim works only on Windows", vim.log.levels.WARN)
    return
  end

  core.toggle_current_project(function(ok, result, err)
    if not ok then
      if result and result.skipped then
        notify("Administrator privilege is required. Skipped Defender modification.", vim.log.levels.WARN)
        return
      end

      notify(err or "Failed to toggle Windows Defender exclusion", vim.log.levels.ERROR)
      return
    end

    if result.action == "added" then
      notify("Added exclusion: " .. result.root)
    elseif result.action == "removed" then
      notify("Removed exclusion: " .. result.root)
    else
      notify("No change: " .. result.root, vim.log.levels.WARN)
    end
  end)
end

function M.list_exclusions()
  if not core.is_windows() then
    notify("kaihou.nvim works only on Windows", vim.log.levels.WARN)
    return
  end

  core.list_exclusions(function(ok, list, err)
    if not ok then
      notify(err or "Failed to list Windows Defender exclusions", vim.log.levels.ERROR)
      return
    end

    if #list == 0 then
      notify("No Defender exclusion paths configured.")
      return
    end

    vim.ui.select(list, {
      prompt = "Windows Defender exclusion paths",
      format_item = function(item)
        return item
      end,
    }, function(choice)
      if choice then
        notify("Selected: " .. choice)
      end
    end)
  end)
end

return M
