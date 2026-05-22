return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  lazy = false,
  config = function()
    local treesitter = require('nvim-treesitter')

    treesitter.setup({
      install_dir = vim.fn.stdpath('data') .. '/lazy/nvim-treesitter',
    })

    local languages = {
      -- базовые
      'lua',
      'vim',
      'vimdoc',
      'json',
      'yaml',
      'markdown',
      'markdown_inline',

      -- shell
      'bash',

      -- JS/TS stack
      'javascript',
      'typescript',
      'tsx', -- React (JSX/TSX)

      -- backend/devops
      'dockerfile',
    }

    treesitter.install(languages)

    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        if pcall(vim.treesitter.start) then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
