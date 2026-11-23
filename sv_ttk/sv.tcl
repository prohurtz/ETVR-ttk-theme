package require Tk 8.6-

namespace eval ::sv_ttk {
  variable dir [file dirname [file normalize [info script]]]

  # Sprite sheets ship at these scales (file suffix "" for 1x, else e.g. "_150").
  variable scales {1 1.25 1.5 1.75 2 2.5 3}

  # UI scale: the display's DPI relative to 96. Aqua scales HiDPI itself.
  # Set ::sv_ttk::requested_scale before sourcing this file to override it.
  if {[info exists requested_scale]} {
    variable factor [expr {double($requested_scale)}]
  } elseif {[tk windowingsystem] eq "aqua"} {
    variable factor 1.0
  } else {
    variable factor [expr {[tk scaling] * 72.0 / 96.0}]
  }
  if {$factor < 1.0} { set factor 1.0 }

  # Images and pixel sizes use the nearest shipped scale; fonts use the exact factor.
  variable scale 1
  foreach s $scales {
    if {abs($s - $factor) < abs($scale - $factor) - 1e-9} { set scale $s }
  }

  proc px {values} {
    variable scale
    set out {}
    foreach v $values { lappend out [expr {round($v * $scale)}] }
    return $out
  }

  proc suffix {} {
    variable scale
    if {$scale == 1} { return "" }
    return [format "_%d" [expr {round($scale * 100)}]]
  }

  # Themes load on first use (ttk::setTheme does `package require ttk::theme::<name>`).
  foreach theme {light dark} {
    package ifneeded ttk::theme::sun-valley-$theme 2.8.0 \
      [list source [file join $dir theme $theme.tcl]]
  }
}


if {[tk windowingsystem] == "win32"} {
  set static ""
} else {
  set static " static"
}

# Fonts come before the themes: the Treeview row height is measured from SunValleyBodyFont.
foreach {name family size} {
  SunValleyCaptionFont "Small" 12
  SunValleyBodyFont "Text" 14
  SunValleyBodyStrongFont "Text Semibold" 14
  SunValleyBodyLargeFont "Text" 18
  SunValleySubtitleFont "Display Semibold" 20
  SunValleyTitleFont "Display Semibold" 28
  SunValleyTitleLargeFont "Display Semibold" 40
  SunValleyDisplayFont "Display Semibold" 68
} {
  if {[tk windowingsystem] == "win32"} {
    set family "Segoe UI Variable$static $family"
  } else {
    # Segoe isn't installed here and the fallback search is slow (~40 ms);
    # name the family it would fall back to.
    set family [font actual TkDefaultFont -family]
  }
  font create $name -family $family -size [expr {-round($size * $::sv_ttk::factor)}]
}


proc config_entry_font {w} {
  set font_config [$w config -font]
  if {[lindex $font_config 3] != [lindex $font_config 4]} {
    return
  }
  if {[ttk::style theme use] in {"sun-valley-dark" "sun-valley-light"}} {
    $w configure -font SunValleyBodyFont
  }
}


proc config_menus {w} {
  if {[tk windowingsystem] == "aqua" || [tk windowingsystem] == "win32"} {
    return
  }

  set theme [ttk::style theme use]
  if {$theme == "sun-valley-dark"} {
    $w configure \
      -relief solid \
      -borderwidth 1 \
      -activeborderwidth 0 \
      -background "#242328" \
      -activebackground $ttk::theme::sv_dark::colors(-selbg) \
      -activeforeground $ttk::theme::sv_dark::colors(-selfg) \
      -selectcolor $ttk::theme::sv_dark::colors(-selfg)
  } elseif {$theme == "sun-valley-light"} {
    $w configure \
      -relief solid \
      -borderwidth 1 \
      -activeborderwidth 0 \
      -background "#e8e7e3" \
      -activebackground $ttk::theme::sv_light::colors(-selbg) \
      -activeforeground $ttk::theme::sv_light::colors(-selfg) \
      -selectcolor $ttk::theme::sv_light::colors(-selfg)
  }

  if {[[winfo toplevel $w] cget -menu] != $w} {
    if {$theme == "sun-valley-dark"} {
      $w configure -borderwidth 0 -background $ttk::theme::sv_dark::colors(-bg)
    } elseif {$theme == "sun-valley-light"} {
      $w configure -borderwidth 0 -background $ttk::theme::sv_light::colors(-bg)
    }
  }
}


# tk_setPalette builds a hidden toplevel holding one of every classic widget class
# (~30 ms) and probes every option on every widget. This applies the same colours and
# option-database defaults, probing each widget class only once.
namespace eval ::sv_ttk {
  variable class_options

  proc set_palette {args} {
    array set new $args
    lassign [winfo rgb . $new(background)] bg_r bg_g bg_b
    lassign [winfo rgb . $new(foreground)] fg_r fg_g fg_b
    set darkerBg [format #%02x%02x%02x [expr {(9*$bg_r)/2560}] \
      [expr {(9*$bg_g)/2560}] [expr {(9*$bg_b)/2560}]]
    foreach i {activeForeground insertBackground selectForeground highlightColor} {
      if {![info exists new($i)]} { set new($i) $new(foreground) }
    }
    if {![info exists new(disabledForeground)]} {
      set new(disabledForeground) [format #%02x%02x%02x \
        [expr {(3*$bg_r + $fg_r)/1024}] [expr {(3*$bg_g + $fg_g)/1024}] \
        [expr {(3*$bg_b + $fg_b)/1024}]]
    }
    foreach i {highlightBackground buttonBackground} {
      if {![info exists new($i)]} { set new($i) $new(background) }
    }
    if {![info exists new(selectColor)]} {
      set new(selectColor) [expr {$bg_r+1.5*$bg_g+0.5*$bg_b > 100000 ? "white" : "black"}]
    }
    foreach i {selectBackground troughColor} {
      if {![info exists new($i)]} { set new($i) $darkerBg }
    }

    set options {}
    foreach name [array names new] { lappend options $name -[string tolower $name] }
    recolor . $options new

    foreach name [array names new] { option add *$name $new($name) widgetDefault }
    array set ::tk::Palette [array get new]
  }

  proc recolor {w options colors} {
    variable class_options
    upvar $colors c
    set class [winfo class $w]
    if {![info exists class_options($class)]} {
      set class_options($class) {}
      foreach {name option} $options {
        if {![catch {$w cget $option}]} { lappend class_options($class) $name $option }
      }
    }
    foreach {name option} $class_options($class) { $w configure $option $c($name) }
    foreach child [winfo children $w] { recolor $child $options c }
  }
}

proc configure_colors {} {
  set theme [ttk::style theme use]
  if {$theme == "sun-valley-dark"} {
    ttk::style configure . \
      -background $ttk::theme::sv_dark::colors(-bg) \
      -foreground $ttk::theme::sv_dark::colors(-fg) \
      -troughcolor $ttk::theme::sv_dark::colors(-bg) \
      -focuscolor $ttk::theme::sv_dark::colors(-selbg) \
      -selectbackground $ttk::theme::sv_dark::colors(-selbg) \
      -selectforeground $ttk::theme::sv_dark::colors(-selfg) \
      -insertwidth 1 \
      -insertcolor $ttk::theme::sv_dark::colors(-fg) \
      -fieldbackground $ttk::theme::sv_dark::colors(-bg) \
      -font SunValleyBodyFont \
      -borderwidth 0 \
      -relief flat

    ::sv_ttk::set_palette \
      background $ttk::theme::sv_dark::colors(-bg) \
      foreground $ttk::theme::sv_dark::colors(-fg) \
      highlightColor $ttk::theme::sv_dark::colors(-selbg) \
      selectBackground $ttk::theme::sv_dark::colors(-selbg) \
      selectForeground $ttk::theme::sv_dark::colors(-selfg) \
      activeBackground $ttk::theme::sv_dark::colors(-selbg) \
      activeForeground $ttk::theme::sv_dark::colors(-selfg)

    ttk::style map . -foreground [list disabled $ttk::theme::sv_dark::colors(-disfg)]
  } elseif {$theme == "sun-valley-light"} {
    ttk::style configure . \
      -background $ttk::theme::sv_light::colors(-bg) \
      -foreground $ttk::theme::sv_light::colors(-fg) \
      -troughcolor $ttk::theme::sv_light::colors(-bg) \
      -focuscolor $ttk::theme::sv_light::colors(-selbg) \
      -selectbackground $ttk::theme::sv_light::colors(-selbg) \
      -selectforeground $ttk::theme::sv_light::colors(-selfg) \
      -insertwidth 1 \
      -insertcolor $ttk::theme::sv_light::colors(-fg) \
      -fieldbackground $ttk::theme::sv_light::colors(-bg) \
      -font SunValleyBodyFont \
      -borderwidth 0 \
      -relief flat

    ::sv_ttk::set_palette \
      background $ttk::theme::sv_light::colors(-bg) \
      foreground $ttk::theme::sv_light::colors(-fg) \
      highlightColor $ttk::theme::sv_light::colors(-selbg) \
      selectBackground $ttk::theme::sv_light::colors(-selbg) \
      selectForeground $ttk::theme::sv_light::colors(-selfg) \
      activeBackground $ttk::theme::sv_light::colors(-selbg) \
      activeForeground $ttk::theme::sv_light::colors(-selfg)

    ttk::style map . -foreground [list disabled $ttk::theme::sv_light::colors(-disfg)]
  }
}


bind [winfo class .] <<ThemeChanged>> {+configure_colors}
bind TEntry <<ThemeChanged>> {+config_entry_font %W}
bind TCombobox <<ThemeChanged>> {+config_entry_font %W}
bind TSpinbox <<ThemeChanged>> {+config_entry_font %W}
bind Menu <<ThemeChanged>> {+config_menus %W}
