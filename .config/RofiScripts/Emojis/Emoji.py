#!/usr/bin/env python3
"""Emoji picker data and selection, compatible with the original usage log."""
import collections
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
DATA = HERE / 'emoji.tsv'
USAGE = Path(os.environ.get('XDG_DATA_HOME', Path.home() / '.local/share')) / 'RofiScripts/Emojis/usage.log'


def items():
    result = []
    for row in DATA.read_text(encoding='utf-8').splitlines():
        ident, emoji, category, name = row.split('\t', 3)
        result.append({'id': ident, 'emoji': emoji, 'category': category, 'name': name})
    return result


def palette():
    result = {'surface': '#121316', 'surface-container': '#1e2022', 'surface-container-highest': '#333537', 'on-surface': '#e3e2e5', 'on-surface-variant': '#c3c6cf', 'primary': '#aac9f2', 'on-primary': '#0d3253', 'outline-variant': '#43474e'}
    try:
        data = (Path.home() / '.config/colors/colors.rasi').read_text()
        for key, value in re.findall(r'^\s*([\w-]+):\s*(#[0-9a-fA-F]{6,8})\s*;', data, re.M):
            if key in result:
                result[key] = value
    except OSError:
        pass
    return result


def find_item(ident):
    return next(item for item in items() if item['id'] == ident)


def main():
    action = sys.argv[1]
    if action == 'list':
        try:
            counts = collections.Counter(USAGE.read_text(encoding='utf-8').splitlines())
        except FileNotFoundError:
            counts = collections.Counter()
        entries = items()
        for item in entries:
            item['count'] = counts[item['emoji']]
        print(json.dumps({'items': entries, 'palette': palette()}, ensure_ascii=False))
    elif action == 'select':
        item = find_item(sys.argv[2])
        subprocess.run(['wl-copy'], input=item['emoji'].encode(), check=True, timeout=10)
        USAGE.parent.mkdir(parents=True, exist_ok=True)
        with USAGE.open('a', encoding='utf-8') as usage:
            usage.write(item['emoji'] + '\n')
    elif action == 'type':
        item = find_item(sys.argv[2])
        time.sleep(0.25)
        if shutil.which('wtype'):
            subprocess.run(['wtype', item['emoji']], check=False)
    else:
        raise ValueError('Unknown action')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, IndexError, StopIteration, subprocess.SubprocessError) as error:
        print(f'Emoji picker: {error}', file=sys.stderr)
        sys.exit(1)
