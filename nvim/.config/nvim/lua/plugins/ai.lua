-- ~/.config/nvim/lua/plugins/ai.lua
return {
  "madox2/vim-ai",
  event = "VeryLazy",
  cond = function()
    return vim.fn.has("python3") == 1
  end,
  init = function()
    -- (опционально) вырубить дефолтные маппинги плагина
    vim.g.vim_ai_disable_mappings = 1
  end,
}
