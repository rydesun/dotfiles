# zle基础配置
setopt no_beep			# 不响铃
setopt correct			# 修正命令
setopt interactive_comments	# 交互模式支持注释

# 历史记录 <<<--------------------------
HISTSIZE=10000
SAVEHIST=100000
setopt share_history
# 写入时去掉重复和空白
setopt hist_ignore_dups hist_reduce_blanks
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
bindkey -e
# >>>-----------------------------------

# 提示符 <<<----------------------------
setopt prompt_subst
autoload -Uz promptinit
promptinit
autoload -Uz colors
colors
setopt transient_rprompt	# 右提示符只出现一次
PROMPT='%F{magenta}%B$(__git_ps1) %1~>%b%f '
RPROMPT='[%F{yellow}%?%f]%F{green}%n@%m Lv.%L%f'
# git <<<-------------------------------
source /usr/share/git/completion/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_DESCRIBE_STYLE="default"
# >>>-----------------------------------
# >>>-----------------------------------

# 扩展 <<<-------------------------
source /usr/share/doc/pkgfile/command-not-found.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# >>>-----------------------------------

# 命令别名 <<<-----------------------------
alias sudo='sudo '

alias e='nvim' && compdef e=nvim
alias ec='nvim -S'
alias g='git' && compdef g=git
alias p='python' && compdef p=python
alias mitm='proxychains -f ~/Archway/proxychains-mitm.conf'
alias gfw='proxychains -f ~/Archway/proxychains-gfw.conf'
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME' && compdef config=git

alias sl='ls'
alias l='ls -l --color=auto'
alias ll='ls -Al --color=auto'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias mv='mv -i'
alias rmf='rm -rf' && compdef rmf='rm'
alias ds='du -sh'
mcd() { mkdir -p $1 && cd $1 }

# 使用neovim作为pager
alias v='nvim -R -c "nnoremap q :exit<CR>"' && compdef v=nvim

alias pm='pacman'
alias pmu='sudo pacman -Syu'
alias pmq='pacman -Qs'
alias pms='pacman -Ss'
pmi() { pacman -Qi $1 2>/dev/null || pacman -Sii $1 }
pmo() { pacman -Qoq $1 2>/dev/null || pkgfile -i $1 }
pml() { (pacman -Qlq $1 2>/dev/null || pkgfile -lq $1) | sed '/\/$/d' }
pmb() { (pacman -Qlq $1 2>/dev/null || pkgfile -lq $1) | awk -F/ '/\/usr\/bin\/.+[^/]$/{print $NF}' }
# >>>-----------------------------------

# vim: foldmethod=marker:foldmarker=<<<---,>>>---
