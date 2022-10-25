typeset -U path PATH
path=($path ~/.bin)

export XDG_CONFIG_HOME=~/.config
export XDG_CACHE_HOME=~/.cache
export XDG_DATA_HOME=~/.data
# export XDG_STATE_HOME=~/.state

### Zsh
export HISTFILE="$XDG_DATA_HOME"/zsh/history

### 终端
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export EDITOR=nvim
export MANPAGER="nvim +Man! --cmd 'let paging=1'"

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

# 环境变量 (桌面) {{{
### Qt
# 用qt5ct配置Qt主题
export QT_QPA_PLATFORMTHEME=qt5ct
# 禁止Qt自动缩放。用xrdb手动设置DPI
export QT_AUTO_SCREEN_SCALE_FACTOR=0

### Fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
# Kitty需要该变量
export GLFW_IM_MODULE=ibus
# }}}

# 同步所有环境变量到所有systemd将要启动的程序
dbus-update-activation-environment --systemd --all

# NOTE: 直接在登录shell中自启桌面环境
# 只在桌面环境使用中文
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    dbus-update-activation-environment --systemd LANG=zh_CN.UTF-8
    if true; then
        LANG=zh_CN.UTF-8 xinit qtile start
    else
        LANG=zh_CN.UTF-8 qtile start -b wayland
    fi
fi

# vim:foldmethod=marker
