// Tab in a sheet, for an extension's Linux screens. Linux only; on the Mac
// and iPhone this file is empty.
#if defined(__linux__)
#include "wellspent_kit_linux.h"
#include <gtk/gtk.h>

// SwiftCrossUI 0.10.0 gives each sheet's window an Escape listener whose key
// handler is declared returning nothing, where GTK's "key-pressed" returns
// whether the key was handled. GTK reads what is left in the register, so
// every key reaching it counts as handled, and Tab never gets to GTK's own
// focus movement. This handler runs first, in the capture phase, moves focus
// as GtkWindow's own Tab does, and lets every other key go on.
static gboolean move_focus_on_tab(GtkEventControllerKey *controller, guint keyval, guint keycode,
                                  GdkModifierType state, gpointer data) {
    (void)keycode;
    (void)data;
    gboolean tab = keyval == GDK_KEY_Tab || keyval == GDK_KEY_KP_Tab || keyval == GDK_KEY_ISO_Left_Tab;
    if (!tab) return FALSE;
    GtkDirectionType direction = (keyval == GDK_KEY_ISO_Left_Tab || (state & GDK_SHIFT_MASK))
        ? GTK_DIR_TAB_BACKWARD : GTK_DIR_TAB_FORWARD;
    GtkWidget *window = gtk_event_controller_get_widget(GTK_EVENT_CONTROLLER(controller));
    // Past the last control, round to the first, as GtkWindow does.
    if (!gtk_widget_child_focus(window, direction)) {
        gtk_window_set_focus(GTK_WINDOW(window), NULL);
        gtk_widget_child_focus(window, direction);
    }
    return TRUE;
}

// The same mark the app's own copy sets, so a window never gets two handlers.
static void add_tab_handler(GtkWidget *widget) {
    GtkRoot *root = gtk_widget_get_root(widget);
    if (!root || !GTK_IS_WINDOW(root)) return;
    if (g_object_get_data(G_OBJECT(root), "wellspent-tab-moves-focus")) return;
    GtkEventController *keys = gtk_event_controller_key_new();
    gtk_event_controller_set_propagation_phase(keys, GTK_PHASE_CAPTURE);
    g_signal_connect(keys, "key-pressed", G_CALLBACK(move_focus_on_tab), NULL);
    gtk_widget_add_controller(GTK_WIDGET(root), keys);
    g_object_set_data(G_OBJECT(root), "wellspent-tab-moves-focus", GINT_TO_POINTER(1));
}

static void add_tab_handler_on_realize(GtkWidget *widget, gpointer data) {
    (void)data;
    add_tab_handler(widget);
}

void wellspent_kit_tab_moves_focus(void *widget) {
    if (!GTK_IS_WIDGET(widget)) return;
    // A view not yet in its window has no window to listen on, so it waits
    // until it is.
    if (gtk_widget_get_root(GTK_WIDGET(widget))) {
        add_tab_handler(GTK_WIDGET(widget));
    } else {
        g_signal_connect(widget, "realize", G_CALLBACK(add_tab_handler_on_realize), NULL);
    }
}

#endif
