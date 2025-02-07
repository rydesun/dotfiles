typeset -U path PATH
path=($path ~/.bin)

### XDG目录
export XDG_CONFIG_HOME=~/.config
export XDG_CACHE_HOME=~/.cache
export XDG_DATA_HOME=~/.data
export XDG_STATE_HOME=~/.state

### Flatpak安装的程序
# 由于修改了 $XDG_DATA_HOME 的位置，
# 并且 /etc/profile.d/flatpak.sh 和 /etc/profile.d/flatpak-bindir.sh
# 两个文件读取 $XDG_DATA_HOME 早于 ~/.zprofile 修改 $XDG_DATA_HOME，
# 所以这两个文件没有成功设置目录在修改后的 $XDG_DATA_HOME。
# 需要手动添加至 $XDG_DATA_DIRS 和 $PATH
FLATPAK_DATA_DIR="$XDG_DATA_HOME"/flatpak/exports/share
FLATPAK_BIN_DIR="$XDG_DATA_HOME"/flatpak/exports/bin
[[ -d "$FLATPAK_DATA_DIR" ]] && \
    XDG_DATA_DIRS="$FLATPAK_DATA_DIR":"$XDG_DATA_DIRS"
[[ -d "$FLATPAK_BIN_DIR" ]] && path=("$FLATPAK_BIN_DIR" $path)

### Flatpak中的Steam安装的程序
STEAM_DESKTOP=~/.var/app/com.valvesoftware.Steam/.local/share/
[[ -d "$STEAM_DESKTOP" ]] && \
    XDG_DATA_DIRS="$STEAM_DESKTOP":"$XDG_DATA_DIRS"
# 修复steam程序名
if [[ -f "$FLATPAK_BIN_DIR"/com.valvesoftware.Steam ]]; then
    [[ ! -f "$FLATPAK_BIN_DIR"/steam ]] && \
        ln -s com.valvesoftware.Steam "$FLATPAK_BIN_DIR"/steam
else
    [[ -f "$FLATPAK_BIN_DIR"/steam ]] && rm "$FLATPAK_BIN_DIR"/steam
fi

### 默认程序
export EDITOR=nvim
export BROWSER=firefox

### Zsh
export HISTFILE="$XDG_DATA_HOME"/zsh/history

### 终端
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export MANPAGER="nvim +Man!"

### GnuPG
export GNUPGHOME="$XDG_DATA_HOME"/gnupg

### Go
export GOPATH="$XDG_DATA_HOME"/go

### Javascript
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc

### Python
export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/repl_startup.py
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME"/python
export PYTHONUSERBASE="$XDG_DATA_HOME"/python
export IPYTHONDIR="$XDG_DATA_HOME"/ipython

### Rust
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup

### SQLite
export SQLITE_HISTORY="$XDG_DATA_HOME"/sqlite_history

# {{{ 图形环境
export XDG_MENU_PREFIX=plasma-

# 鼠标主题
export XCURSOR_PATH="$XDG_DATA_HOME"/icons:/usr/share/icons

### Qt
# 无桌面环境用qt5ct配置Qt主题
export QT_QPA_PLATFORMTHEME=qt5ct

# 禁止Qt自动缩放。用xrdb手动设置DPI
export QT_AUTO_SCREEN_SCALE_FACTOR=0

### GTK
# 配合xdg-desktop-portal-kde使用
export GTK_USE_PORTAL=1

### Fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
# Kitty需要该变量
export GLFW_IM_MODULE=ibus
# }}}

# 同步所有环境变量到所有systemd将要启动的程序
command -v dbus-update-activation-environment &>/dev/null && \
    dbus-update-activation-environment --systemd --all 2>/dev/null

# NOTE: 直接在登录shell中自启桌面环境
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    # 只在桌面环境使用中文
    command -v dbus-update-activation-environment &>/dev/null && \
        dbus-update-activation-environment --systemd LANG=zh_CN.UTF-8 2>/dev/null

    if true; then
        LANG=zh_CN.UTF-8 xinit qtile start
    else
        LANG=zh_CN.UTF-8 qtile start -b wayland
    fi
fi

# vim:foldmethod=marker
