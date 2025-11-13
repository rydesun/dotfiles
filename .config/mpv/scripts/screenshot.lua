local mp = require 'mp'
local utils = require 'mp.utils'
local opt = require 'mp.options'

local user_opts = {
    -- 如果视频位于该目录下的子目录，则截图和视频保存在同一位置
    dirs = { '/mnt/', '/run/media/' },
    -- 否则位于XDG图片目录下的子目录mpv。如果XDG目录不存在则使用mpv默认值
}

local script_name = mp.get_script_name()
local raw_user_opts = { dirs = '' }
opt.read_options(raw_user_opts, script_name)
if raw_user_opts.dirs ~= "" then
    user_opts.dirs = utils.parse_json(raw_user_opts.dirs)
end

local function use_xdg_dir()
    local res = mp.command_native {
        name = 'subprocess',
        args = { 'xdg-user-dir', 'PICTURES' },
        capture_stdout = true,
    }
    local dir = res and res.stdout:gsub('\n', '') .. "/mpv" or ''
    mp.set_property('file-local-options/screenshot-directory', dir)
end

local function set_screenshot_dir()
    local filepath = mp.get_property("path")
    if filepath == nil or filepath:find("^http[s]?://") then
        use_xdg_dir()
        return
    end
    local dir, _ = utils.split_path(filepath)
    for _, prefix in pairs(user_opts.dirs) do
        if dir:find(prefix, 1, true) then
            mp.set_property('file-local-options/screenshot-directory', dir)
            return
        end
    end
    use_xdg_dir()
end

mp.register_event("file-loaded", set_screenshot_dir)
