#!/bin/bash
# Возврат к обычному горизонтальному формату

CONFIG_DIR="$HOME/dotfiles/alacritty/.config/alacritty"
LINK="$HOME/.config/alacritty/alacritty.toml"

# Переключаем на обычный
ln -sf "$CONFIG_DIR/alacritty.toml" "$LINK"
echo "✅ Переключено на обычный формат (220x40)"
echo "Alacritty автоматически перезагрузит конфиг"
