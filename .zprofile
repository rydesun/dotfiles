typeset -U path PATH
path=($path ~/.bin)

export XDG_CONFIG_HOME=~/.config
export XDG_CACHE_HOME=~/.cache
export XDG_DATA_HOME=~/.data
# export XDG_STATE_HOME=~/.state

### Zsh
export ZDOTDIR="$XDG_CONFIG_HOME"/zsh
export HISTFILE="$XDG_DATA_HOME"/zsh/history

### 终端
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export EDITOR=nvim
export MANPAGER="nvim +Man! --cmd 'let paging=1'"

### GnuPG
export GNUPGHOME="$XDG_DATA_HOME"/gnupg

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

# 同步环境变量到所有systemd将要启动的程序
dbus-update-activation-environment --systemd --all

# 自启X环境
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    xinit qtile start
fi
