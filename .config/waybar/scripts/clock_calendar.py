#!/usr/bin/env python3

import calendar
import json
from datetime import datetime
from pathlib import Path

try:
    from zoneinfo import ZoneInfo  # py3.9+
except Exception:  # pragma: no cover
    ZoneInfo = None


TZ = "Europe/Moscow"
STATE_FILE = Path.home() / ".local" / "state" / "waybar-clock-mode"
RU_WEEKDAYS = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
RU_MONTH_NAMES = [
    "",
    "Январь",
    "Февраль",
    "Март",
    "Апрель",
    "Май",
    "Июнь",
    "Июль",
    "Август",
    "Сентябрь",
    "Октябрь",
    "Ноябрь",
    "Декабрь",
]

def now_in_tz() -> datetime:
    if ZoneInfo is None:
        return datetime.now()
    try:
        return datetime.now(ZoneInfo(TZ))
    except Exception:
        return datetime.now()


def month_block(year: int, month: int, today: datetime) -> list[str]:
    cal = calendar.Calendar(firstweekday=0)  # Monday
    month_name = RU_MONTH_NAMES[month]

    # The outer padding is consumed when today's brackets sit at either edge.
    # This keeps every month row the same width as the unmarked calendar grid.
    width = 22
    header = month_name.center(width)
    weekdays = f" {' '.join(RU_WEEKDAYS)} "

    lines = [header, weekdays]
    for week in cal.monthdayscalendar(year, month):
        cells: list[str] = []
        today_index = None
        for day in week:
            if day == 0:
                cells.append("  ")
            elif year == today.year and month == today.month and day == today.day:
                today_index = len(cells)
                cells.append(f"[{day:>2}]")
            else:
                cells.append(str(day).rjust(2))
        parts: list[str] = []
        for index, cell in enumerate(cells):
            if index == 0:
                # At the edges, brackets replace the outer padding.
                if today_index != 0:
                    parts.append(" ")
            elif index != today_index and index - 1 != today_index:
                # Inside the row, brackets replace the separators on both sides.
                parts.append(" ")
            parts.append(cell)

        if today_index != len(cells) - 1:
            parts.append(" ")
        week_line = "".join(parts)
        lines.append(week_line)

    while len(lines) < 8:
        lines.append(" " * width)
    return lines[:8]


def year_calendar(year: int, today: datetime) -> str:
    blocks = [month_block(year, m, today) for m in range(1, 13)]
    rows: list[str] = []
    gap = "  "
    for i in range(0, 12, 3):
        for line_idx in range(8):
            rows.append(gap.join(blocks[i + j][line_idx] for j in range(3)).rstrip())
        rows.append("")
    return "\n".join(rows).rstrip()


def main() -> None:
    now = now_in_tz()
    tooltip = f"<big>{now.year}</big>\n<tt><small>{year_calendar(now.year, now)}</small></tt>"
    mode = "default"
    try:
        mode = STATE_FILE.read_text(encoding="utf-8").strip() or "default"
    except FileNotFoundError:
        pass

    if mode == "alt":
        weekday = RU_WEEKDAYS[now.weekday()]
        text = f"󰸗 {weekday} {now:%d.%m.%y}"
    else:
        text = now.strftime(" %H:%M")
    print(json.dumps({"text": text, "tooltip": tooltip}))


if __name__ == "__main__":
    main()
