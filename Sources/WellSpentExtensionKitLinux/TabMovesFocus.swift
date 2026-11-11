#if canImport(SwiftCrossUI)
import Gtk
import GtkBackend
import SwiftCrossUI
import WellSpentExtensionKitLinuxNative

public extension View {
    /// Tab and Shift+Tab move between the controls of the window the view is
    /// in, as they do in the main window. For a sheet's content: in
    /// SwiftCrossUI 0.10.0 a sheet's window lets no Tab through, so a person
    /// can't reach the second control from the first by the keyboard. Any
    /// view in the sheet will do, since it's the window that listens.
    ///
    /// The window takes Tab before any control sees it. So a control that
    /// wants Tab for itself, such as a text box of several lines, never gets
    /// it. No sheet has one today.
    func tabMovesFocus() -> some View {
        inspect([.onCreate, .afterUpdate]) { (widget: Gtk.Widget) in
            wellspent_kit_tab_moves_focus(widget.widgetPointer)
        }
    }
}
#endif
