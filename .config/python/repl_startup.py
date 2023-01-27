import atexit
import os
import readline
from functools import partial

# 命令历史的记录文件
xdg_data_home = os.getenv(
    'XDG_DATA_HOME', os.path.expanduser('~/.local/share'))
data_dir = os.path.join(xdg_data_home, 'python')
readline_history_file = os.path.join(data_dir, 'history')

try:
    readline.read_history_file(readline_history_file)
except FileNotFoundError:
    os.makedirs(data_dir, exist_ok=True)
    open(readline_history_file, 'wb').close()
    readline.read_history_file(readline_history_file)

readline.set_history_length(1000000)
atexit.register(readline.write_history_file, readline_history_file)

# 让输出的数据结构和Traceback带有语法高亮
# 需要安装python-rich
try:
    from rich import inspect, pretty, traceback
    pretty.install()
    inspect_methods = partial(inspect, methods=True)
    traceback.install()
except Exception:
    pass
