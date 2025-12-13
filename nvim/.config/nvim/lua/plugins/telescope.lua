return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')
    local fb_actions = require('telescope').extensions.file_browser.actions

    telescope.setup({
      defaults = {
        layout_strategy  = 'vertical',
        layout_config    = { prompt_position = 'top' },
        sorting_strategy = 'ascending',
        path_display     = { 'truncate' },
        mappings = {
          i = { ['<esc>'] = actions.close },
          n = { ['q']     = actions.close },
        },
        file_ignore_patterns = {},
      },

      pickers = {
        oldfiles = { initial_mode = 'insert' },
        find_files = {
          hidden    = true,
          no_ignore = true,
          follow    = true,
        },
      },

      extensions = {
        file_browser = {
          grouped           = true,
          hidden            = true,
          respect_gitignore = false,
          hijack_netrw      = true,
          initial_mode      = 'normal',
          mappings = {
            i = {
              ['-'] = fb_actions.goto_parent_dir,
            },
            n = {
              ['-'] = fb_actions.goto_parent_dir,
            },
          },
        },
      },
    })

    pcall(function() telescope.load_extension('file_browser') end)

    -- Ctrl+R — недавние файлы
    vim.keymap.set('n', '<C-r>', function()
      require('telescope.builtin').oldfiles({
        cwd_only     = false,
        prompt_title = 'Recent files',
      })
    end, { desc = 'Recent files (Telescope)' })

    -- Ctrl+F — поиск файлов (показывать всё)
    vim.keymap.set({ 'n', 'i', 'v' }, '<C-f>', function()
      require('telescope.builtin').find_files({
        hidden    = true,
        no_ignore = true,
        follow    = true,
      })
    end, { desc = 'Find files (ALL)' })

    -- Ctrl+E — file browser в текущей папке
    vim.keymap.set({ 'n', 'i', 'v' }, '<C-e>', function()
      telescope.extensions.file_browser.file_browser({
        path = vim.loop.cwd(),
        cwd  = vim.loop.cwd(),
        grouped = true,
        hidden  = true,
        respect_gitignore = false,
        initial_mode = 'normal',
      })
    end, { desc = 'File Browser (ALL)' })

    -- <leader>pe — открыть папку с конфигами плагинов
    vim.keymap.set('n', '<leader>pe', function()
      local p = vim.fn.stdpath('config') .. '/lua/plugins'
      telescope.extensions.file_browser.file_browser({
        path = p,
        cwd  = p,
        grouped = true,
        hidden  = true,
        respect_gitignore = false,
        initial_mode = 'normal',
      })
    end, { desc = 'File Browser: ~/.config/nvim/lua/plugins' })
  end,
}
