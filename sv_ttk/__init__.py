from __future__ import annotations

import tkinter
import warnings
from functools import partial
from pathlib import Path
from tkinter import ttk

TCL_THEME_FILE_PATH = Path(__file__).with_name("sv.tcl").absolute()

_THEME_NAMESPACES = {"sun-valley-dark": "sv_dark", "sun-valley-light": "sv_light"}


def _load_theme(style: ttk.Style, scale: float | None = None) -> None:
    if not isinstance(style.master, tkinter.Tk):
        raise TypeError("root must be a `tkinter.Tk` instance!")

    if not hasattr(style.master, "_sv_ttk_loaded"):
        if scale is not None:
            style.tk.call("namespace", "eval", "::sv_ttk", ["variable", "requested_scale", float(scale)])
        style.tk.call("source", str(TCL_THEME_FILE_PATH))
        style.master._sv_ttk_loaded = True  # type: ignore
    elif scale is not None and float(scale) != float(style.tk.call("set", "::sv_ttk::factor")):
        warnings.warn("sv_ttk: the scale is fixed when the theme first loads; ignoring scale=", stacklevel=3)


def get_theme(root: tkinter.Tk | None = None) -> str:
    style = ttk.Style(master=root)
    _load_theme(style)

    theme = style.theme_use()
    return {"sun-valley-dark": "dark", "sun-valley-light": "light"}.get(theme, theme)


def set_theme(theme: str, root: tkinter.Tk | None = None, *, scale: float | None = None) -> None:
    """Apply the dark or light theme.

    `scale` overrides the UI scale (1.0 = 96 DPI) detected from `tk scaling`.
    It only takes effect on the first call for a given root.
    """
    style = ttk.Style(master=root)
    _load_theme(style, scale)

    theme = theme.lower()

    if theme not in {"dark", "light"}:
        raise RuntimeError(f"not a valid sv_ttk theme: {theme}")

    style.theme_use(f"sun-valley-{theme}")


def toggle_theme(root: tkinter.Tk | None = None) -> None:
    style = ttk.Style(master=root)
    _load_theme(style)

    set_theme("light" if style.theme_use() == "sun-valley-dark" else "dark", root)


def get_colors(root: tkinter.Tk | None = None) -> dict[str, str]:
    """The active theme's palette, e.g. {"bg": "#18171c", "fg": "#ebe9f0", "accent": ...}."""
    style = ttk.Style(master=root)
    _load_theme(style)

    namespace = _THEME_NAMESPACES.get(style.theme_use())
    if namespace is None:
        raise RuntimeError("no sv_ttk theme is in use")

    flat = style.tk.splitlist(style.tk.call("array", "get", f"ttk::theme::{namespace}::colors"))
    return {key.lstrip("-"): str(value) for key, value in zip(flat[::2], flat[1::2])}


def get_scale(root: tkinter.Tk | None = None) -> float:
    """The scale the theme's images and spacing were built at (1.0 = 96 DPI)."""
    style = ttk.Style(master=root)
    _load_theme(style)

    return float(style.tk.call("set", "::sv_ttk::scale"))


use_dark_theme = partial(set_theme, "dark")
use_light_theme = partial(set_theme, "light")
