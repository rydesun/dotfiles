local mp = require 'mp'
local utils = require 'mp.utils'


local function find_fonts_dir(base_dir)
    local sub_dirs = utils.readdir(base_dir, "dirs")
    if sub_dirs == nil then return end
    for _, sub_dir in ipairs(sub_dirs) do
        if sub_dir:lower() == "fonts" then
            return utils.join_path(base_dir, sub_dir)
        end
    end
end

mp.register_event("file-loaded", function()
    local path = mp.get_property("path")
    if not path then return end
    local base_dir = utils.split_path(path)
    local fonts_dir = find_fonts_dir(base_dir)
    if not fonts_dir then return end
    mp.set_property("file-local-options/sub-fonts-dir", fonts_dir)
end)
