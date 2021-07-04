#!/usr/bin/bash -e

if ! command -v 7z &>/dev/null; then
	echo p7zip is missing >&2
	exit 1
fi

config_dir=${XDG_CONFIG_HOME:-~/.config}/mpv/
script_dir=${config_dir}/scripts/
shader_dir=${config_dir}/shaders/

echo "Updating scripts..."
curl -fL --create-dirs -o "${script_dir}/osc.lua" \
	https://github.com/422658476/MPV-EASY-Player/raw/master/mpv-easy-data/osc-style/osc-potplayer-box-knob-or-bar-0.lua

curl -fL --create-dirs -o "${script_dir}/zenity-open-files.lua" \
	https://github.com/alifarazz/mpv-zenity-open-files/raw/master/zenity-open-files.lua

echo "Updating shaders..."
curl -fL --create-dirs -o /tmp/mpv/fsrcnnx.7z \
	https://github.com/igv/FSRCNN-TensorFlow/releases/download/1.1/checkpoints_params.7z \
	&& 7z e -o"${shader_dir}" -y /tmp/mpv/fsrcnnx.7z FSRCNNX_x2_16-0-4-1.glsl \
	&& rm /tmp/mpv/fsrcnnx.7z

curl -fL --create-dirs -o "${shader_dir}/FSRCNNX_x2_16-0-4-1_anime_enhance.glsl" \
	https://github.com/HelpSeeker/FSRCNN-TensorFlow/releases/download/1.1_distort/FSRCNNX_x2_16-0-4-1_anime_enhance.glsl

echo "Done."
