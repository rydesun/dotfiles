local mp = require 'mp'

local function get_xattr_comment(path)
    local p = io.popen(string.format(
        "getfattr -n user.timemarks --only-values %q 2>/dev/null", path
    ))
    if not p then return nil end
    local out = p:read("*a")
    p:close()
    return #out > 0 and out or nil
end

local function set_xattr_comment(path, comment)
    local cmd
    if comment == "" then
        cmd = string.format("setfattr -x user.timemarks %q", path)
    else
        cmd = string.format("setfattr -n user.timemarks -v %q %q", comment, path)
    end
    os.execute(cmd)
end

local function parse_time(tstr)
    local h, m, s
    if tstr:match("^%d+:%d+:%d+$") then
        h, m, s = tstr:match("^(%d+):(%d+):(%d+)$")
        return tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s)
    elseif tstr:match("^%d+:%d+$") then
        m, s = tstr:match("^(%d+):(%d+)$")
        return tonumber(m) * 60 + tonumber(s)
    end
end

local function format_time(sec)
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = math.floor(sec % 60)
    if h > 0 then
        return string.format("%d:%02d:%02d", h, m, s)
    else
        return string.format("%02d:%02d", m, s)
    end
end

local function to_timemark(time_str, title)
    local sec = parse_time(time_str)
    if not sec then return end
    return { time = sec, title = (#title > 0) and title or "" }
end

local function get_timemarks()
    local path = mp.get_property("path")
    if not path then return end
    local comment = get_xattr_comment(path)
    if not comment then return end

    local marks = {}
    for time_str, title in comment:gmatch("{(%d+:%d+:%d+)%s*([^:}]*)}") do
        local mark = to_timemark(time_str, title)
        if mark then table.insert(marks, mark) end
    end
    for time_str, title in comment:gmatch("{(%d+:%d+)%s*([^:}]*)}") do
        local mark = to_timemark(time_str, title)
        if mark then table.insert(marks, mark) end
    end
    table.sort(marks, function(a, b) return a.time < b.time end)
    return marks
end

local function create_chapters()
    local marks = get_timemarks()
    if marks and #marks > 0 then
        mp.set_property_native("chapter-list", marks)
    end
end

local function get_current_chapter_pos()
    local chapter_list = mp.get_property_native("chapter-list")
    if not chapter_list or #chapter_list == 0 then return end
    local current_time = mp.get_property_number("time-pos", 0)

    local current_chapter
    for _, chapter in ipairs(chapter_list) do
        if current_time >= chapter.time then
            current_chapter = chapter
        else
            break
        end
    end
    return current_chapter and current_chapter.time or nil
end

local function append_current_time()
    local path = mp.get_property("path")
    if not path then return end
    local pos = mp.get_property_number("time-pos")
    if not pos then return end
    local tstr = format_time(pos)
    local comment = get_xattr_comment(path) or ""
    comment = comment .. "{" .. tstr .. "}"
    set_xattr_comment(path, comment)
    mp.osd_message("添加时间标记：" .. tstr)
    create_chapters()
end

local function remove_current_time()
    local current_chapter_pos = get_current_chapter_pos()
    if not current_chapter_pos then return end

    mp.commandv("seek", current_chapter_pos, "absolute")
    local tstr = format_time(current_chapter_pos)
    local path = mp.get_property("path")
    if not path then return end
    local comment = get_xattr_comment(path) or ""
    comment = comment:gsub("{" .. tstr .. "%s*[^}]*}", "")
    set_xattr_comment(path, comment)
    mp.osd_message("删除时间标记：" .. tstr)
    local marks = get_timemarks()
    if marks and #marks > 0 then
        mp.set_property_native("chapter-list", marks)
    else
        -- 必须清空所有章节信息
        mp.set_property_native("chapter-list", {})
    end
end

mp.register_event("file-loaded", create_chapters)
mp.register_script_message("xattr-append-timemark", append_current_time)
mp.register_script_message("xattr-remove-timemark", remove_current_time)
