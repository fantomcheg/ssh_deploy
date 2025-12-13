return {
  'hrsh7th/nvim-cmp',
  event = { 'InsertEnter', 'CmdlineEnter' },
  dependencies = {
    'hrsh7th/cmp-path',        -- автодополнение путей
    'hrsh7th/cmp-buffer',      -- автодополнение из буфера
    'hrsh7th/cmp-cmdline',     -- автодополнение в командной строке
  },
  config = function()
    local cmp = require('cmp')

    cmp.setup({
      mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),  -- Ctrl+D - скролл документации вверх
        ['<C-u>'] = cmp.mapping.scroll_docs(4),   -- Ctrl+U - скролл документации вниз
        ['<C-Space>'] = cmp.mapping.complete(),   -- Ctrl+Space - показать меню
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { 'i', 's' }),
      }),

      sources = cmp.config.sources({
        { name = 'path', priority = 1000 },    -- путь — высший приоритет
        { name = 'buffer', priority = 500 },   -- текст из буфера
      }),

      -- Настройка окна автодополнения
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      -- Форматирование записей
      formatting = {
        format = function(entry, vim_item)
          -- Иконки для источников
          vim_item.menu = ({
            path = '[Path]',
            buffer = '[Buf]',
          })[entry.source.name]
          return vim_item
        end,
      },
    })

    -- Автодополнение в командной строке (для :e, :cd и т.д.)
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' },
        { name = 'cmdline' },
      }),
    })

    -- Автодополнение для поиска
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' },
      },
    })
  end,
}
