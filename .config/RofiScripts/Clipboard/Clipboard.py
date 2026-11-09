#!/usr/bin/env python3
"""Provide cliphist entries and private, temporary thumbnails to the menu."""

import json
import os
from pathlib import Path
import re
import subprocess
import sys


def palette():
    defaults = {
        "surface": "#121316", "surface-container": "#1e2022",
        "surface-container-high": "#292a2d", "surface-container-highest": "#333537",
        "on-surface": "#e3e2e5", "on-surface-variant": "#c3c6cf",
        "primary": "#aac9f2", "on-primary": "#0d3253", "outline-variant": "#43474e",
    }
    try:
        content = (Path.home() / ".config/colors/colors.rasi").read_text()
        for key, value in re.findall(r"^\s*([\w-]+):\s*(#[0-9a-fA-F]{6,8})\s*;", content, re.M):
            if key in defaults:
                defaults[key] = value
    except OSError:
        pass
    return defaults


def entries():
    result = subprocess.run(["cliphist", "list"], capture_output=True, check=True, timeout=5)
    items = []
    for line in result.stdout.decode("utf-8", "replace").splitlines():
        clip_id, separator, content = line.partition("\t")
        if not separator or not clip_id.isdecimal():
            continue
        content = " ".join(content.replace("\x00", "").split())
        image = content.startswith("[[ binary data ")
        dimensions = re.search(r"\b(\d+x\d+)\b", content) if image else None
        items.append({
            "id": clip_id,
            "order": len(items) + 1,
            "image": image,
            "text": ("Изображение " + dimensions.group(1) if dimensions else "Изображение") if image else content,
            "search": content.casefold() + (" изображение картинка скриншот image screenshot" if image else ""),
        })
    return {"items": items, "palette": palette()}


def thumbnail(clip_id):
    if not clip_id.isdecimal():
        raise ValueError("Invalid clipboard ID")
    folder = Path(os.environ["CLIPBOARD_MENU_TMP"])
    output = folder / f"{clip_id}.image"
    temporary = folder / f"{clip_id}.{os.getpid()}.part"
    try:
        with temporary.open("wb") as handle:
            subprocess.run(["cliphist", "decode", clip_id], stdout=handle, check=True, timeout=10)
        os.replace(temporary, output)
    finally:
        temporary.unlink(missing_ok=True)


def copy(clip_id):
    if not clip_id.isdecimal():
        raise ValueError("Invalid clipboard ID")
    decode = subprocess.Popen(["cliphist", "decode", clip_id], stdout=subprocess.PIPE)
    try:
        copied = subprocess.run(["wl-copy"], stdin=decode.stdout, timeout=10)
    finally:
        if decode.stdout:
            decode.stdout.close()
    if decode.wait(timeout=10) != 0 or copied.returncode != 0:
        raise RuntimeError("Could not copy clipboard entry")


def delete(clip_id):
    if not clip_id.isdecimal():
        raise ValueError("Invalid clipboard ID")
    subprocess.run(["cliphist", "delete"], input=f"{clip_id}\n".encode(), check=True, timeout=5)
    folder = os.environ.get("CLIPBOARD_MENU_TMP")
    if folder:
        (Path(folder) / f"{clip_id}.image").unlink(missing_ok=True)


if __name__ == "__main__":
    try:
        if sys.argv[1:] == ["list"]:
            print(json.dumps(entries(), ensure_ascii=False))
        elif len(sys.argv) == 3 and sys.argv[1] == "thumbnail":
            thumbnail(sys.argv[2])
        elif len(sys.argv) == 3 and sys.argv[1] == "copy":
            copy(sys.argv[2])
        elif len(sys.argv) == 3 and sys.argv[1] == "delete":
            delete(sys.argv[2])
        else:
            raise ValueError("Invalid command")
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"Clipboard menu: {error}", file=sys.stderr)
        sys.exit(1)
