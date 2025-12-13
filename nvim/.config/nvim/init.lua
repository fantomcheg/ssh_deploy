require("config.lazy")
require 'core.keymaps'
require 'core.config'
require 'core.options'
require 'core.ai'
vim.g.vim_ai_roles_config_file = vim.fn.expand("~/.config/vim-ai/roles.ini")
-- Русская раскладка -> латинская (JCUKEN → QWERTY), обе регистры
-- положи это ПОСЛЕ vim.g.mapleader, но ДО объявлений keymap'ов
vim.opt.langmap = table.concat({
  -- нижний регистр
  "йq,цw,уe,кr,еt,нy,гu,шi,щo,зp,",
  "фa,ыs,вd,аf,пg,рh,оj,лk,дl,",
  "яz,чx,сc,мv,иb,тn,ьm,",
  -- верхний регистр
  "ЙQ,ЦW,УE,КR,ЕT,НY,ГU,ШI,ЩO,ЗP,",
  "ФA,ЫS,ВD,АF,ПG,РH,ОJ,ЛK,ДL,",
  "ЯZ,ЧX,СC,МV,ИB,ТN,ЬM",
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.keymap.set('i', '<S-CR>', function() return next_list_cr() end,
      { buffer = true, expr = true, noremap = true })
  end,
})
