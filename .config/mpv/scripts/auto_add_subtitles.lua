local mp = require 'mp'
local utils = require 'mp.utils'
local opt = require 'mp.options'

local user_opts = {
    subtitle_ext_pattern = "(srt|ass|sub)", -- 字幕文件名后缀
    dir_depth = 2,                          -- 搜索目录的深度
    another_dir = "",                       -- 额外指定的目录
    subtitle_pattern = "[0-9]+_chinese",    -- 额外匹配的字幕
}

local script_name = mp.get_script_name()
opt.read_options(user_opts, script_name)

local function get_parrent_dir(filepath)
    return utils.split_path(utils.join_path(
        mp.get_property("working-directory"), filepath))
end

local function add_subtitles(dir, prefix)
    local cmd = {'find', dir, '-maxdepth', tostring(user_opts.dir_depth),
            '-regextype', 'posix-egrep', '-regex', ".*\\."..user_opts.subtitle_ext_pattern}
    if user_opts.another_dir ~= "" then
        local another_dir = user_opts.another_dir:gsub('^~/', os.getenv("HOME"))
        table.insert(cmd, 2, another_dir)
    end
    local res = utils.subprocess({args=cmd})

    local prefix_lower = prefix:lower()
    for subtitle_path in res.stdout:gmatch("[^\r\n]+") do
        local _, subtitle_name = utils.split_path(subtitle_path)
        if subtitle_name:lower():find(user_opts.subtitle_pattern) or
            subtitle_name:lower():find(prefix_lower, 1, true) then
            mp.commandv('sub-add', subtitle_path, 'select')
        end
    end
end

local function add_current_subs()
    local filepath = mp.get_property("path")
    if filepath == nil or filepath:find("^http[s]?://") then
        return
    end
    local _, filename = utils.split_path(filepath)
    local prefix = filename:match("(.+%.[12][0-9][0-9][0-9])%..+") or
        filename:match("(.+)%.[0-9]+p%..+") or
        filename:match("(.+)%..+")
    local dir = get_parrent_dir(filepath)
    add_subtitles(dir, prefix)
end

mp.register_event("file-loaded", add_current_subs)
