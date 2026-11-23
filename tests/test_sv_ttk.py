import tkinter
from tkinter import ttk

import pytest
import sv_ttk


def test_set_theme():
    sv_ttk.set_theme("dark")
    assert sv_ttk.get_theme() == "dark"

    sv_ttk.set_theme("light")
    assert sv_ttk.get_theme() == "light"


def test_set_theme_using_ttk_dot_style_dot_theme_use():
    # theme is already loaded for the default root
    ttk.Style().theme_use("sun-valley-dark")
    assert sv_ttk.get_theme() == "dark"

    sv_ttk.set_theme("light")
    assert ttk.Style().theme_use() == "sun-valley-light"


def test_use_xxx_theme():
    sv_ttk.use_dark_theme()
    assert sv_ttk.get_theme() == "dark"

    sv_ttk.use_light_theme()
    assert sv_ttk.get_theme() == "light"


def test_toggle_theme():
    sv_ttk.set_theme("dark")
    assert sv_ttk.get_theme() == "dark"

    sv_ttk.toggle_theme()
    assert sv_ttk.get_theme() == "light"


def test_toggle_theme_uses_explicit_root():
    root = tkinter.Tk()
    sv_ttk.set_theme("dark", root=root)

    sv_ttk.toggle_theme(root=root)
    assert sv_ttk.get_theme(root=root) == "light"
    root.destroy()


def test_get_colors_follows_active_theme():
    style = ttk.Style()
    for theme in ("dark", "light"):
        sv_ttk.set_theme(theme)
        style.master.update()  # <<ThemeChanged>> is handled at idle time
        colors = sv_ttk.get_colors()
        assert colors["bg"] == str(style.lookup(".", "background"))
        assert colors["fg"] == str(style.lookup(".", "foreground"))


def test_classic_widgets_follow_palette():
    root = ttk.Style().master
    before = tkinter.Label(root)
    for theme in ("dark", "light"):
        sv_ttk.set_theme(theme)
        root.update()  # <<ThemeChanged>> is handled at idle time
        after = tkinter.Label(root)
        bg = sv_ttk.get_colors()["bg"]
        assert before.cget("background") == bg
        assert after.cget("background") == bg


def test_treeview_rows_fit_body_font():
    root = tkinter.Tk()
    sv_ttk.set_theme("dark", root=root)
    linespace = root.tk.call("font", "metrics", "SunValleyBodyFont", "-linespace")
    assert int(ttk.Style(root).lookup("Treeview", "rowheight")) >= linespace
    root.destroy()


def test_unloaded_theme_can_be_selected_directly():
    root = tkinter.Tk()
    sv_ttk.get_theme(root=root)  # loads sv_ttk but neither theme

    ttk.Style(root).theme_use("sun-valley-light")
    assert sv_ttk.get_theme(root=root) == "light"
    root.destroy()


@pytest.mark.parametrize(
    "requested, expected",
    [(1, 1.0), (1.25, 1.25), (1.4, 1.5), (1.75, 1.75), (2, 2.0), (2.5, 2.5), (3, 3.0), (4, 3.0)],
)
def test_every_scale_loads(requested, expected):
    root = tkinter.Tk()
    sv_ttk.set_theme("dark", root=root, scale=requested)
    assert sv_ttk.get_scale(root=root) == expected

    for theme in ("dark", "light"):
        sv_ttk.set_theme(theme, root=root)
        ttk.Checkbutton(root, text="x", style="Switch.TCheckbutton").pack()
        ttk.Treeview(root).pack()
        root.update()
    root.destroy()


def test_no_default_root():
    tkinter.NoDefaultRoot()
    with pytest.raises(RuntimeError):
        sv_ttk.get_theme()


def test_explicit_root():
    root = tkinter.Tk()
    assert sv_ttk.get_theme(root=root) == ttk.Style(root).theme_use()

    sv_ttk.set_theme("dark", root=root)
    assert sv_ttk.get_theme(root=root) == "dark"
