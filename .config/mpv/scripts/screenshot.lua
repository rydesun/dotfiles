local mp = require 'mp'
local utils = require 'mp.utils'
local opt = require 'mp.options'

local user_opts = {
    -- 如果视频位于该目录下的子目录，则截图和视频保存在同一位置
    dirs = {'/mnt/', '/run/media/'},
}

local script_name = mp.get_script_name()
opt.read_options(user_opts, script_name)

local function set_screenshot_dir()
    local filepath = mp.get_property("path")
    if filepath == nil or filepath:find("^http[s]?://") then
        return
    end
    local dir, _ = utils.split_path(filepath)
    for _, prefix in pairs(user_opts.dirs) do
        if dir:find(prefix, 1, true) then
            mp.set_property('screenshot-directory', dir)
            return
        end
    end
end

mp.register_event("file-loaded", set_screenshot_dir)
