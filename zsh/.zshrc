#####
# Документация для .zshrc

## Инициализация Powerlevel10k
# Включает мгновенный промпт Powerlevel10k для ускорения загрузки оболочки.
# Код, требующий ввода (например, пароли или подтверждения), должен быть размещен выше этого блока.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

## Настройка Zinit
# Устанавливает каталог для хранения Zinit и его плагинов.
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Загружает Zinit из репозитория GitHub, если он ещё не установлен.
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Подключает скрипт инициализации Zinit.
source "${ZINIT_HOME}/zinit.zsh"


## Плагины Zsh
# Powerlevel10k: современная тема для промпта командной строки.
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Плагины для улучшения функциональности Zsh:
# Подсветка синтаксиса команд в реальном времени.
zinit light zsh-users/zsh-syntax-highlighting
# Расширенное автодополнение команд.
zinit light zsh-users/zsh-completions
# Автопредложения на основе истории команд.
zinit light zsh-users/zsh-autosuggestions
# Интеграция с FZF для улучшения вкладок автодополнения.
zinit light Aloxaf/fzf-tab

## Snippets (фрагменты кода)
# Добавляет полезные функции и алиасы:
# sudo: позволяет повторять команду с префиксом sudo.
zinit snippet OMZP::sudo
# command-not-found: предлагает установку пакетов при отсутствии команды.
zinit snippet OMZP::command-not-found
# history: улучшает работу с историей команд.
zinit snippet OMZP::history

## Настройка завершения команд
# Загружает и инициализирует систему автодополнения Zsh.
autoload -Uz compinit && compinit
# Применяет все изменения Zinit без вывода сообщений.
zinit cdreplay -q

## Настройка Powerlevel10k
# Загружает конфигурацию Powerlevel10k, если файл существует.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


## Настройки истории
# Размер истории команд в памяти.
HISTSIZE=100000
# Файл для хранения истории команд.
HISTFILE=~/.zsh_history
# Количество команд для сохранения в файле.
SAVEHIST=$HISTSIZE
# Максимальный размер файла истории.
HISTFILESIZE=100000
# Режим обработки дубликатов: стирать старые дубликаты.
HISTDUP=erase
# Опции для управления историей: добавлять к файлу, делить между сессиями, игнорировать команды с пробелом, удалять дубликаты и т.д.
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt inc_append_history
setopt share_history
alias h='fc -l -50'


## Стили завершения
# Делает автодополнение нечувствительным к регистру.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# Использует цвета из переменной LS_COLORS для автодополнения.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Отключает меню автодополнения.
zstyle ':completion:*' menu no
# Настройки предпросмотра для fzf-tab: показывает содержимое каталогов и файлов.
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

## Функции
# Функция для перехода в каталог с помощью FZF с предпросмотром дерева файлов.
_fzf_cd() {
  local dir
  dir=$(fzf --preview 'tree -C {} | head -200') &&
    cd "$dir"
}

# Jump to directory with fzf: cdf plugins
cdf() {
  local q="${1:-}"
  local dir

  if command -v fd >/dev/null 2>&1; then
    # fd быстрее find
    if [[ -n "$q" ]]; then
      dir="$(fd -t d --hidden --follow "$q" ~ 2>/dev/null | fzf --query="$q")"
    else
      dir="$(fd -t d --hidden --follow . ~ 2>/dev/null | fzf)"
    fi
  else
    # fallback на find
    if [[ -n "$q" ]]; then
      dir="$(find ~ -type d -name "*$q*" 2>/dev/null | fzf --query="$q")"
    else
      dir="$(find ~ -type d 2>/dev/null | fzf)"
    fi
  fi

  [[ -n "$dir" ]] && cd "$dir"
}

# Интегрирует функцию в автодополнение для команды cd.
zstyle ':completion:*:*:cd:argument-completer' _expand _complete _fzf_cd

## Переменные окружения
# Добавляет путь к npm в переменную PATH.
export PATH="$PATH:/usr/local/share/npm/bin"
# Настройки по умолчанию для FZF: обратный layout, границы, встроенная информация, символы и предпросмотр.
export FZF_DEFAULT_OPTS="
  --layout=reverse
  --border
  --info=inline
  --prompt='> '
  --pointer='>'
  --marker='*'
  --preview '
    if [ -d \"{}\" ]; then
      eza -T -- \"{}\" | head -20
    else
      bat --style=numbers --color=always -- \"{}\" 2>/dev/null | head -200
    fi
  '
"

## Инициализация истории
# Создаёт файл истории, если он пустой.
if [[ ! -s ~/.zsh_history ]]; then
  >| ~/.zsh_history
fi

## Интеграции с оболочкой
# Инициализирует интеграцию FZF с Zsh.
eval "$(fzf --zsh)"
# Инициализирует zoxide для умного перехода по каталогам (замена cd).
eval "$(zoxide init --cmd cd zsh)"
# Переменные для Go: путь к GOPATH и добавление в PATH.
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:$GOPATH/bin/pdtm

## Псевдонимы FZF
# Переход в каталог с помощью FZF, пропуская определённые каталоги.
# Команда по умолчанию для FZF: поиск файлов в домашнем каталоге.
export FZF_DEFAULT_COMMAND="find ~+ -type f"

## Пути для pdtm
# Добавляет путь к pdtm в PATH.
export PATH=$PATH:/home/xrapid/.pdtm/go/bin

## Псевдонимы Tmux
# Убивает сервер Tmux.
alias tmuxk='tmux kill-server'
# Короткий алиас для убийства сервера Tmux.
alias k='tmux kill-server'
# Убивает все окна кроме текущего.
alias cc='tmux kill-window -a -t !'

## Системные псевдонимы
# Показывает историю команд.
# Замена cat на bat с цветами.
#alias cat='bat --color=always'
# Алиасы для eza (улучшенный ls).
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons'
    alias la='eza -la --icons'
    alias ll='eza -ll --icons'
    alias lt='eza -T --icons'
elif command -v exa >/dev/null 2>&1; then
    alias ls='exa'
    alias la='exa -la'
    alias ll='exa -ll'
fi
# Очистка экрана.
alias c='clear'
# Перетаскивание файлов с помощью dragon-drop.
alias d='dragon-drop'
# Быстрый переход на уровень выше.
alias ../='cd ../'
# Включает сопоставление с файлами, начинающимися с точки.
setopt globdots
# Редактирование конфигурации загрузчика EFI.
alias loader='sudo -E nvim /efi/loader/loader.conf'

## Псевдонимы Pacman/Yay
# Удаление пакетов через Pacman.
alias r='sudo pacman -R'
# Установка пакетов через Yay.
alias y='yay -S'
# Перезагрузка конфигурации .zshrc.
alias so='source ~/.zshrc'
# Перезагрузка конфигурации Tmux.
alias sot='tmux source ~/.config/tmux/tmux.conf'
# Обновление системы через Pacman.
alias s='sudo pacman -Syu'
# Поиск пакетов с помощью pamac_search_bat.
alias pms='pamac_search_bat'
# Запуск скрипта обновления системы.
alias u="${HOME}/scripts/update_system.sh"
alias update="${HOME}/scripts/update_system.sh"

## Псевдонимы Neovim
# Редактирование файлов с правами sudo.
alias nvims='sudoedit'
# Замена vim на nvim.
alias vim='nvim'
# Открытие старых файлов через Telescope.
alias nvimr='nvim +"Telescope\ oldfiles"'
# Замена nano на nvim.
alias nano='nvim'
# Редактирование .zshrc.
alias nvimz='nvim ~/.zshrc'
alias nvimai='nvim ~/.zsh_ai_aliases'

# Редактирование конфигурации Neovim.
alias nvimn='nvim ~/.config/nvim/init.lua'
# Редактирование конфигурации Tmux.
alias nvimt='nvim ~/.config/tmux/tmux.conf'
# Редактирование конфигурации Alacritty.
alias nvima='nvim ~/.config/alacritty/alacritty.toml'
# Открытие файла через FZF.
alias nvimf='nvim $(fzf --walker-skip=.steam,.local --walker=file,hidden, --walker-root=/home/xrapid)'
# Установка Neovim как редактора по умолчанию.
export EDITOR="nvim"
export VISUAL="nvim"

## Псевдонимы для перезагрузки конфигураций
# Перезагрузка конфигурации Tmux.
alias sourcet='tmux source ~/.config/tmux/tmux.conf'
# Перезагрузка конфигурации .zshrc.
alias sourcez='source ~/.zshrc'

## Псевдонимы для загрузки с YouTube
# Загрузка видео в указанный каталог.
alias yt='yt-dlp -P /mnt/Video/'
# Загрузка аудио в формате MP3.
alias yt3='yt-dlp -P /mnt/Yandex.Disk/Music/ -t mp3'
# Загрузка через vot-cli.
alias vot='vot-cli --output="."'

## Псевдонимы для перевода
# Перевод текста на русский.
alias t='trans -b :ru'
# Интерактивный перевод с английского на русский.
alias ts='trans -shell en:ru'
# Интерактивный перевод с русского на английский.
alias tsr='trans -shell ru:en'
# Перевод текста на английский.
alias tr='trans -b :en'

## Настройки NNN
# Запуск файлового менеджера NNN.
alias n='nnn'
alias cdn='nnn'
# Плагины для NNN: autojump, fzcd, fzopen, preview-tui, dragdrop.
export NNN_PLUG='j:autojump;p:preview-tui;d:dragdrop'
# Именованный канал для NNN.
export NNN_FIFO=/tmp/nnn.fifo
# Пейджер для NNN.
export NNN_PAGER='more -lfp'
# Скрипт для выхода в текущий каталог.
[ -f "$HOME/.local/zsh/quitcd.bash_sh_zsh" ] && source "$HOME/.local/zsh/quitcd.bash_sh_zsh"
# Цветовая схема для NNN.
export NNN_FCOLORS="D4DEB778E79F9F67D2E5E5D2"
# Включение корзины.
export NNN_TRASH=1
# Закладки для быстрого доступа.
export NNN_BMS='h:/home/xrapid/;y:/mnt/Yandex.Disk/;c:~/.config/;p:~/Projects;d:~/dotfiles/'

# --- Midnight Commander: выход в текущую директорию ---
mc() {
    local mc_pwd_file="${TMPDIR:-/tmp}/mc-pwd.$$"
    command mc -P "$mc_pwd_file" "$@"
    if [ -r "$mc_pwd_file" ]; then
        local mc_pwd="$(cat "$mc_pwd_file")"
        if [ -n "$mc_pwd" ] && [ -d "$mc_pwd" ] && [ "$mc_pwd" != "$PWD" ]; then
            cd "$mc_pwd"
        fi
        rm -f "$mc_pwd_file"
    fi
}

# Включение Wayland для Firefox.
export MOZ_ENABLE_WAYLAND=1

# Функция для обновления каталога в NNN при выходе.
nnn_cd()                                                                                                   
{
    if ! [ -z "$NNN_PIPE" ]; then
        printf "%s\0" "0c${PWD}" > "${NNN_PIPE}" !&
    fi  
}
# Вызов функции при выходе из оболочки.
trap nnn_cd EXIT

## Настройки Pyenv (только если установлен)
if [ -d "$HOME/.pyenv" ]; then
    # Каталог установки Pyenv.
    export PYENV_ROOT="$HOME/.pyenv"
    # Добавление Pyenv в PATH, если команда доступна.
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    # Инициализация Pyenv.
    eval "$(pyenv init -)"
fi

## Настройки Wayland
# Настройка QT для использования Wayland.
export QT_QPA_PLATFORM=wayland
# Включение Wayland для Firefox.
export MOZ_ENABLE_WAYLAND=1
# Настройка OZONE для приложений на Electron.
export OZONE_PLATFORM=wayland

## Генерация паролей
# Генерация сложного пароля длиной 30 символов.
alias password='pwgen -cnys 30 1'

## Музыка
# Запуск музыкального плеера ncmpcpp.
alias music='ncmpcpp'
# Включение случайного воспроизведения и запуск плеера.
alias random='mpc shuffle && mpc play && ncmpcpp'
# Переключение воспроизведения музыки.
alias m='mpc toggle'

## Пользовательские скрипты
# Перезагрузка демонов systemd.
alias reload='sudo systemctl daemon-reload'
# Показ календаря на год.
alias cal='cal -y'
# Копирование в буфер обмена Wayland.
alias copy='wl-copy'
# Вставка из буфера обмена Wayland.
alias paste='wl-paste'
# Просмотр открытых сокетов.
alias ss='sudo ss -tulpn'
# Получение информации о публичном IP.
alias myip='curl -s ipinfo.io | jq -r ".ip as \$ip | .country as \$c | .city as \$city | .org as \$org | \"IP: \(\$ip)\nСтрана: \(\$c)\nГород: \(\$city)\nПровайдер: \(\$org)\""'
# Замена df на duf для красивого вывода.
alias df='duf'
# Анализ использования диска с ncdu.
alias disk='ncdu'
# Просмотр ошибок в журнале systemd.
alias errors='journalctl -b -p err'
# Мониторинг сетевого трафика.
alias net='sudo bandwhich -s'
# Переключение DNS.
alias dns='sudo ~/scripts/toggle-dns.sh'
# Поиск файлов с fd.
alias fd='fd -HIgp'
# Загрузка темы для SSH в Alacritty (только если файл существует).
[ -f ~/.config/alacritty/ssh-theme.sh ] && source ~/.config/alacritty/ssh-theme.sh



## Справка и вики
# Настройка пейджера для man (если manpager установлен).
command -v manpager >/dev/null 2>&1 && eval "$(manpager)"
# Функция для просмотра man-страниц в Neovim.
vman() {
  man "$@" | nvim -R -c 'set ft=man' -
}
# Краткая справка через tldr.
alias tman='tldr'
# Справка через cht.sh.
alias cman='cht.sh'
# Поиск в вики Arch Linux.
alias wiki='wikiman -s arch'

## Скринсейверы
# Запуск анимации бонсай.
alias bonsai='gobonsai -Slit 99ms'
# Запуск анимации дождя.
alias rain='rainfall'
# Запуск анимации pipes.
alias p='~/scripts/pipes.sh'
# Запуск матрицы.
alias cm='cmatrix'

## Тестирование
# Запуск тестового скрипта.
alias test='~/scripts/test.sh'


## Broot
# Подключение лаунчера Broot (только если установлен).
[ -f ~/.config/broot/launcher/bash/br ] && source ~/.config/broot/launcher/bash/br
# Алиасы для запуска Broot.
alias b='br'
alias bh='br --hidden'
alias bs='br -S --sort-by-size --hidden'    
alias bm='br -S --sort-by-date -HPD'    

# Функция для интеграции Broot с оболочкой (автогенерируется).
function br {
    local cmd cmd_file code
    cmd_file=$(mktemp)
    if broot --outcmd "$cmd_file" "$@"; then
        cmd=$(<"$cmd_file")
        command rm -f "$cmd_file"
        eval "$cmd"
    else
        code=$?
        command rm -f "$cmd_file"
        return "$code"
    fi
}

## Кодирование URL
# Функция для кодирования строки в URL.
#####
# Функция urlencode принимает строку и кодирует её для использования в URL
urlencode() {
 # Печатает первый аргумент как строку и передаёт в jq для URI-кодирования
 printf "%s" "$1" |  jq -sRr @uri
}

# ZAP (только если установлен)
[ -f /usr/share/zaproxy/zap.sh ] && alias zap='/usr/share/zaproxy/zap.sh -cmd'

# NVM (только если установлен)
if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "/usr/share/nvm/init-nvm.sh" ] && source /usr/share/nvm/init-nvm.sh
fi


# Load AI aliases
[ -f ~/.zsh_ai_aliases ] && source ~/.zsh_ai_aliases
[ -f ~/.zsh_mount_aliases ] && source ~/.zsh_mount_aliases
[ -f ~/.zsh_taskwarrior ] && source ~/.zsh_taskwarrior
[ -f ~/.zsh_work_aliases ] && source ~/.zsh_work_aliases
