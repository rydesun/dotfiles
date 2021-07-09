#!/usr/bin/bash -e

if ! command -v 7z &>/dev/null; then
	echo p7zip is missing >&2
	exit 1
fi

config_dir=${XDG_CONFIG_HOME:-~/.config}/mpv/
script_dir=${config_dir}/scripts/
shader_dir=${config_dir}/shaders/

echo "Updating scripts..."
curl -fL --create-dirs -o "${script_dir}/Thumbnailer.lua" \
	https://github.com/deus0ww/mpv-conf/raw/master/scripts/Thumbnailer.lua
curl -fL --create-dirs -o "${script_dir}/Thumbnailer_OSC.lua" \
	https://github.com/deus0ww/mpv-conf/raw/master/scripts/Thumbnailer_OSC.lua
curl -fL https://github.com/deus0ww/mpv-conf/raw/master/scripts/Thumbnailer_Worker.lua |
	sed "s/'19'/'-19'/" > "${script_dir}/Thumbnailer_Worker.lua"

curl -fL --create-dirs -o "${script_dir}/playlistmanager.lua" \
	https://github.com/jonniek/mpv-playlistmanager/raw/master/playlistmanager.lua

curl -fL --create-dirs -o "${script_dir}/zenity-open-files.lua" \
	https://github.com/alifarazz/mpv-zenity-open-files/raw/master/zenity-open-files.lua

echo "Updating shaders..."
curl -fL --create-dirs -o /tmp/mpv/fsrcnnx.7z \
	https://github.com/igv/FSRCNN-TensorFlow/releases/download/1.1/checkpoints_params.7z \
	&& 7z e -o"${shader_dir}" -y /tmp/mpv/fsrcnnx.7z FSRCNNX_x2_16-0-4-1.glsl \
	&& rm /tmp/mpv/fsrcnnx.7z

curl -fL --create-dirs -o "${shader_dir}/FSRCNNX_x2_8-0-4-1.glsl" \
	https://github.com/igv/FSRCNN-TensorFlow/releases/download/1.1/FSRCNNX_x2_8-0-4-1.glsl

curl -fL --create-dirs -o "${shader_dir}/FSRCNNX_x2_16-0-4-1_anime_enhance.glsl" \
	https://github.com/HelpSeeker/FSRCNN-TensorFlow/releases/download/1.1_distort/FSRCNNX_x2_16-0-4-1_anime_enhance.glsl

curl -fL --create-dirs -o "${shader_dir}/KrigBilateral.glsl" \
	https://gist.github.com/igv/a015fc885d5c22e6891820ad89555637/raw

curl -fL --create-dirs -o "${shader_dir}/adaptive-sharpen.glsl" \
	https://gist.github.com/igv/8a77e4eb8276753b54bb94c1c50c317e/raw

echo "Done."
