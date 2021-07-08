local mp = require 'mp'
local utils = require 'mp.utils'

local function levenshtein_distance(s1, s2)
    local t = {}
    for i = 0, #s1 do
        local arr = {}
        for j = 0, #s2 do
            local value = 0
            if i == 0 then
                value = j
            elseif j == 0 then
                value = i
            end
            table.insert(arr, value)
        end
        table.insert(t, arr)
    end

    for i = 2, #s1+1 do
        for j = 2, #s2+1 do
            local cost = 0
            if s1:sub(i-1,i-1) ~= s2:sub(j-1,j-1) then
                cost = 1
            end
            t[i][j] = math.min(
                t[i-1][j] + 1,
                t[i][j-1] + 1,
                t[i-1][j-1] + cost)
        end
    end
    return t[#s1+1][#s2+1]
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
            if distance <= 2 or (distance/#o_basename <= 0.5) then
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
    table.sort(files)
    for i = 1, #files do
        if files[i] ~= filename then
            mp.commandv("loadfile", dir..'/'..files[i], "append")
        else
            mp.commandv("playlist-move", 0, i)
        end
    end
end

mp.register_event("start-file", autoload_series)
