local mp = require 'mp'

local data_dir = os.getenv('XDG_DATA_HOME')
if data_dir == nil then
    data_dir = '~/.local/share'
end

mp.set_property('watch-later-directory', data_dir..'/mpv/watch_later')
