# zle基础配置
setopt no_beep			# 不响铃
setopt correct			# 修正命令
setopt interactive_comments	# 交互模式支持注释

# 插件 <<<------------------------------
source <(antibody init)
antibody bundle <<EOF
skywind3000/z.lua
zsh-users/zsh-completions
zsh-users/zsh-autosuggestions
zsh-users/zsh-syntax-highlighting
EOF
# z.lua <<<-----------------------------
# 数据文件路径
export _ZL_DATA=${XDG_DATA_HOME}/zsh/zlua
# 仅在当前路径$PWD改变时才更新数据库
export _ZL_ADD_ONCE=1
# 在跳转后显示目标路径名称
export _ZL_ECHO=1
# 增强匹配模式
export _ZL_MATCH_MODE=1
# >>>-----------------------------------
# zsh-autosuggestions <<<---------------
# 建议策略: history, completion, match_prev_cmd
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# 开启异步模式
ZSH_AUTOSUGGEST_USE_ASYNC=1
# >>>-----------------------------------
# pkgfile: 命令找不到时提示安装包
source /usr/share/doc/pkgfile/command-not-found.zsh
# function: 模仿fish折叠路径
source ${ZDOTDIR}/functions/fish_collapsed_pwd.sh
# >>>-----------------------------------

# 历史记录 <<<--------------------------
HISTSIZE=10000
SAVEHIST=100000
setopt share_history
# 去掉重复和空白
setopt hist_ignore_dups hist_reduce_blanks hist_find_no_dups
# >>>-----------------------------------

# 命令补全 <<<--------------------------
autoload -Uz compinit
# 注意: 指定缓存文件所在目录必须先确保该目录存在！
compinit -d ${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}
setopt complete_aliases		# 补全别名
setopt list_packed		# 补全列表压缩列宽
zstyle :compinstall filename ${XDG_CONFIG_HOME}/zsh/.zshrc
zstyle ':completion:*' menu select
# 模糊修正
zstyle ':completion:*' matcher-list '' 'm:{-a-zA-Z}={_A-Za-z}'
# >>>-----------------------------------

# 按键绑定 <<<--------------------------
# 默认Emacs
bindkey -e
# >>>-----------------------------------

# 提示符 <<<----------------------------
setopt prompt_subst
autoload -Uz promptinit
promptinit
autoload -Uz colors
colors
setopt transient_rprompt	# 右提示符只出现一次
PROMPT='%F{magenta}%B$(__git_ps1) $(_fish_collapsed_pwd)> %b%f'
RPROMPT='%{$bg[cyan]$fg[white]%} %n@%m %{$reset_color%}'
# git <<<-------------------------------
source /usr/share/git/completion/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_DESCRIBE_STYLE="default"
# >>>-----------------------------------
# >>>-----------------------------------

# 命令别名 <<<-----------------------------
# sudo后面的命令可以是别名
alias sudo='sudo '
# 设置命令默认行为
alias ls='ls --color=auto --time-style=iso --human-readable'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias mv='mv -i'

alias sl='ls'
alias l='ls -l'
alias la='ls -Al'
mcd() { mkdir -p $1 && cd $1 }

alias v='nvim -R -c "nnoremap q :exit<CR>"' && compdef v=nvim # 使用neovim作为pager
alias e='nvim' && compdef e=nvim
alias es='nvim -S' && compdef es=nvim
alias g='git' && compdef g=git
alias py='python' && compdef py=python
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME' && compdef config=git

alias pmq='pacman -Qs'
alias pms='pacman -Ss'
pmi() { pacman -Qi $1 2>/dev/null || pacman -Sii $1 }
pmo() { pacman -Qoq $1 2>/dev/null || pkgfile -i $1 }
pml() { (pacman -Qlq $1 2>/dev/null || pkgfile -lq $1) | sed '/\/$/d' }
pmb() { (pacman -Qlq $1 2>/dev/null || pkgfile -lq $1) | awk -F/ '/\/usr\/bin\/.+[^/]$/{print $NF}' }
# >>>-----------------------------------

# vim: foldmethod=marker:foldmarker=<<<---,>>>---
