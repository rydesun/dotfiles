local mp = require 'mp'
local utils = require 'mp.utils'
local opt = require 'mp.options'

local user_opts = {
    subtitle_ext_pattern = "(srt|ass|sub|sup)", -- 字幕文件名后缀
    min_length = 3,                         -- 最小触发长度
    dir_depth = 2,                          -- 搜索目录的深度
    another_dir = "",                       -- 额外指定的目录
    subtitle_pattern = "[0-9]+_chinese",    -- 额外匹配的字幕
}

local script_name = mp.get_script_name()
opt.read_options(user_opts, script_name)

local function get_parent_dir(filepath)
    return utils.split_path(utils.join_path(
        mp.get_property("working-directory"), filepath))
end

local function add_subtitles(dir, prefix_unified)
    local cmd = {'find', dir, '-maxdepth', tostring(user_opts.dir_depth),
            '-regextype', 'posix-egrep', '-regex', ".*\\."..user_opts.subtitle_ext_pattern}
    if user_opts.another_dir ~= "" then
        local another_dir = user_opts.another_dir:gsub('^~', os.getenv("HOME"))
        table.insert(cmd, 2, another_dir)
    end
    local res = utils.subprocess({args=cmd})

    local selected = false
    for subtitle_path in res.stdout:gmatch("[^\r\n]+") do
        local _, subtitle_name = utils.split_path(subtitle_path)
        local subtitle_name_unified = subtitle_name:lower():gsub(" ", ".")
        if subtitle_name_unified:find(user_opts.subtitle_pattern) or
            subtitle_name_unified:find(prefix_unified, 1, true) == 1 then
            if selected then
                mp.commandv('sub-add', subtitle_path, 'auto')
            else
                mp.commandv('sub-add', subtitle_path, 'select')
                selected = true
            end
        end
    end
end

local function add_current_subs()
    local filepath = mp.get_property("path")
    if filepath == nil or filepath:find("^http[s]?://") then
        return
    end
    local _, filename = utils.split_path(filepath)
    if #filename < user_opts.min_length then
        return
    end
    local filename_unified = filename:lower():gsub(" ", ".")
    local prefix = filename_unified:match("(.+%.[12][0-9][0-9][0-9])%..+") or
        filename_unified:match("(.+)%.[0-9]+p%..+") or
        filename_unified:match("(.+)%..+")
    local dir = get_parent_dir(filepath)
    add_subtitles(dir, prefix)
end

mp.register_event("file-loaded", add_current_subs)
