local M = {}

local DEFAULT_ROOT_PATTERNS = {
  ".git",
  "package.json",
  "Cargo.toml",
  "pyproject.toml",
}

local config = {
  auto_check = true,
}

local function is_windows()
  return vim.uv.os_uname().sysname == "Windows_NT"
end

local function ps_base_command(script)
  return {
    "powershell",
    "-NoProfile",
    "-NonInteractive",
    "-ExecutionPolicy",
    "Bypass",
    "-Command",
    script,
  }
end

local function run_powershell(script, callback)
  vim.system(ps_base_command(script), { text = true }, function(result)
    vim.schedule(function()
      callback(result)
    end)
  end)
end

local function escape_ps_single_quote(value)
  return value:gsub("'", "''")
end

local function normalize_path(path)
  local normalized = vim.fs.normalize(path)
  normalized = normalized:gsub("[/\\]+$", "")
  return normalized:lower()
end

local function detect_root()
  local source = vim.api.nvim_buf_get_name(0)
  if source == "" then
    source = vim.uv.cwd() or vim.fn.getcwd()
  end

  return vim.fs.root(source, DEFAULT_ROOT_PATTERNS) or vim.uv.cwd() or vim.fn.getcwd()
end

function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
end

function M.is_windows()
  return is_windows()
end

function M.is_admin(callback)
  if not is_windows() then
    callback(false, "Windows only")
    return
  end

  local script = table.concat({
    "$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())",
    "if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { 'true' } else { 'false' }",
  }, "; ")

  run_powershell(script, function(result)
    if result.code ~= 0 then
      local stderr = (result.stderr or ""):gsub("%s+$", "")
      callback(false, stderr ~= "" and stderr or "Failed to detect administrator privilege")
      return
    end

    local stdout = (result.stdout or ""):gsub("%s+$", "")
    callback(stdout == "true", nil)
  end)
end

function M.list_exclusions(callback)
  if not is_windows() then
    callback(false, nil, "Windows only")
    return
  end

  local script = "Get-MpPreference | Select-Object -ExpandProperty ExclusionPath"
  run_powershell(script, function(result)
    if result.code ~= 0 then
      local stderr = (result.stderr or ""):gsub("%s+$", "")
      callback(false, nil, stderr ~= "" and stderr or "Failed to list Defender exclusions")
      return
    end

    local list = {}
    for line in (result.stdout or ""):gmatch("[^\r\n]+") do
      local path = vim.trim(line)
      if path ~= "" then
        table.insert(list, path)
      end
    end

    callback(true, list, nil)
  end)
end

function M.get_project_root()
  return detect_root()
end

function M.check_current_project(callback)
  if not is_windows() then
    callback(false, { root = detect_root(), excluded = false, list = {} }, "Windows only")
    return
  end

  local root = detect_root()
  local root_key = normalize_path(root)

  M.list_exclusions(function(ok, list, err)
    if not ok then
      callback(false, { root = root, excluded = false, list = {} }, err)
      return
    end

    local excluded = false
    for _, path in ipairs(list) do
      if normalize_path(path) == root_key then
        excluded = true
        break
      end
    end

    callback(true, { root = root, excluded = excluded, list = list }, nil)
  end)
end

function M.add_exclusion(path, callback)
  local escaped_path = escape_ps_single_quote(path)
  local script = string.format("Add-MpPreference -ExclusionPath '%s'", escaped_path)

  run_powershell(script, function(result)
    if result.code ~= 0 then
      local stderr = (result.stderr or ""):gsub("%s+$", "")
      callback(false, stderr ~= "" and stderr or "Failed to add Defender exclusion")
      return
    end

    callback(true, nil)
  end)
end

function M.remove_exclusion(path, callback)
  local escaped_path = escape_ps_single_quote(path)
  local script = string.format("Remove-MpPreference -ExclusionPath '%s'", escaped_path)

  run_powershell(script, function(result)
    if result.code ~= 0 then
      local stderr = (result.stderr or ""):gsub("%s+$", "")
      callback(false, stderr ~= "" and stderr or "Failed to remove Defender exclusion")
      return
    end

    callback(true, nil)
  end)
end

function M.toggle_current_project(callback)
  if not is_windows() then
    callback(false, { action = "none", root = detect_root() }, "Windows only")
    return
  end

  M.is_admin(function(admin, admin_err)
    if not admin then
      callback(
        false,
        { action = "none", root = detect_root(), skipped = true },
        admin_err or "Administrator privilege is required"
      )
      return
    end

    M.check_current_project(function(ok, state, err)
      if not ok then
        callback(false, { action = "none", root = state.root }, err)
        return
      end

      local apply = state.excluded and M.remove_exclusion or M.add_exclusion
      local action = state.excluded and "removed" or "added"

      apply(state.root, function(mod_ok, mod_err)
        if not mod_ok then
          callback(false, { action = action, root = state.root }, mod_err)
          return
        end

        callback(true, { action = action, root = state.root }, nil)
      end)
    end)
  end)
end

function M.get_config()
  return config
end

return M
