#!/usr/bin/env python3
"""Kitten to print the current list of keyboard shortcuts (consists of BOTH single keys and key
sequences).

https://github.com/kovidgoyal/kitty/issues/2164#issuecomment-1501097471
"""

import re
from collections import defaultdict
from typing import Optional, Union, Final

from kittens.tui.handler import result_handler
from kitty import fast_data_types
from kitty.boss import Boss
from kitty.options.utils import KeyMap, MouseEvent, SequenceMap
from kitty.tab_bar import Formatter as fmt
from kitty.types import Shortcut, mod_to_names

# List of categories and regular expressions to match actions on
categories: Final = {
    "Scrollback": r"(^scroll_|show_scrollback|.*show.*_command_output)",
    "Tab Management": r"(^|_)tab( |_|$)",
    "Window Management": r"(^|_)windows?(_|$)",
    "Layout Management": r"(^|_)layout(_|\b)",
    "Hints": r"(_|\b)hints\b",
    "Clipboard": r"(_to|_from|paste)_(clipboard|selection)",
    "Options": r"^(set_|toggle_|change_)",
    "Mouse Click": r"mouse_handle_click",
    "Mouse Selection": r"mouse_selection",
    "Other Shortcuts": r".",
}

ShortcutRepr = str
ActionMap = dict[str, list[ShortcutRepr]]


def main(args: list[str]) -> Optional[str]:
    pass


@result_handler(no_ui=True)
def handle_result(args: list[str], answer: str, target_window_id: int, boss: Boss):
    if boss.active_window is None:
        return

    opts = fast_data_types.get_options()

    # set up keymaps (single keystrokes)
    _keymap: KeyMap = (
        boss.keymap
    )  # same as `opts.keymap`, except with global keymaps removed
    keymap: dict[Union[Shortcut, MouseEvent], str] = {
        Shortcut((key,)): action for key, action in _keymap.items()
    }
    # set up key sequences (combinations of keystrokes, separated by '>')
    _seq_keymap: SequenceMap = opts.sequence_map
    seq_keymap: dict[Shortcut, str] = {
        Shortcut((key, *subseq_keys)): action
        for key, subseq in _seq_keymap.items()
        for subseq_keys, action in subseq.items()
    }
    keymap.update(seq_keymap.items())

    # and mousemap
    mousemap: dict[MouseEvent, str] = opts.mousemap
    keymap.update(mousemap.items())

    # categorize shortcuts
    # because each action can have multiple shortcuts associated with it, we also attempt to
    # group shortcuts with the same actions together.
    output_categorized: dict[str, ActionMap] = defaultdict(lambda: defaultdict(list))
    for key, action in keymap.items():
        key_repr: ShortcutRepr = key.human_repr(kitty_mod=opts.kitty_mod)
        key_repr = f"{key_repr:<15} {fmt.fg.red}→{fmt.fg.default} {action}"

        for subheader, re_pat in categories.items():
            if re.search(re_pat, action):
                action_map: ActionMap = output_categorized[subheader]
                action_map[action].append(key_repr)
                break
        else:
            emsg = f"No valid subheader found for keymap {key_repr!r}."
            raise ValueError(emsg)

    # print out shortcuts
    output = [
        "Kitty keyboard mappings",
        "=======================",
        "",
        "My kitty_mod is {}.".format("+".join(mod_to_names(opts.kitty_mod))),
        "",
    ]
    for category in categories:
        if category not in output_categorized:
            continue
        output.extend([category, "=" * len(category), ""])
        output.extend(sum(output_categorized[category].values(), []))
        output.append("")

    boss.display_scrollback(
        boss.active_window,
        "\n".join(output),
        title="Kitty keyboard mappings",
        report_cursor=False,
    )
