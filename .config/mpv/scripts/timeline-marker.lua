local mp = require 'mp'
local utils = require 'mp.utils'

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

local function get_current_and_next_chapter()
    local chapter_list = mp.get_property_native("chapter-list")
    if not chapter_list or #chapter_list == 0 then return end
    local current_time = mp.get_property_number("time-pos", 0)

    local current_chapter, next_chapter
    for _, chapter in ipairs(chapter_list) do
        if current_time >= chapter.time then
            current_chapter = chapter
        else
            next_chapter = chapter
            break
        end
    end
    return current_chapter, next_chapter
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
    local current_chapter = get_current_and_next_chapter()
    if not current_chapter then return end

    mp.commandv("seek", current_chapter.time, "absolute")
    local tstr = format_time(current_chapter.time)
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

local function modify_current_title()
    local current_chapter = get_current_and_next_chapter()
    if not current_chapter then return end

    local res = utils.subprocess({
        args = { "kdialog", "--inputbox", "编辑标题", current_chapter.title },
        cancellable = false
    })
    if res.error or res.status ~= 0 then return end
    local input = res.stdout:gsub("^%s+", ""):gsub("%s+$", "")

    local path = mp.get_property("path")
    if not path then return end
    local comment = get_xattr_comment(path)
    if not comment then return end
    local tstr = format_time(current_chapter.time)

    if input ~= "" then
        local new_fmt = "{" .. tstr .. " " .. input .. "}"
        comment = comment:gsub("{" .. tstr .. "%s*[^}]*}", new_fmt)
        mp.osd_message("时间标记的新标题：" .. input)
    else
        local new_fmt = "{" .. tstr .. "}"
        comment = comment:gsub("{" .. tstr .. "%s*[^}]*}", new_fmt)
        mp.osd_message("清除时间标记的标题")
    end
    set_xattr_comment(path, comment)
    create_chapters()
end

local mark_combo = {
    enabled = false,
    timer = nil,
}
mp.register_script_message('set', function(prop, _)
    if prop ~= "timemark-combo" then return end
    mark_combo.toggle()
end)

function mark_combo.toggle()
    mark_combo.enabled = not mark_combo.enabled
    if mark_combo.enabled then
        local chapter_list = mp.get_property_native("chapter-list")
        if #chapter_list == 0 then
            mark_combo.stop()
            return
        end
        if mp.get_property_native("pause") then
            mp.commandv("set", "pause", "no")
        end
        mp.commandv('script-message-to', 'uosc', 'set', 'timemark-combo', "yes")
        mark_combo.multistep(chapter_list)
    else
        mark_combo.stop()
    end
end

function mark_combo.stop()
    mp.commandv('script-message-to', 'uosc', 'set', 'timemark-combo', "no")
    mark_combo.enabled = false
    if mark_combo.timer then
        mark_combo.timer:kill()
        mark_combo.timer = nil
    end
end

function mark_combo.multistep(chapter_list)
    local min_duration = 10
    if mp.get_property_native("pause") then
        mark_combo.stop()
        return
    end

    local current_time = mp.get_property_number("time-pos", 0)
    local duration = min_duration + math.random(min_duration / 2)
    local current_chapter, next_chapter = get_current_and_next_chapter()

    if current_chapter then
        local current_offset = current_time - current_chapter.time
        -- 防止相邻的两个时间标记过近导致错过当前标记，需要先播放完当前标记
        if current_offset < duration then
            -- 当前标记的剩余时长，不可以跳到下个标记
            duration = duration - current_offset
        else
            if next_chapter then
                mp.commandv("seek", next_chapter.time, "absolute")
            else
                -- 从头播放
                next_chapter = chapter_list[1]
                mp.commandv("seek", next_chapter.time, "absolute")
            end
        end
    elseif next_chapter then
        mp.commandv("seek", next_chapter.time, "absolute")
    else
        -- #chapter_list > 0
    end

    mark_combo.timer = mp.add_timeout(duration, function()
        mark_combo.multistep(chapter_list)
    end)
end

mp.register_event("file-loaded", create_chapters)
mp.register_event("file-loaded", mark_combo.stop)

mp.register_script_message("xattr-append-timemark", append_current_time)
mp.register_script_message("xattr-remove-timemark", remove_current_time)
mp.register_script_message("xattr-modify-timemark-title", modify_current_title)
mp.register_script_message("timemark-combo-toggle", mark_combo.toggle)
