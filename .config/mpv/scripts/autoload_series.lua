local mp = require 'mp'
local opt = require 'mp.options'
local utils = require 'mp.utils'

local user_opts = {
    max_distance = 2,   -- 文件名的最大差异
    max_distance_ratio = 0.5,   -- 文件名的最大差异占比
}

local script_name = mp.get_script_name()
opt.read_options(user_opts, script_name)

local function levenshtein_distance(s1, s2)
    local t = {}
    for i = 0, #s2 do
        table.insert(t, i)
    end

    for i = 2, #s1+1 do
        local t2 = {i-1}
        for j = 2, #s2+1 do
            local value
            if t[j-1] <= t[j] and t[j-1] <= t2[j-1] then
                local cost = s1:sub(i-1,i-1) ~= s2:sub(j-1,j-1) and 1 or 0
                value = t[j-1] + cost
            elseif t[j] < t2[j-1] then
                value = t[j] + 1
            else
                value = t2[j-1] + 1
            end
            table.insert(t2, value)
        end
        t = t2
    end
    return t[#s2+1]
end

local function similar_files(dir, filename)
    local o_basename, o_ext = filename:match("(.+)%.(.+)")
    local files = utils.readdir(dir, "files")
    local res = {}
    for _, file in pairs(files) do
        if file == filename then
            table.insert(res, file)
        else
            local basename, ext = file:match("(.+)%.(.+)")
            if ext ~= o_ext then
                goto continue
            end
            local distance = levenshtein_distance(basename, o_basename)
            if distance <= user_opts.max_distance
                or (distance/#o_basename <= user_opts.max_distance_ratio) then
                table.insert(res, file)
            end
        end
        ::continue::
    end
    return res
end

local function autoload_series()
    if mp.get_property_number("playlist-count", 1) > 1 then
        return
    end

    local filepath = mp.get_property("path", "")
    if filepath == nil or filepath:find("^http[s]?://") then
        return
    end
    local dir, filename = utils.split_path(filepath)
    if #dir == 0 then
        return
    end

    local files = similar_files(dir, filename)
    table.sort(files, function(s1, s2)
        if #s1 ~= #s2 then return #s1 < #s2 else return s1 < s2 end
    end)
    for i = 1, #files do
        if files[i] ~= filename then
            mp.commandv("loadfile", dir..'/'..files[i], "append")
        else
            mp.commandv("playlist-move", 0, i)
        end
    end
end

mp.register_event("start-file", autoload_series)
