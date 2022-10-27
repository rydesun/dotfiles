# Linux 配置

~~使用 `pam_environment` 管理环境变量 (被上游移除。溜了溜了)~~  
使用 `zprofile` (zsh 作为 login shell) 管理环境变量，
调用 `dbus-update-activation-environment --systemd`
同步选择的环境变量到 dbus 和 systemd。  
因为 ssh 远程主机没有通过 pam 设置环境变量，
所以对 ssh 直接调用的命令无效，比如 `ssh USER@HOST env`。
如果远程主机在 zsh 中设置环境变量，
可以用 `ssh USER@HOST 'zsh -l -c "exec env"'`。

使用 [kitty](https://sw.kovidgoyal.net/kitty/) 虚拟终端：
[Why does Alacritty terminal gets more attention than Kitty?
](https://github.com/kovidgoyal/kitty/issues/2701)

使用 [everforest](https://github.com/sainnhe/everforest) 配色主题

使用 [zinit](https://github.com/zdharma-continuum/zinit) 管理 zsh 插件

## 更多

Neovim 配置移步至
[rydesun/neovim-config](https://github.com/rydesun/neovim-config)

Qtile WM 配置移步至
[rydesun/qtile-config](https://github.com/rydesun/qtile-config)
