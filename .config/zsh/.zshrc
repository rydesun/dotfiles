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
# fzf
# source /usr/share/fzf/completion.zsh
# >>>-----------------------------------

# 按键绑定 <<<--------------------------
# 默认Emacs
bindkey -e
# fzf
source /usr/share/fzf/key-bindings.zsh
# >>>-----------------------------------

# 提示符 <<<----------------------------
setopt prompt_subst
autoload -Uz promptinit
promptinit
autoload -Uz colors
colors
setopt transient_rprompt	# 右提示符只出现一次

_color_purple=$'%{\e[38;2;199;146;234m%}'
_color_invert=$'%{\e[7m%}'
_color_reset=$'%{\e[0m%}'

ZLE_RPROMPT_INDENT=0		# 去掉右提示符右侧多余空白
precmd() {
	# 上一条命令的运行结果
	if [ $? -ne 0 ]; then
		PROMPT_err="%{$bg[red]$fg[black]%} E %{$reset_color%}"
	else
		PROMPT_err=""
	fi

	_collapsed_pwd=$(_fish_collapsed_pwd)
	PROMPT_host="${_color_purple}${_color_invert} %n@%m ${_color_reset}"
	# ssh标志
	if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
		PROMPT_ssh="%{$bg[yellow]$fg[black]%} ssh %{$reset_color%}"
	else
		PROMPT_ssh=""
	fi
	# tmux标志
	if [ -n "$TMUX" ]; then
		PROMPT_tmux="%{$bg[green]$fg[black]%} tmux %{$reset_color%}"
	else
		PROMPT_tmux=""
	fi
	# python virtualenv标志
	if [ -n "$VIRTUAL_ENV" ]; then
		PROMPT_pyvenv="%{$bg[cyan]$fg[black]%} pyvenv %{$reset_color%}"
	else
		PROMPT_pyvenv=""
	fi
	PROMPT_git=$(__git_ps1 " %s)")
	PROMPT_cwd=${_collapsed_pwd}
	PROMPT_tail=" %# "

	PROMPT="${_color_purple} ┃${PROMPT_git} ${PROMPT_cwd}${PROMPT_tail}${_color_reset}"
	RPROMPT="${PROMPT_err}${PROMPT_pyvenv}${PROMPT_tmux}${PROMPT_ssh}${PROMPT_host}"

	# 设置终端标题
	print -n "\e]0;zsh ( ${_collapsed_pwd} )\a"
}
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
