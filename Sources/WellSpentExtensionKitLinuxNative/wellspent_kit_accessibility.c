// GTK's accessibility calls for an extension's Linux screens: what a screen
// reader names a widget, what it says after the name, and whether it's the
// one picked. Linux only; on the Mac and iPhone this file is empty.
#if defined(__linux__)
#include "wellspent_kit_linux.h"
#include <gtk/gtk.h>

void wellspent_accessible_set_label(void *widget, const char *label) {
    if (!GTK_IS_ACCESSIBLE(widget) || !label) return;
    gtk_accessible_update_property(GTK_ACCESSIBLE(widget), GTK_ACCESSIBLE_PROPERTY_LABEL, label, -1);
}

void wellspent_accessible_set_description(void *widget, const char *description) {
    if (!GTK_IS_ACCESSIBLE(widget) || !description) return;
    gtk_accessible_update_property(GTK_ACCESSIBLE(widget), GTK_ACCESSIBLE_PROPERTY_DESCRIPTION, description, -1);
}

void wellspent_accessible_set_selected(void *widget, int selected) {
    if (!GTK_IS_ACCESSIBLE(widget)) return;
    gtk_accessible_update_state(GTK_ACCESSIBLE(widget), GTK_ACCESSIBLE_STATE_SELECTED, selected ? TRUE : FALSE, -1);
}

static GtkWidget *find_calendar(GtkWidget *widget) {
    if (GTK_IS_CALENDAR(widget)) return widget;
    for (GtkWidget *child = gtk_widget_get_first_child(widget); child; child = gtk_widget_get_next_sibling(child)) {
        GtkWidget *found = find_calendar(child);
        if (found) return found;
    }
    return NULL;
}

static void collect_buttons(GtkWidget *widget, GtkWidget **buttons, int *count) {
    for (GtkWidget *child = gtk_widget_get_first_child(widget); child && *count < 4;
         child = gtk_widget_get_next_sibling(child)) {
        if (GTK_IS_BUTTON(child))
            buttons[(*count)++] = child;
        else
            collect_buttons(child, buttons, count);
    }
}

static void arrow_moved(GtkCalendar *calendar, gpointer data) {
    (void)data;
    g_signal_emit_by_name(calendar, "day-selected");
}

// The arrow keys on a calendar move its chosen day by a day or a week. GTK's
// own move only a box drawn around a day, which nothing reads aloud, and the
// first press jumps to the grid's last box, often in another month. With
// Control, GTK's own: the month and the year.
static gboolean move_day_by_key(GtkEventControllerKey *controller, guint keyval, guint keycode,
                                GdkModifierType state, gpointer data) {
    (void)keycode;
    (void)data;
    if (state & (GDK_CONTROL_MASK | GDK_ALT_MASK)) return FALSE;
    int days;
    switch (keyval) {
    case GDK_KEY_Left: case GDK_KEY_KP_Left: days = -1; break;
    case GDK_KEY_Right: case GDK_KEY_KP_Right: days = 1; break;
    case GDK_KEY_Up: case GDK_KEY_KP_Up: days = -7; break;
    case GDK_KEY_Down: case GDK_KEY_KP_Down: days = 7; break;
    default: return FALSE;
    }
    GtkCalendar *calendar = GTK_CALENDAR(gtk_event_controller_get_widget(GTK_EVENT_CONTROLLER(controller)));
    GDateTime *date = gtk_calendar_get_date(calendar);
    GDateTime *moved = g_date_time_add_days(date, days);
    gtk_calendar_select_day(calendar, moved);
    g_date_time_unref(moved);
    g_date_time_unref(date);
    g_signal_emit_by_name(calendar, "day-selected");
    return TRUE;
}

void wellspent_calendar_arrows(void *widget, const char *previous_month, const char *next_month,
                               const char *previous_year, const char *next_year) {
    if (!GTK_IS_WIDGET(widget)) return;
    GtkWidget *calendar = find_calendar(GTK_WIDGET(widget));
    if (!calendar) return;
    // GTK 4 lays its calendar's header out as < month > < year >.
    GtkWidget *buttons[4];
    int count = 0;
    collect_buttons(calendar, buttons, &count);
    if (count == 4) {
        const char *names[4] = { previous_month, next_month, previous_year, next_year };
        for (int i = 0; i < 4; i++)
            wellspent_accessible_set_label(buttons[i], names[i]);
    }
    // An arrow moves the chosen day to the next or last month or year, and
    // shows it chosen, but GTK says "day-selected" only for a day clicked.
    // Said here too, so what's saved is the day the calendar shows. Once.
    if (g_object_get_data(G_OBJECT(calendar), "wellspent-arrows")) return;
    g_object_set_data(G_OBJECT(calendar), "wellspent-arrows", GINT_TO_POINTER(1));
    const char *moves[] = { "prev-month", "next-month", "prev-year", "next-year" };
    for (int i = 0; i < 4; i++)
        g_signal_connect(calendar, moves[i], G_CALLBACK(arrow_moved), NULL);
    // Before GTK's own handling of the keys, which this replaces for the
    // plain arrows.
    GtkEventController *keys = gtk_event_controller_key_new();
    gtk_event_controller_set_propagation_phase(keys, GTK_PHASE_CAPTURE);
    g_signal_connect(keys, "key-pressed", G_CALLBACK(move_day_by_key), NULL);
    gtk_widget_add_controller(calendar, keys);
}

static GtkWidget *named_control(GtkWidget *widget) {
    if (GTK_IS_DROP_DOWN(widget) || GTK_IS_CHECK_BUTTON(widget)) return widget;
    for (GtkWidget *child = gtk_widget_get_first_child(widget); child; child = gtk_widget_get_next_sibling(child)) {
        GtkWidget *found = named_control(child);
        if (found) return found;
    }
    return NULL;
}
static gboolean label_control_idle(gpointer widget) {
    g_object_set_data(G_OBJECT(widget), "wellspent-label-pending", NULL);
    GtkWidget *control = named_control(GTK_WIDGET(widget));
    const char *label = g_object_get_data(G_OBJECT(widget), "wellspent-control-label");
    const char *description = g_object_get_data(G_OBJECT(widget), "wellspent-control-description");
    if (control && label) gtk_accessible_update_property(GTK_ACCESSIBLE(control),
        GTK_ACCESSIBLE_PROPERTY_LABEL, label, GTK_ACCESSIBLE_PROPERTY_DESCRIPTION, label, -1);
    // A description alone keeps GTK's own name for the control, such as a
    // list's chosen option, and says what the control is for after it.
    if (control && description && !label) gtk_accessible_update_property(GTK_ACCESSIBLE(control),
        GTK_ACCESSIBLE_PROPERTY_DESCRIPTION, description, -1);
    return G_SOURCE_REMOVE;
}
void wellspent_control_label(void *widget, const char *label) {
    if (!GTK_IS_WIDGET(widget)) return;
    // SwiftCrossUI's Picker and checkbox Toggle are composite views. Name the
    // actual control rather than the surrounding anonymous layout container.
    g_object_set_data_full(G_OBJECT(widget), "wellspent-control-label", g_strdup(label), g_free);
    // Composite children can be attached after the inspection callback.
    if (!g_object_get_data(G_OBJECT(widget), "wellspent-label-pending")) {
        g_object_set_data(G_OBJECT(widget), "wellspent-label-pending", GINT_TO_POINTER(1));
        g_idle_add_full(G_PRIORITY_DEFAULT_IDLE, label_control_idle, g_object_ref(widget), g_object_unref);
    }
}

void wellspent_control_description(void *widget, const char *description) {
    if (!GTK_IS_WIDGET(widget)) return;
    g_object_set_data_full(G_OBJECT(widget), "wellspent-control-description", g_strdup(description), g_free);
    if (!g_object_get_data(G_OBJECT(widget), "wellspent-label-pending")) {
        g_object_set_data(G_OBJECT(widget), "wellspent-label-pending", GINT_TO_POINTER(1));
        g_idle_add_full(G_PRIORITY_DEFAULT_IDLE, label_control_idle, g_object_ref(widget), g_object_unref);
    }
}
#endif
