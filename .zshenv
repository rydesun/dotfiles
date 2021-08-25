# default
export EDITOR=nvim
export BROWSER=firefox
export MANPAGER="nvim +Man! --cmd 'let $NVIM_AS_PAGER=1'"

# xdg base directory
export XDG_CONFIG_HOME=${HOME}/.config
export XDG_CACHE_HOME=${HOME}/.cache
export XDG_DATA_HOME=${HOME}/.data

# readline
export INPUTRC=${XDG_CONFIG_HOME}/readline/inputrc

# less
export LESSKEY=${XDG_CONFIG_HOME}/less/lesskey
export LESSHISTFILE=${XDG_DATA_HOME}/less/history

# wget
export WGETRC=${XDG_CONFIG_HOME}/wget/wgetrc

# zsh
export ZDOTDIR=${XDG_CONFIG_HOME}/zsh
export HISTFILE=${XDG_DATA_HOME}/zsh/history

# openssl
export RANDFILE=${XDG_DATA_HOME}/openssl/randfile

# golang
export GO111MODULE=on
export GOPROXY=https://goproxy.cn,direct
export GOCACHE=${XDG_CACHE_HOME}/go
export GOMODCACHE=${XDG_DATA_HOME}/go
export GOPATH=${XDG_DATA_HOME}/go
export GOBIN=${HOME}/bin/go

# python
export PYTHONSTARTUP=${XDG_CONFIG_HOME}/python/repl_startup.py
export PYTHONPYCACHEPREFIX=${HOME}/.cache/python
export PYTHONUSERBASE=${HOME}/.data/python
# ipython
export IPYTHONDIR=${XDG_CONFIG_HOME}/jupyter
export JUPYTER_CONFIG_DIR=${XDG_CONFIG_HOME}/jupyter
# pylint
export PYLINTHOME=${XDG_CACHE_HOME}/pylint
# mypy
export MYPY_CACHE_DIR=${XDG_CACHE_HOME}/mypy

# node
export NODE_REPL_HISTORY=${XDG_DATA_HOME}/node_repl_history

# npm
export NPM_CONFIG_USERCONFIG=${XDG_CONFIG_HOME}/npm/npmrc

# docker
export DOCKER_CONFIG=${XDG_CONFIG_HOME}/docker

# PATH
export PATH=${HOME}/bin:${GOBIN}:${PYTHONUSERBASE}/bin:${HOME}/.packages/node_modules/.bin:${PATH}
