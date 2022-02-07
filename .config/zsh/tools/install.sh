#!/bin/zsh -e

zinit_bin_dir=${XDG_DATA_HOME:-~/.data}/zinit/bin

if [[ -e $zinit_bin_dir ]]; then
	echo Clean up old zinit bin dir.
	rm -rf $zinit_bin_dir
fi

echo Installing zinit...
git clone --depth 1 --single-branch \
	https://github.com/zdharma-continuum/zinit.git $zinit_bin_dir
