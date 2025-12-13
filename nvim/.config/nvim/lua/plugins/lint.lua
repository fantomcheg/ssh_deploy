return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Какие линтеры для каких файлов
    lint.linters_by_ft = {
      javascript = { "eslint" },
      typescript = { "eslint" },
      javascriptreact = { "eslint" },
      typescriptreact = { "eslint" },
    }

    -- Переопределяем eslint: указываем глобальный конфиг
    local eslint = lint.linters.eslint
    eslint.args = {
      "--config", vim.fn.expand("~/.config/eslint/eslint.config.cjs"),
      "--format", "json",
      "--stdin",
      "--stdin-filename", function()
        return vim.api.nvim_buf_get_name(0)
      end,
    }

    -- Автоматически запускать линтер при сохранении файла
    vim.api.nvim_create_autocmd("BufWritePost", {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}
