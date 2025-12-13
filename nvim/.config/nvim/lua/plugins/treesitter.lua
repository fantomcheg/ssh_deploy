return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('nvim-treesitter.configs').setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      ensure_installed = {
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
        'tsx',          -- React (JSX/TSX)
        
        -- backend/devops
        'dockerfile',
      },
    })
  end,
}
