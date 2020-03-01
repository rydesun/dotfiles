import atexit
import os
import readline


xdg_data_home = os.getenv('XDG_DATA_HOME', os.path.expanduser('~/.data'))
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
