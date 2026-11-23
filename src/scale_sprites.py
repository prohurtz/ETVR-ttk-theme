"""Render the theme sprites at HiDPI scales from the SVG sources.

    python3 scale_sprites.py            # writes src/<theme>/scale-<NNN>/*.png
    python3 scale_sprites.py --check    # only verify the 1x render matches the shipped PNGs

Needs `rsvg-convert` (librsvg), Pillow, NumPy and OpenCV (opencv-python).
Run from the `src` directory, then `node spritesheet_generator.js` to pack the sheets.

The 1x PNGs in src/<theme>/ are the reference: each sprite is located on the
rendered SVG page by template matching, then re-rendered from the SVG at every
scale through a viewBox covering exactly that sprite. Sprites that overlap a
neighbour on the page are rendered on their own (rsvg-convert --export-id).
"""

from __future__ import annotations

import glob
import os
import re
import subprocess
import sys
import tempfile

import cv2
import math
import numpy as np
from PIL import Image

SCALES = [1.25, 1.5, 1.75, 2, 2.5, 3]
THEMES = {"dark": (0x18, 0x17, 0x1C), "light": (0xFA, 0xF9, 0xF7)}  # window -bg, for RGB sprites
PAD_PX = 160  # canvas padding at 1x, a whole number of pixels so the sprite grid stays aligned
PAGE_MATCH_LIMIT = 1.5  # mean abs difference (0-255) for a page match to count


def tcl_round(v: float) -> int:
    """Round like Tcl's round() (halves away from zero), which sizes the borders in the theme."""
    return math.floor(v + 0.5)


def svg_root(svg: str) -> tuple[list[float], float]:
    vb = [float(v) for v in re.search(r'viewBox="([^"]+)"', svg).group(1).split()]
    width = float(re.search(r'<svg\b[^>]*?\swidth="([0-9.]+)', svg).group(1))
    return vb, width / vb[2]  # px per user unit


def with_view(svg: str, view: tuple[float, float, float, float], width: int, height: int) -> str:
    svg = re.sub(r'viewBox="[^"]+"', 'viewBox="%r %r %r %r"' % view, svg, count=1)
    svg = re.sub(r'(<svg\b[^>]*?\s)width="[^"]+"', rf'\g<1>width="{width}"', svg, count=1)
    svg = re.sub(r'(<svg\b[^>]*?\s)height="[^"]+"', rf'\g<1>height="{height}"', svg, count=1)
    return svg.replace("<svg\n", '<svg preserveAspectRatio="none"\n', 1)


def rsvg(svg_text: str, *args: str) -> np.ndarray:
    with tempfile.TemporaryDirectory() as tmp:
        src, out = os.path.join(tmp, "in.svg"), os.path.join(tmp, "out.png")
        with open(src, "w", encoding="utf-8") as f:
            f.write(svg_text)
        subprocess.run(["rsvg-convert", *args, src, "-o", out], check=True)
        return np.asarray(Image.open(out).convert("RGBA")).astype(np.float32)


def locate(page: np.ndarray, sprite: np.ndarray) -> tuple[int, int, float]:
    _, _, (x, y), _ = cv2.minMaxLoc(cv2.matchTemplate(page, sprite, cv2.TM_SQDIFF))
    h, w = sprite.shape[:2]
    return x, y, float(np.abs(page[y : y + h, x : x + w] - sprite).mean())


def finish(rgba: np.ndarray, mode: str, bg: tuple[int, int, int]) -> Image.Image:
    img = Image.fromarray(np.clip(rgba + 0.5, 0, 255).astype(np.uint8), "RGBA")
    if mode == "RGB":
        base = Image.new("RGBA", img.size, bg + (255,))
        img = Image.alpha_composite(base, img).convert("RGB")
    return img


def fit(rgba: np.ndarray, x: int, y: int, w: int, h: int) -> np.ndarray:
    out = np.zeros((h, w, 4), np.float32)
    src = rgba[max(y, 0) : y + h, max(x, 0) : x + w]
    out[max(-y, 0) : max(-y, 0) + src.shape[0], max(-x, 0) : max(-x, 0) + src.shape[1]] = src
    return out


def borders(theme: str) -> dict[str, int]:
    """sprite name -> 9-slice border at 1x, from the theme's element definitions."""
    tcl = open(f"../sv_ttk/theme/{theme}.tcl", encoding="utf-8").read()
    result = {}
    for block in re.findall(r"element create .*?(?=\n\s*\n|ttk::style element create|\Z)", tcl, re.S):
        border = re.search(r"-border \[::sv_ttk::px \{?([0-9 ]+)\}?\]", block)
        if border:
            for name in re.findall(r"\$I\(([^)]+)\)", block):
                result[name] = max(int(v) for v in border.group(1).split())
    return result


def stretch_ok(img: Image.Image, border: int) -> bool:
    a = np.asarray(img.convert("RGBA")).astype(int)
    h, w = a.shape[:2]
    ok = True
    if w > 2 * border + 1:
        band = a[:, border : w - border]
        ok &= int(np.abs(band - band[:, :1]).max()) <= 3
    if h > 2 * border + 1:
        band = a[border : h - border]
        ok &= int(np.abs(band - band[:1]).max()) <= 3
    return bool(ok)


def main() -> int:
    check_only = "--check" in sys.argv
    failures = 0
    for theme, bg in THEMES.items():
        svg = open(f"{theme}/{theme}.svg", encoding="utf-8").read()
        vb, ppu = svg_root(svg)
        pad = PAD_PX / ppu
        page_view = (vb[0] - pad, vb[1] - pad, vb[2] + 2 * pad, vb[3] + 2 * pad)
        page = rsvg(with_view(svg, page_view, tcl_round(page_view[2] * ppu), tcl_round(page_view[3] * ppu)))
        nine = borders(theme)

        for path in sorted(glob.glob(f"{theme}/*.png")):
            name = os.path.basename(path)[:-4]
            ref_img = Image.open(path)
            ref = np.asarray(ref_img.convert("RGBA")).astype(np.float32)
            h, w = ref.shape[:2]
            x, y, err = locate(page, ref)

            if err <= PAGE_MATCH_LIMIT:
                view = (page_view[0] + x / ppu, page_view[1] + y / ppu, w / ppu, h / ppu)

                def render(s: float) -> np.ndarray:
                    return rsvg(with_view(svg, view, tcl_round(w * s), tcl_round(h * s)))

            else:  # overlaps a neighbour on the page: render the element on its own
                alone = rsvg(svg, "-i", name, "-z", repr(ppu))
                padded = np.zeros((alone.shape[0] + 2 * h, alone.shape[1] + 2 * w, 4), np.float32)
                padded[h : h + alone.shape[0], w : w + alone.shape[1]] = alone
                ox, oy, err = locate(padded, ref)
                ox, oy = ox - w, oy - h
                if err > 6:  # the shipped 1x sprite is clipped (scrollbar-left/up): use the vector as drawn
                    ox, oy = 0, 0
                    print(f"{theme:5s} {name:28s} shipped 1x differs from the SVG; scaling the SVG as drawn")

                def render(s: float) -> np.ndarray:
                    img = rsvg(svg, "-i", name, "-z", repr(ppu * s))
                    return fit(img, tcl_round(ox * s), tcl_round(oy * s), tcl_round(w * s), tcl_round(h * s))

            one = finish(render(1), ref_img.mode, bg)
            diff = float(np.abs(np.asarray(one.convert("RGBA")).astype(np.float32) - ref).mean())
            status = "ok" if diff <= 6 else "DIFFERS"
            if diff > 6 and err <= 6:
                failures += 1
            print(f"{theme:5s} {name:28s} 1x diff {diff:5.2f} {status}")
            if check_only:
                continue

            for s in SCALES:
                img = finish(render(s), ref_img.mode, bg)
                if name in nine and stretch_ok(ref_img, nine[name]):
                    if not stretch_ok(img, tcl_round(nine[name] * s)):
                        # e.g. the progress bar's rounded end reaches slightly past its border
                        print(f"      warning: {name} @{s}: 9-slice stretch band is not uniform")
                out_dir = f"{theme}/scale-{tcl_round(s * 100)}"
                os.makedirs(out_dir, exist_ok=True)
                img.save(f"{out_dir}/{name}.png", optimize=True)

    print("failures:", failures)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
