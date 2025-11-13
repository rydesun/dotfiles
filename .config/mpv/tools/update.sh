#!/usr/bin/bash -e

config_dir=${XDG_CONFIG_HOME:-~/.config}/mpv/
script_dir=${config_dir}/scripts/
shader_dir=${config_dir}/shaders/

echo "Updating uosc..."
bash -c "$(curl -fL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh)"

curl -fL --create-dirs -o "${script_dir}/thumbfast.lua" \
	https://github.com/po5/thumbfast/raw/master/thumbfast.lua

echo "Updating shaders..."
curl -fL --create-dirs -o "${shader_dir}/FSRCNNX_x2_8-0-4-1.glsl" \
	https://github.com/igv/FSRCNN-TensorFlow/releases/download/1.1/FSRCNNX_x2_8-0-4-1.glsl

curl -fL --create-dirs -o "${shader_dir}/FSRCNNX_x1_16-0-4-1_distort.glsl" \
	https://github.com/HelpSeeker/FSRCNN-TensorFlow/releases/download/1.2_distort/FSRCNNX_x1_16-0-4-1_distort.glsl

curl -fL --create-dirs -o "${shader_dir}/KrigBilateral.glsl" \
	https://gist.github.com/igv/a015fc885d5c22e6891820ad89555637/raw

curl -fL --create-dirs -o "${shader_dir}/adaptive-sharpen.glsl" \
	https://gist.github.com/igv/8a77e4eb8276753b54bb94c1c50c317e/raw

echo "Done."
