source [file join [file dirname [info script]] sprites_light[::sv_ttk::suffix].tcl]

namespace eval ttk::theme::sv_light {
  package provide ttk::theme::sv_light 2.5
  package provide ttk::theme::sun-valley-light 2.8.0

  array set colors {
    -fg      "#1f1d26"
    -bg      "#faf9f7"
    -disfg   "#a19fa3"
    -selfg   "#ffffff"
    -selbg   "#6750c8"
    -accent  "#6750c8"
    -surface "#f3f2ef"
    -border  "#d8d6d2"
    -muted   "#54525e"
  }

  proc load_images {imgfile} {
    variable I
    image create photo spritesheet -file $imgfile -format png
    foreach {name x y width height} $::spriteinfo {
      set I($name) [image create photo -width $width -height $height]
      $I($name) copy spritesheet -from $x $y [expr {$x+$width}] [expr {$y+$height}]
    }
    image delete spritesheet
  }

  load_images [file join [file dirname [info script]] spritesheet_light[::sv_ttk::suffix].png]

  ttk::style theme create sun-valley-light -parent clam -settings {
        
    # Button
    ttk::style layout TButton {
      Button.button -children {
        Button.padding -children {
          Button.label -side left -expand 1
        } 
      }
    }

    ttk::style configure TButton -padding [::sv_ttk::px {8 2 8 3}] -anchor center -foreground $colors(-fg)
    ttk::style map TButton -foreground [list disabled "#a3a1a5" pressed "#63616d" active "#1d1b24"]
    
    ttk::style element create Button.button image \
      [list $I(button-rest) \
        {selected disabled} $I(button-dis) \
        disabled $I(button-dis) \
        selected $I(button-rest) \
        pressed $I(button-pressed) \
        {active focus} $I(button-focus-hover) \
        active $I(button-hover) \
        focus $I(button-focus) \
      ] -border [::sv_ttk::px 4] -sticky nsew

    # Toolbutton
    ttk::style layout Toolbutton {
      Toolbutton.button -children {
        Toolbutton.padding -children {
          Toolbutton.label -side left -expand 1
        } 
      }
    }

    ttk::style configure Toolbutton -padding [::sv_ttk::px {8 2 8 3}] -anchor center
    
    ttk::style element create Toolbutton.button image \
      [list $I(empty) \
        disabled $I(button-dis) \
        pressed $I(button-pressed) \
        {active focus} $I(button-focus-hover) \
        active $I(button-hover) \
        focus $I(button-focus) \
      ] -border [::sv_ttk::px 4] -sticky nsew

    # Accent.TButton
    ttk::style layout Accent.TButton {
      AccentButton.button -children {
        AccentButton.padding -children {
          AccentButton.label -side left -expand 1
        } 
      }
    }

    ttk::style configure Accent.TButton -padding [::sv_ttk::px {8 2 8 3}] -anchor center -foreground "#faf9f7"
    ttk::style map Accent.TButton -foreground [list pressed "#dcdafa" disabled "#ffffff"]

    ttk::style element create AccentButton.button image \
      [list $I(button-accent-rest) \
        {selected disabled} $I(button-accent-dis) \
        disabled $I(button-accent-dis) \
        selected $I(button-accent-rest) \
        pressed $I(button-accent-pressed) \
        {active focus} $I(button-accent-focus-hover) \
        active $I(button-accent-hover) \
        focus $I(button-accent-focus) \
      ] -border [::sv_ttk::px 4] -sticky nsew

    # Menubutton
    ttk::style layout TMenubutton {
      Menubutton.button -children {
        Menubutton.padding -children {
          Menubutton.label -side left -expand 1
          Menubutton.indicator -side right -sticky nsew
        }
      }
    }

    ttk::style configure TMenubutton -padding [::sv_ttk::px {8 2 13 3}]

    ttk::style element create Menubutton.button image \
      [list $I(button-rest) \
        disabled $I(button-dis) \
        pressed $I(button-pressed) \
        {active focus} $I(button-focus-hover) \
        active $I(button-hover) \
        focus $I(button-focus) \
      ] -border [::sv_ttk::px 4] -sticky nsew 

    ttk::style element create Menubutton.indicator image $I(down) -width [::sv_ttk::px 10] -sticky e

    # OptionMenu
    ttk::style layout TOptionMenu {
      OptionMenu.button -children {
        OptionMenu.padding -children {
          OptionMenu.label -side left -expand 1
          OptionMenu.indicator -side right -sticky nsew
        }
      }
    }
    
    ttk::style configure TOptionMenu -padding [::sv_ttk::px {8 2 13 3}]

    ttk::style element create OptionMenu.button image \
      [list $I(button-rest) \
        disabled $I(button-dis) \
        pressed $I(button-pressed) \
        {active focus} $I(button-focus-hover) \
        active $I(button-hover) \
        focus $I(button-focus) \
      ] -border [::sv_ttk::px 4] -sticky nsew 

    ttk::style element create OptionMenu.indicator image $I(down) -width [::sv_ttk::px 10] -sticky e

    # Checkbutton
    ttk::style layout TCheckbutton {
      Checkbutton.button -children {
        Checkbutton.padding -children {
          Checkbutton.indicator -side left
          Checkbutton.label -side right -expand 1
        }
      }
    }

    ttk::style configure TCheckbutton -padding [::sv_ttk::px 4]

    ttk::style element create Checkbutton.indicator image \
      [list $I(check-unsel-rest) \
        {alternate disabled} $I(check-tri-dis) \
        {selected disabled} $I(check-dis) \
        disabled $I(check-unsel-dis) \
        {pressed alternate} $I(check-tri-hover) \
        {active focus alternate} $I(check-tri-focus-hover) \
        {active alternate} $I(check-tri-hover) \
        {focus alternate} $I(check-tri-focus) \
        alternate $I(check-tri-rest) \
        {pressed selected} $I(check-hover) \
        {active focus selected} $I(check-focus-hover) \
        {active selected} $I(check-hover) \
        {focus selected} $I(check-focus) \
        selected $I(check-rest) \
        {pressed !selected} $I(check-unsel-pressed) \
        {active focus} $I(check-unsel-focus-hover) \
        active $I(check-unsel-hover) \
        focus $I(check-unsel-focus) \
      ] -width [::sv_ttk::px 26] -sticky w

    # Switch.TCheckbutton
    ttk::style layout Switch.TCheckbutton {
      Switch.button -children {
        Switch.padding -children {
          Switch.indicator -side left
          Switch.label -side right -expand 1
        }
      }
    }

    ttk::style element create Switch.indicator image \
      [list $I(switch-off-rest) \
        {selected disabled} $I(switch-dis) \
        disabled $I(switch-off-dis) \
        {pressed selected} $I(switch-pressed) \
        {active focus selected} $I(switch-focus-hover) \
        {active selected} $I(switch-hover) \
        {focus selected} $I(switch-focus) \
        selected $I(switch-rest) \
        {pressed !selected} $I(switch-off-pressed) \
        {active focus} $I(switch-off-focus-hover) \
        active $I(switch-off-hover) \
        focus $I(switch-off-focus) \
      ] -width [::sv_ttk::px 46] -sticky w

    # Toggle.TButton
    ttk::style layout Toggle.TButton {
      ToggleButton.button -children {
        ToggleButton.padding -children {
          ToggleButton.label -side left -expand 1
        } 
      }
    }

    ttk::style configure Toggle.TButton -padding [::sv_ttk::px {8 2 8 3}] -anchor center -foreground $colors(-fg)

    ttk::style map Toggle.TButton -foreground \
      [list {selected disabled} "#ffffff" \
        {selected pressed} "#63616d" \
        selected "#faf9f7" \
        pressed "#dcdafa" \
        disabled "#a3a1a5" \
        active "#1d1b24"
      ]

    ttk::style element create ToggleButton.button image \
      [list $I(button-rest) \
        {selected disabled} $I(button-accent-dis) \
        disabled $I(button-dis) \
        {pressed selected} $I(button-rest) \
        {active focus selected} $I(button-accent-focus-hover) \
        {active selected} $I(button-accent-hover) \
        {focus selected} $I(button-accent-focus) \
        selected $I(button-accent-rest) \
        {pressed !selected} $I(button-accent-rest) \
        {active focus} $I(button-focus-hover) \
        active $I(button-hover) \
        focus $I(button-focus) \
      ] -border [::sv_ttk::px 4] -sticky nsew

    # Radiobutton
    ttk::style layout TRadiobutton {
      Radiobutton.button -children {
        Radiobutton.padding -children {
          Radiobutton.indicator -side left
          Radiobutton.label -side right -expand 1
        }
      }
    }

    ttk::style configure TRadiobutton -padding [::sv_ttk::px 4]

    ttk::style element create Radiobutton.indicator image \
      [list $I(radio-unsel-rest) \
        {selected disabled} $I(radio-dis) \
        disabled $I(radio-unsel-dis) \
        {pressed selected} $I(radio-pressed) \
        {active focus selected} $I(radio-focus-hover) \
        {active selected} $I(radio-hover) \
        {focus selected} $I(radio-focus) \
        selected $I(radio-rest) \
        {pressed !selected} $I(radio-unsel-pressed) \
        {active focus} $I(radio-unsel-focus-hover) \
        active $I(radio-unsel-hover) \
        focus $I(radio-unsel-focus) \
      ] -width [::sv_ttk::px 26] -sticky w

    # Entry
    ttk::style configure TEntry -foreground $colors(-fg) -padding [::sv_ttk::px {6 1 4 2}]
    ttk::style map TEntry -foreground [list disabled $colors(-disfg) pressed "#63616d" active "#62606c"]

    ttk::style element create Entry.field image \
      [list $I(textbox-rest) \
        {focus hover !invalid} $I(textbox-focus) \
        invalid $I(textbox-error) \
        disabled $I(textbox-dis) \
        {focus !invalid} $I(textbox-focus) \
        hover $I(textbox-hover) \
      ] -border [::sv_ttk::px 5] -sticky nsew

    # Combobox
    ttk::style layout TCombobox {
      Combobox.field -sticky nsew -children {
        Combobox.arrow -side right -sticky ns
        Combobox.padding -sticky nsew -children {
          Combobox.textarea -sticky nsew
        }
      }
    }

    ttk::style configure TCombobox -foreground $colors(-fg) -padding [::sv_ttk::px {6 1 0 2}]
    ttk::style configure ComboboxPopdownFrame -borderwidth 1 -relief solid
    ttk::style map TCombobox -foreground [list disabled $colors(-disfg) pressed "#63616d" active "#62606c"]
    
    ttk::style map TCombobox -selectbackground [list \
      {readonly hover} $colors(-selbg) \
      {readonly focus} $colors(-selbg) \
    ] -selectforeground [list \
      {readonly hover} $colors(-selfg) \
      {readonly focus} $colors(-selfg) \
    ]

    ttk::style element create Combobox.field image \
      [list $I(textbox-rest) \
        {readonly focus} $I(button-focus) \
        {readonly disabled} $I(button-dis) \
        {readonly pressed} $I(button-pressed) \
        {readonly hover} $I(button-hover) \
        readonly $I(button-rest) \
        {focus hover !invalid} $I(textbox-focus) \
        invalid $I(textbox-error) \
        disabled $I(textbox-dis) \
        focus $I(textbox-focus) \
        {focus !invalid} $I(textbox-focus) \
        hover $I(textbox-hover) \
      ] -border [::sv_ttk::px 5]

    ttk::style element create Combobox.arrow image $I(down) -width [::sv_ttk::px 34] -sticky {}

    # Spinbox
    ttk::style layout TSpinbox {
      Spinbox.field -side top -sticky we -children {
        Spinbox.downarrow -side right -sticky ns
        Spinbox.uparrow -side right -sticky ns
        Spinbox.padding -sticky nswe -children {
          Spinbox.textarea -sticky nsew
        }
      }
    }

    ttk::style configure TSpinbox -foreground $colors(-fg) -padding [::sv_ttk::px {6 1 0 2}]
    ttk::style map TSpinbox -foreground [list disabled $colors(-disfg) pressed "#63616d" active "#62606c"]

    ttk::style element create Spinbox.field image \
      [list $I(textbox-rest) \
        {focus hover !invalid} $I(textbox-focus) \
        invalid $I(textbox-error) \
        disabled $I(textbox-dis) \
        focus $I(textbox-focus) \
        {focus !invalid} $I(textbox-focus) \
        hover $I(textbox-hover) \
      ] -border [::sv_ttk::px 5] -sticky nsew

    ttk::style element create Spinbox.uparrow image $I(up) -width [::sv_ttk::px 34] -height [::sv_ttk::px 16] -sticky {}
    ttk::style element create Spinbox.downarrow image $I(down) -width [::sv_ttk::px 34] -height [::sv_ttk::px 16] -sticky {}

    # Progressbar
    ttk::style element create Horizontal.Progressbar.trough image $I(progressbar-trough-hor) \
      -border [::sv_ttk::px 1] -sticky ew
    ttk::style element create Horizontal.Progressbar.pbar image $I(progressbar-bar-hor) \
      -border [::sv_ttk::px 2] -sticky ew

    ttk::style element create Vertical.Progressbar.trough image $I(progressbar-trough-vert) \
      -border [::sv_ttk::px 1] -sticky ns
    ttk::style element create Vertical.Progressbar.pbar image $I(progressbar-bar-vert) \
      -border [::sv_ttk::px 2] -sticky ns

    # Scale
    ttk::style element create Horizontal.Scale.trough image $I(slider-trough-hor) \
      -border [::sv_ttk::px 5] -padding [::sv_ttk::px 0] -sticky {ew}

    ttk::style element create Vertical.Scale.trough image $I(slider-trough-vert) \
      -border [::sv_ttk::px 5] -padding [::sv_ttk::px 0] -sticky {ns}

    ttk::style element create Scale.slider image \
      [list $I(slider-thumb-rest) \
        disabled $I(slider-thumb-dis) \
        pressed $I(slider-thumb-pressed) \
        {active focus} $I(slider-thumb-focus-hover) \
        active $I(slider-thumb-hover) \
        focus $I(slider-thumb-focus) \
      ] -sticky {}

    # Scrollbar
    ttk::style layout Vertical.TScrollbar {
      Vertical.Scrollbar.trough -sticky ns -children {
        Vertical.Scrollbar.uparrow -side top
        Vertical.Scrollbar.downarrow -side bottom
        Vertical.Scrollbar.thumb -expand 1
      }
    }

    ttk::style layout Horizontal.TScrollbar {
      Horizontal.Scrollbar.trough -sticky ew -children {
        Horizontal.Scrollbar.leftarrow -side left
        Horizontal.Scrollbar.rightarrow -side right
        Horizontal.Scrollbar.thumb -expand 1
      }
    }

    ttk::style element create Horizontal.Scrollbar.trough image $I(scrollbar-trough-hor) -sticky ew -border [::sv_ttk::px {6 0}]
    ttk::style element create Horizontal.Scrollbar.thumb image $I(scrollbar-thumb-hor) -sticky ew -border [::sv_ttk::px {3 0}]

    ttk::style element create Horizontal.Scrollbar.rightarrow image $I(scrollbar-right) -sticky e -width [::sv_ttk::px 13]
    ttk::style element create Horizontal.Scrollbar.leftarrow image $I(scrollbar-left) -sticky w -width [::sv_ttk::px 13]

    ttk::style element create Vertical.Scrollbar.trough image $I(scrollbar-trough-vert) -sticky ns -border [::sv_ttk::px {0 6}]
    ttk::style element create Vertical.Scrollbar.thumb image $I(scrollbar-thumb-vert) -sticky ns -border [::sv_ttk::px {0 3}]

    ttk::style element create Vertical.Scrollbar.uparrow image $I(scrollbar-up) -sticky n -height [::sv_ttk::px 13]
    ttk::style element create Vertical.Scrollbar.downarrow image $I(scrollbar-down) -sticky s -height [::sv_ttk::px 13]

    # Separator
    ttk::style element create Separator.separator image $I(sep) -width [::sv_ttk::px 1] -height [::sv_ttk::px 1]

    # Sizegrip
    ttk::style element create Sizegrip.sizegrip image $I(grip) -sticky nsew

    # Card
    ttk::style layout Card.TFrame {
      Card.field {
        Card.padding -expand 1 
      }
    }

    ttk::style element create Card.field image $I(card) -border [::sv_ttk::px 10] -padding [::sv_ttk::px 4] -sticky nsew

    # Labelframe
    ttk::style layout TLabelframe {
      Labelframe.border {
        Labelframe.padding -expand 1 -children {
          Labelframe.label -side left
        }
      }
    }

    ttk::style element create Labelframe.border image $I(card) -border [::sv_ttk::px 5] -padding [::sv_ttk::px 4] -sticky nsew
    ttk::style configure TLabelframe.Label -font SunValleyCaptionFont

    # Notebook
    ttk::style layout TNotebook {
      Notebook.border -children {
        TNotebook.Tab -expand 1
      }
    }

    ttk::style configure TNotebook -padding [::sv_ttk::px 1]
    ttk::style configure TNotebook.Tab -focuscolor $colors(-accent)
    ttk::style element create Notebook.border image $I(notebook-border) -border [::sv_ttk::px 5] -padding [::sv_ttk::px 5]

    ttk::style element create Notebook.tab image \
      [list $I(tab-rest) \
        selected $I(tab-selected) \
        active $I(tab-hover) \
      ] -border [::sv_ttk::px 13] -padding [::sv_ttk::px {16 14 16 6}] -height [::sv_ttk::px 32]

    # Treeview
    ttk::style configure Heading -font SunValleyCaptionFont
    ttk::style configure Treeview \
        -background $colors(-bg) \
        -rowheight [expr {[font metrics SunValleyBodyFont -linespace] + [::sv_ttk::px 3]}] \
        -font SunValleyBodyFont

    ttk::style map Treeview -background {selected "#e8e7e3"} -foreground {selected "#1c1a22"}

    ttk::style element create Treeview.field image $I(card) -border [::sv_ttk::px 5] -width [::sv_ttk::px 0] -height [::sv_ttk::px 0]
    ttk::style element create Treeheading.cell image \
      [list $I(heading-rest) \
        pressed $I(heading-pressed) \
        active $I(heading-hover)
      ] -border [::sv_ttk::px 5] -padding [::sv_ttk::px 14] -sticky nsew
    
    if {[package vsatisfies [package provide Tk] 9-]} {
      # Tk 9 no longer exposes the open/leaf item states, so use its drawn arrow
      ttk::style configure Item -foreground $colors(-fg) \
        -indicatorsize [::sv_ttk::px 9] -indicatormargins [::sv_ttk::px {8 0 9 0}]
      ttk::style map Item -foreground [ttk::style map Treeview -foreground]
    } else {
      ttk::style element create Treeitem.indicator image \
        [list $I(right) \
          user2 $I(empty) \
          user1 $I(down) \
        ] -width [::sv_ttk::px 26] -sticky {}
    }

    # Panedwindow
    ttk::style configure Sash \
      -lightcolor "#676571" \
      -darkcolor "#676571" \
      -bordercolor "#676571" \
      -sashthickness [::sv_ttk::px 4] \
      -gripcount 20
  }
}
