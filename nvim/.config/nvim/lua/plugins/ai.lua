-- ~/.config/nvim/lua/plugins/ai.lua
return {
  "madox2/vim-ai",
  event = "VeryLazy",
  init = function()
    -- (опционально) вырубить дефолтные маппинги плагина
    vim.g.vim_ai_disable_mappings = 1
  end,
}
