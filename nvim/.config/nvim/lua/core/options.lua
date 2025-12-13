-- Автостарт Telescope при чистом запуске Neovim
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    -- Если запуск через vman → пропускаем
    if os.getenv("NVIM_MAN") == "1" then
      return
    end

    -- Если буфер уже содержит текст (stdin/pipe) → пропускаем
    if vim.fn.line2byte("$") ~= -1 then
      return
    end

    -- Если были переданы файлы → пропускаем
    if vim.fn.argc() > 0 then
      return
    end

    -- "Чистый" старт → запускаем Telescope
    vim.schedule(function()
      require('telescope.builtin').oldfiles({
        cwd_only = false,
        prompt_title = 'Recent files',
        attach_mappings = function(_, map)
          -- Новый файл
          map('i', '<C-n>', function()
            vim.cmd('enew!')
            return true
          end)
          map('n', '<C-n>', function()
            vim.cmd('enew!')
            return true
          end)

          -- Выйти из Neovim
          map('i', '<C-q>', function()
            vim.cmd('qa!')
            return true
          end)
          map('n', '<C-q>', function()
            vim.cmd('qa!')
            return true
          end)

          return true
        end,
      })
    end)
  end,
})

-- ESLINT

-- Показывать диагностики в строке
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    prefix = "●",        -- точка перед сообщением
    source = "if_many",  -- показывать источник (eslint и т.п.), если их несколько
  },
  signs = true,
  underline = true,
  update_in_insert = false, -- не отвлекать во время набора
  severity_sort = true,
})

-- Чтобы CursorHold срабатывал быстрее
vim.o.updatetime = 300  -- мс

-- Всплывающее окно при наведении курсора
local float_opts = {
  focusable = false,
  close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
  border = "rounded",
  source = "always",   -- всегда показывать источник (eslint)
  prefix = "",
  scope = "cursor",
}

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  callback = function()
    vim.diagnostic.open_float(nil, float_opts)
  end,
})
