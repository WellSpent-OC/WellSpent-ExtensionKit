// GTK's accessibility calls for an extension's Linux screens. Each takes a
// GtkWidget as a plain pointer, so Swift can pass SwiftCrossUI's widget. Linux
// only; on the Mac and iPhone this header declares nothing.
#ifndef WELLSPENT_KIT_LINUX_H
#define WELLSPENT_KIT_LINUX_H
#if defined(__linux__)

/// What a screen reader names `widget` (a GtkWidget), in place of what it
/// shows: for a widget whose look carries its meaning, such as an arrow.
void wellspent_accessible_set_label(void *widget, const char *label);

/// What a screen reader says after the widget's name, such as how much of a
/// budget is used.
void wellspent_accessible_set_description(void *widget, const char *description);

/// Whether a screen reader hears the widget as the one picked, such as the
/// open budget's row. 1 for picked, 0 for not.
void wellspent_accessible_set_selected(void *widget, int selected);

/// The four arrows of the GTK calendar inside `widget` (a GtkWidget): names
/// them, since GTK leaves them unnamed and a screen reader hears four plain
/// buttons, in the order GTK shows them (the month back and on, then the
/// year back and on). A move by them chooses the day the calendar then shows
/// chosen, as a click on a day does. And the arrow keys move the chosen day
/// by a day or a week, as on the Mac. Call after every update.
void wellspent_calendar_arrows(void *widget, const char *previous_month, const char *next_month,
                               const char *previous_year, const char *next_year);

/// The accessible name of the control inside a composite view, such as a
/// checkbox Toggle or a Picker, whose own widget is an anonymous container.
void wellspent_control_label(void *widget, const char *label);
/// The accessible description of the control inside a composite view, with
/// GTK's own name for it kept, such as a list's chosen option.
void wellspent_control_description(void *widget, const char *description);

/// Tab and Shift+Tab move the keyboard between the controls of the window that
/// holds `widget` (a GtkWidget), once it is in one. For a sheet, whose window
/// lets no Tab through in SwiftCrossUI 0.10.0. Once per window is enough; more
/// calls change nothing.
void wellspent_kit_tab_moves_focus(void *widget);

#endif
#endif
