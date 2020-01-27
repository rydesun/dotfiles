HISTSIZE=10000
SAVEHIST=100000
setopt nomatch
bindkey -e
zstyle :compinstall filename '/home/helia/.zshrc'
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'

# !make sure the folder exists!
autoload -Uz compinit && compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION

source /usr/share/git/completion/git-prompt.sh
setopt prompt_subst
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_DESCRIBE_STYLE="default"

setopt completealiases
setopt appendhistory share_history hist_ignore_dups
setopt listpacked
setopt transient_rprompt

autoload -U promptinit colors
promptinit; colors
# precmd () { __git_ps1 "%n" ":%~$ " "|%s" }
PROMPT='%F{5}%B$(__git_ps1) %1~>%b%f '
RPROMPT='%F{5}%B%d%b%f'

source /usr/share/doc/pkgfile/command-not-found.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias sudo='sudo '

alias e='nvim' && compdef e='nvim'
alias g='git' && compdef g='git'
alias glg='git lg'
alias p='python' && compdef p='python'
alias mitm='proxychains -f ~/Archway/proxychains-mitm.conf'
alias gfw='proxychains -f ~/Archway/proxychains-gfw.conf'
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'

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

alias -g LL='| less'

alias pm='pacman'
alias pmu='sudo pacman -Syu'
alias pmq='pacman -Qs'
alias pms='pacman -Ss'
pmi() { pacman -Qi $1 2>/dev/null || pacman -Sii $1 }
pmo() { pacman -Qoq $1 2>/dev/null || pkgfile -i $1 }
pml() { (pacman -Qlq $1 2>/dev/null || pkgfile -lq $1) | sed '/\/$/d' }
pmb() { pacman -Ql $1 | awk -F/ '/\/usr\/bin\/.+[^/]$/{print $NF}' }

if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec startx "$XDG_CONFIG_HOME/X11/xinitrc"
fi
