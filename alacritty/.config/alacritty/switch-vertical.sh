#!/bin/bash
# Переключение на вертикальный формат для сториз

CONFIG_DIR="$HOME/dotfiles/alacritty/.config/alacritty"
LINK="$HOME/.config/alacritty/alacritty.toml"

# Создаем резервную копию текущей ссылки
if [ -L "$LINK" ]; then
    CURRENT=$(readlink "$LINK")
    echo "Текущий конфиг: $CURRENT"
fi

# Переключаем на вертикальный
ln -sf "$CONFIG_DIR/alacritty_vertical.toml" "$LINK"
echo "✅ Переключено на вертикальный формат (45x30 для сториз)"
echo "Alacritty автоматически перезагрузит конфиг"
