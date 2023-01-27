#!/bin/sh

# 加载其他软件包提供的配置
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && source "$f"
    done; unset f
fi

# 加载Xresources
[ -f ~/.xresources ] && xrdb -merge ~/.xresources

# 加载xprofile
[ -f ~/.xprofile ] && source ~/.xprofile

if [[ -n "$@" ]]; then
    # 启动锁屏程序
    xss-lock -- betterlockscreen -l &

    # 启动所有systemd管理的桌面程序
    systemctl start --user X11.target &

    exec "$@"
fi
