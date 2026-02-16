if vim.g.loaded_kaihou_nvim == 1 then
  return
end
vim.g.loaded_kaihou_nvim = 1

local ok, kaihou = pcall(require, "kaihou")
if not ok then
  return
end

kaihou._create_commands()
kaihou._create_autocmd()
