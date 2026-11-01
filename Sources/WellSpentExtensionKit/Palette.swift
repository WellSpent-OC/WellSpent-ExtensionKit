#if canImport(SwiftUI)
import SwiftUI

/// The colours from `PaletteValues`, ready for SwiftUI. On a phone each one
/// follows the device's light or dark setting.
public enum Palette {
    public static let ground = Color(PaletteValues.ground)
    public static let surface = Color(PaletteValues.surface)
    public static let sidebar = Color(PaletteValues.sidebar)
    public static let ink = Color(PaletteValues.ink)
    public static let muted = Color(PaletteValues.muted)
    public static let line = Color(PaletteValues.line)
    public static let track = Color(PaletteValues.track)
    public static let accent = Color(PaletteValues.accent)
    public static let warning = Color(PaletteValues.warning)
    public static let blue = Color(PaletteValues.blue)

    /// The same values as `PaletteValues.budgetColors`, made once, so a budget
    /// keeps the very colour its index names.
    private static let budgetColors = [accent, blue, Color(PaletteValues.purple), warning]

    public static func budgetColor(_ index: Int) -> Color {
        budgetColors[abs(index) % budgetColors.count]
    }
}

extension Color {
    /// On a phone, the pair's light value in light mode and its dark value in
    /// dark mode. The system picks one each time it draws, so a change of
    /// setting shows at once. The Mac draws the light value in both, until
    /// dark mode is placed in a Mac build.
    public init(_ pair: ColorPair) {
        #if os(macOS)
        self.init(red: pair.light.red, green: pair.light.green, blue: pair.light.blue)
        #else
        self.init(uiColor: UIColor { traits in
            let rgb = traits.userInterfaceStyle == .dark ? pair.dark : pair.light
            return UIColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: 1)
        })
        #endif
    }
}

extension Font {
    /// Tabular figures, so columns of money line up.
    public static func money(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}
#endif
