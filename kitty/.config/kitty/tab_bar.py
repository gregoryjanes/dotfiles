# Custom kitty tab bar: tmux-style tabs on the left, date/time on the right.
# Also autosaves the kitty session periodically (tmux-continuum replacement).
import os
from datetime import datetime

from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer
from kitty.tab_bar import DrawData, ExtraData, TabAccessor, TabBarData, as_rgb, draw_tab_with_separator

CLOCK_FG = as_rgb(0x47524e)
CLOCK_BG = as_rgb(0xab9f6a)
AUTOSAVE_PATH = os.path.expanduser('~/.local/share/kitty/autosave.kitty-session')
AUTOSAVE_INTERVAL = 15 * 60

_timers_started = False


def _redraw(timer_id: int | None) -> None:
    for tm in get_boss().all_tab_managers:
        tm.mark_tab_bar_dirty()


def _autosave(timer_id: int | None) -> None:
    os.makedirs(os.path.dirname(AUTOSAVE_PATH), exist_ok=True)
    get_boss().save_as_session('--save-only', AUTOSAVE_PATH)


def _start_timers() -> None:
    global _timers_started
    if not _timers_started:
        _timers_started = True
        add_timer(_redraw, 30.0, True)
        add_timer(_autosave, AUTOSAVE_INTERVAL, True)


def _short_title(tab: TabBarData) -> str:
    # tmux automatic-rename: one word, the running program (zsh, nvim, python3).
    # A title set with prefix+, (set_tab_title) is kept as-is.
    t = get_boss().tab_for_id(tab.tab_id)
    if t is not None and t.name:
        return t.name
    exe = TabAccessor(tab.tab_id).active_exe.lstrip('-')
    return exe or (tab.title.split() or [''])[0]


def draw_tab(
    draw_data: DrawData, screen: Screen, tab: TabBarData,
    before: int, max_tab_length: int, index: int, is_last: bool,
    extra_data: ExtraData,
) -> int:
    _start_timers()
    tab = tab._replace(title=_short_title(tab))
    end = draw_tab_with_separator(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data)
    if is_last:
        clock = datetime.now().strftime(' %Y-%m-%d %H:%M ')
        padding = screen.columns - screen.cursor.x - len(clock)
        if padding >= 0:
            screen.cursor.bg = 0
            screen.draw(' ' * padding)
            screen.cursor.fg = CLOCK_FG
            screen.cursor.bg = CLOCK_BG
            screen.draw(clock)
    return end
