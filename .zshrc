# {{{ 环境
Z_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"/zsh
Z_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"/zsh
Z_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"/zsh
# 指定DATA和CACHE目录必须确保该目录存在，
# 否则zsh无法写入。zsh不会主动创建这些目录
[[ ! -d "$Z_DATA_DIR" ]] && mkdir -p "$Z_DATA_DIR"
[[ ! -d "$Z_CACHE_DIR" ]] && mkdir -p "$Z_CACHE_DIR"

Z_COMP_DIR="$Z_CACHE_DIR"
Z_COMPDUMP_PATH="$Z_COMP_DIR"/zcompdump
Z_COMPCACHE_DIR="$Z_COMP_DIR"/zcompcache

# 是否为ROOT用户
[[ $UID == 0 || $EUID == 0 ]] && Z_ENV_ROOT=1
# 是否在SSH会话中
[[ ${SSH_CLIENT:-${SSH_TTY}} ]] && Z_ENV_SSH=1
# 是否在Neovim终端中
[[ $NVIM ]] && Z_ENV_NVIM=1
# 是否在kitty中
[[ $TERM == 'xterm-kitty' ]] && Z_ENV_KITTY=1
# 是否在桌面
[[ $DISPLAY || $Z_ENV_KITTY -gt 0 ]] && Z_ENV_DESKTOP=1

### 外部资源
# 本地插件
fpath+=("$Z_CONFIG_DIR"/functions "$Z_CONFIG_DIR"/completions)

# zinit插件管理器
Z_ZINIT_BIN=/usr/share/zinit/zinit.zsh
if [[ ! -f "$Z_ZINIT_BIN" ]]; then
    Z_ZINIT_BIN="${XDG_DATA_HOME:-$HOME/.local/share}"/zinit/zinit.git/zinit.zsh
fi

# git的prompt部件
Z_SRC_GIT_PROMPT=/usr/share/git/git-prompt.sh

# fzf补全
Z_SRC_FZF_COMPLETION=/usr/share/fzf/completion.zsh
Z_SRC_FZF_KEYBIND=/usr/share/fzf/key-bindings.zsh

# pkgfile查找缺失的命令
Z_SRC_PKGFILE_HINT=/usr/share/doc/pkgfile/command-not-found.zsh
# }}}

# {{{ 选项
setopt correct			# 改正输错的命令
setopt interactive_comments	# 交互模式下允许注释
HISTSIZE=10000
SAVEHIST=100000
setopt share_history		# 多个实例共享历史记录
setopt hist_ignore_dups		# 不记录多条连续重复的历史
setopt hist_reduce_blanks	# 删除历史记录中的空行
setopt hist_find_no_dups	# 查找历史记录时忽略重复项
setopt hist_ignore_space    # 不记录空格开头的命令
# }}}

# {{{ 插件
if [[ -f "$Z_ZINIT_BIN" ]]; then
    source "$Z_ZINIT_BIN"
else
    echo "zinit not found" >/dev/stderr
fi

declare -A ZINIT
# 由于zcompdump的路径被修改，所以需要配置zinit使用同一路径
ZINIT[ZCOMPDUMP_PATH]="$Z_COMPDUMP_PATH"

### 语法高亮
zinit ice lucid wait
zinit light zdharma-continuum/fast-syntax-highlighting

### 提示历史命令
zinit ice lucid wait atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions
# 颜色 (注意tty)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=0'
# 先查找历史，如果没找到就采用补全
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# 修改按键
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(end-of-line)
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(forward-word forward-char)

### 更多的命令补全
zinit light zsh-users/zsh-completions

### 快速跳转目录
zinit ice lucid wait
zinit light skywind3000/z.lua
# 数据文件路径
export _ZL_DATA="$Z_DATA_DIR"/zlua
# 仅在当前路径$PWD改变时才更新数据库
export _ZL_ADD_ONCE=1
# 在跳转后显示目标路径名称
export _ZL_ECHO=1
# 增强匹配模式
export _ZL_MATCH_MODE=1

### 更多的git命令
zinit ice lucid wait'1' as"program" pick"$ZPFX/bin/git-*" \
    src"etc/git-extras-completion.zsh" make"PREFIX=$ZPFX"
zinit light tj/git-extras
# }}}

# {{{ 配色主题
# 设置$LS_COLORS
eval $(dircolors)
# $LS_COLORS去掉粗体
LS_COLORS=${LS_COLORS//=01/\=00}

autoload -Uz colors && colors
Z_PROMPT_COLOR_PWD=%{$fg[magenta]%}
Z_PROMPT_COLOR_COLLAPSED_PWD=%{$fg[white]%}
Z_PROMPT_COLOR_GIT=%{$fg[red]%}

Z_PROMPT_ERR="%{$fg[red]%}▌%{$reset_color%}"
Z_PROMPT_OK="%{$fg[blue]%}▌%{$reset_color%}"
Z_PROMPT_USER=%{$fg_bold[blue]%}\$%{$reset_color%}
Z_PROMPT_ROOT=%{$fg_bold[red]%}#%{$reset_color%}
if ((Z_ENV_DESKTOP)); then
    Z_PROMPT_SSH="%{$fg[blue]%}󰒍 %{$reset_color%}"
    Z_PROMPT_NVIM="%{$fg[blue]%} %{$reset_color%}"
else
    Z_PROMPT_SSH=%{$fg[blue]%}SSH%{$reset_color%}
    Z_PROMPT_NVIM=%{$fg[blue]%}VIM%{$reset_color%}
fi
# }}}

# {{{ PROMPT
# 加载git状态部件
if [[ -f $Z_SRC_GIT_PROMPT ]]; then
    source $Z_SRC_GIT_PROMPT
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_STATESEPARATOR=
    GIT_PS1_SHOWUPSTREAM=auto
    GIT_PS1_DESCRIBE_STYLE=default
fi

# 加载折叠路径部件
autoload -Uz collapsed_pwd

precmd() {
    local last_status=$?
    local prompt_array=()

    # 指示上一条命令的运行结果
    if (($last_status)); then
        prompt_array+=$Z_PROMPT_ERR
    else
        prompt_array+=$Z_PROMPT_OK
    fi

    # 显示运行环境
    ((Z_ENV_SSH)) && prompt_array+=$Z_PROMPT_SSH
    ((Z_ENV_NVIM)) && prompt_array+=$Z_PROMPT_NVIM

    # 当前目录的git状态
    if command -v __git_ps1 &>/dev/null; then
        local git_status=$(__git_ps1 "%s")
        if [[ $git_status ]]; then
            prompt_array+=$Z_PROMPT_COLOR_GIT$git_status%{$reset_color%}
        fi
    fi

    # 显示当前目录
    if command -v collapsed_pwd &>/dev/null; then
        prompt_array+=$Z_PROMPT_COLOR_PWD$(collapsed_pwd)%{$reset_color%}
    else
        prompt_array+=$PWD
    fi

    # 用户类型
    if ((Z_ENV_ROOT)); then
        prompt_array+=$Z_PROMPT_ROOT
    else
        prompt_array+=$Z_PROMPT_USER
    fi

    PROMPT="$prompt_array "
}

# 只在SSH环境中显示右提示符
if ((Z_ENV_SSH)); then
    Z_RPROMPT_NAME=%{$bg[red]$fg[black]%}%n%{$reset_color%}
    Z_RPROMPT_AT=%{$bg[magenta]$fg[black]%}@%{$reset_color%}
    Z_RPROMPT_HOST=%{$bg[red]$fg[black]%}%m%{$reset_color%}
    RPROMPT=$Z_RPROMPT_NAME$Z_RPROMPT_AT$Z_RPROMPT_HOST
fi

# 右提示符只出现一次
setopt transient_rprompt
# }}}

# {{{ 补全
autoload -Uz compinit
compinit -d "$Z_COMPDUMP_PATH"

# 压缩补全列表的列宽
setopt list_packed

# 失败时的提示
zstyle ':completion:*:warnings' format '%F{red} -- No Matches Found --%f'
# 彩色菜单
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# 使用菜单切换候选
zstyle ':completion:*' menu select
# 列表分组
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%K{black} %d %k'
# 文件列表目录优先
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' group-order local-directories

# 不区分大小写
zstyle ':completion:*' matcher-list '' 'm:{-a-zA-Z}={_A-Za-z}'
# 路径中多个斜杠被视为只有一个
zstyle ':completion:*' squeeze-slashes true

# 启用缓存
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$Z_COMPCACHE_DIR"

# fzf
[[ -f "$Z_SRC_FZF_COMPLETION" ]] && source "$Z_SRC_FZF_COMPLETION"
export FZF_COMPLETION_TRIGGER=''
export FZF_DEFAULT_COMMAND='fd -uu -E .git -E .node_modules'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# 命令找不到时提示软件名(通过pkgfile)
[[ -f "$Z_SRC_PKGFILE_HINT" ]] && source "$Z_SRC_PKGFILE_HINT"
# }}}

# {{{ 按键绑定
bindkey -e	# emacs风格
bindkey '^U' backward-kill-line

# 补全菜单
zmodload zsh/complist
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'J' vi-forward-blank-word
bindkey -M menuselect 'K' vi-backward-blank-word
bindkey -M menuselect 'H' beginning-of-buffer-or-history
bindkey -M menuselect 'L' end-of-buffer-or-history
bindkey -M menuselect 's' accept-and-hold
bindkey -M menuselect '/' accept-and-infer-next-history

# 当前命令行在编辑器中打开
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# 修改清屏方式
# 将内容挤出屏幕而不是直接清空
scroll-and-clear-screen() {
    printf '\n%.0s' {1..$LINES}
    zle clear-screen
} && zle -N scroll-and-clear-screen
bindkey '^L' scroll-and-clear-screen

# fzf
[[ -f "$Z_SRC_FZF_KEYBIND" ]] && source "$Z_SRC_FZF_KEYBIND"

# 空行按Tab时，展示当前目录
first-tab() {
    if [[ $#BUFFER == 0 ]]; then
        BUFFER="ls "
        CURSOR=3
        zle list-choices
        zle backward-kill-word
    else
        zle expand-or-complete
    fi
}
zle -N first-tab
bindkey '^I' first-tab

# 让 / = 作为分隔符
# 默认 WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'
# }}}

# {{{ 命令
# sudo后面的命令可以是alias
alias sudo='sudo '

### 命令的默认行为
alias ls='ls --color=auto --time-style=iso --human-readable --hyperlink=auto -F -v'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias mitmproxy="mitmproxy --set confdir=${XDG_CONFIG_HOME:-$HOME/.config}/mitmproxy"
alias mitmweb="mitmweb --set confdir=${XDG_CONFIG_HOME:-$HOME/.config}/mitmproxy"

### 命令缩写
alias sl='ls'
alias l='ls -l'
alias la='ls -A'
alias ll='ls -Al'
alias g='git'
alias x='xdg-open'
alias e='nvim'
alias f='ranger'
d() {
    if [ "$#" -eq 1 ]; then
        # 查看单个patch
        cat $1 | delta
    else
        # 比较两个文件
        diff -u "$1" "$2" | delta
    fi
}

# 需要搭配neovim配置
# https://github.com/rydesun/neovim-config/blob/master/init.lua#L4
# 使用neovim作为pager
alias v="nvim -R --cmd 'let pager=1'"
# 使用neovim作为pager，支持ANSI code
alias V="sh -c \"exec nvim 63<&0 </dev/null --cmd 'let termcat=63'\""

### 与kitty集成
if ((Z_ENV_KITTY)); then
    alias ssh='kitty +kitten ssh'
    alias rg='kitty +kitten hyperlinked_grep'
    alias icat='kitty +kitten icat'
    if ((Z_ENV_SSH)) then
        alias e='edit-in-kitty --type tab --title nvim-scp'
    fi
fi

alias cfg='GIT_DIR=$HOME/.myconf GIT_WORK_TREE=$HOME git'
alias cfg.e='GIT_DIR=$HOME/.myconf GIT_WORK_TREE=$HOME nvim'

mcd() { mkdir -p $1 && cd $1 }
mountdisk() {
    mount | grep -E '^(/dev/sd|/dev/nvme|/dev/mmcblk|gvfsd-fuse)' | \
        awk '{print $1 "\t" $5 "\t" $3 "\n\t\t" $6}'
}

# Arch Linux
alias pmq='pacman -Qs'
alias pms='pacman -Ss'
pmi() { pacman -Qii $1 2>/dev/null || pacman -Sii $1 }
pmo() { pacman -Qoq $1 2>/dev/null || pkgfile -i $1 }
pml() { (pacman -Qlq $1 2>/dev/null || pkgfile -lq $1) | sed -e '/\/$/d' -e '/^\/usr\/share\/locale\//d' }
pmb() { pml $1 | awk -F/ '/\/usr\/bin\/.+[^/]$/{print $NF}' }
pmd() { pml $1 | grep -e '\.service$' -e '\.socket$' -e '\.timer$' -e '\.desktop$' }
# }}}

# vim: foldmethod=marker:foldlevel=0
