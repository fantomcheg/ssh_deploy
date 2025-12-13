-- === Универсальный AIEdit (Grok Code Fast 1) ===
local map, o = vim.keymap.set, { noremap = true, silent = true }

-- Visual: правим только выделение
local function ai_edit_selection()
  local prompt = vim.fn.input("AI (выделение): ")
  if prompt == "" then
    return
  end
  vim.cmd("'<,'>AIEdit " .. prompt)
end

-- Normal: правим весь файл
local function ai_edit_buffer()
  local prompt = vim.fn.input("AI (файл целиком): ")
  if prompt == "" then
    return
  end
  vim.cmd("%AIEdit " .. prompt)
end

-- ОДИН хоткей для обоих случаев:
map("v", "<leader>aa", ai_edit_selection,
  vim.tbl_extend("force", o, { desc = "AIEdit selection (Grok)" })
)
map("n", "<leader>aa", ai_edit_buffer,
  vim.tbl_extend("force", o, { desc = "AIEdit buffer (Grok)" })
)

-- Дубли под русскую раскладку, если хочешь
map("v", "<leader>фф", ai_edit_selection, o)
map("n", "<leader>фф", ai_edit_buffer, o)
