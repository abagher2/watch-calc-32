import SwiftUI

enum ThemeType: String, CaseIterable, Identifiable {
    case beta = "Beta"
    case pioneerBrown = "Pioneer Brown"
    case pioneerPurpleGreen = "Pioneer Purple/Green"
    case modern = "Modern"
    case retro = "Retro (Pixel LCD)"
    
    var id: String { self.rawValue }
}

protocol AppTheme {
    var chassisColor: Color { get }
    var digitKeyColor: Color { get }
    var functionKeyColor: Color { get }
    var digitTextColor: Color { get }
    var functionTextColor: Color { get }
    
    var yellowShiftColor: Color { get }
    var blueShiftColor: Color { get }
    
    var shift1Label: LocalizedStringKey { get }
    var shift2Label: LocalizedStringKey { get }
    
    var backspaceLabel: LocalizedStringKey { get }
    
    var lcdBackgroundColor: Color { get }
    var lcdTextColor: Color { get }
    
    var isDarkChassis: Bool { get }
}

struct BetaTheme: AppTheme {
    var chassisColor: Color = Color.clear
    var digitKeyColor: Color = Color.primary.opacity(0.1)
    var functionKeyColor: Color = Color.primary.opacity(0.15)
    var digitTextColor: Color = .primary
    var functionTextColor: Color = .primary
    
    var yellowShiftColor: Color = Color.orange
    var blueShiftColor: Color = Color.cyan
    
    var shift1Label: LocalizedStringKey = "\(Image(systemName: "arrow.turn.up.left"))"
    var shift2Label: LocalizedStringKey = "\(Image(systemName: "arrow.turn.up.right"))"
    var backspaceLabel: LocalizedStringKey = "\(Image(systemName: "delete.left.fill"))"
    
    var lcdBackgroundColor: Color = Color.primary.opacity(0.05)
    var lcdTextColor: Color = .primary
    
    var isDarkChassis: Bool = false
}

struct PioneerBrownTheme: AppTheme {
    var chassisColor: Color = Color(red: 0.32, green: 0.28, blue: 0.25) // Warm brown/grey chassis
    var digitKeyColor: Color = Color(white: 0.18) // Dark plastic keys
    var functionKeyColor: Color = Color(white: 0.18)
    var digitTextColor: Color = .white
    var functionTextColor: Color = .white
    
    var yellowShiftColor: Color = Color(red: 0.95, green: 0.55, blue: 0.1) // HP Orange
    var blueShiftColor: Color = Color(red: 0.2, green: 0.6, blue: 0.8) // HP Light Blue
    
    var shift1Label: LocalizedStringKey = "\(Image(systemName: "arrow.turn.up.left"))"
    var shift2Label: LocalizedStringKey = "\(Image(systemName: "arrow.turn.up.right"))"
    var backspaceLabel: LocalizedStringKey = "\(Image(systemName: "arrow.left"))"
    
    var lcdBackgroundColor: Color = Color(red: 0.6, green: 0.65, blue: 0.55) // Greenish LCD
#if os(watchOS)
    var lcdTextColor: Color = .white
#else
    var lcdTextColor: Color = .black
#endif
    
    var isDarkChassis: Bool = true
}

struct PioneerPurpleGreenTheme: AppTheme {
    var chassisColor: Color = Color(white: 0.2) // Dark grey chassis
    var digitKeyColor: Color = Color(white: 0.15)
    var functionKeyColor: Color = Color(white: 0.15)
    var digitTextColor: Color = .white
    var functionTextColor: Color = .white
    
    var yellowShiftColor: Color = Color(red: 0.7, green: 0.2, blue: 0.6) // True Violet/Purple
    var blueShiftColor: Color = Color(red: 0.2, green: 0.8, blue: 0.4) // Mint Green
    
    var shift1Label: LocalizedStringKey = "\(Image(systemName: "arrow.turn.up.left"))"
    var shift2Label: LocalizedStringKey = "\(Image(systemName: "arrow.turn.up.right"))"
    var backspaceLabel: LocalizedStringKey = "\(Image(systemName: "arrow.left"))"
    
    var lcdBackgroundColor: Color = Color(red: 0.6, green: 0.65, blue: 0.55)
#if os(watchOS)
    var lcdTextColor: Color = .white
#else
    var lcdTextColor: Color = .black
#endif
    
    var isDarkChassis: Bool = true
}

struct DM32Theme: AppTheme {
    var chassisColor: Color = Color(red: 0.08, green: 0.08, blue: 0.08) // Deep matte black
    var digitKeyColor: Color = Color(white: 0.15)
    var functionKeyColor: Color = Color(white: 0.15)
    var digitTextColor: Color = .white
    var functionTextColor: Color = .white
    
    var yellowShiftColor: Color = Color(red: 0.98, green: 0.6, blue: 0.1) // Bold DM Orange
    var blueShiftColor: Color = Color(red: 0.3, green: 0.65, blue: 0.9) // Bright Blue
    
    var shift1Label: LocalizedStringKey = ""
    var shift2Label: LocalizedStringKey = ""
    var backspaceLabel: LocalizedStringKey = "\(Image(systemName: "arrow.left"))"
    
    var lcdBackgroundColor: Color = Color(red: 0.7, green: 0.75, blue: 0.7) // LCD
#if os(watchOS)
    var lcdTextColor: Color = .white
#else
    var lcdTextColor: Color = .black
#endif
    
    var isDarkChassis: Bool = true
}

struct RetroTheme: AppTheme {
    var chassisColor: Color = Color.black
    var digitKeyColor: Color = Color.white.opacity(0.1)
    var functionKeyColor: Color = Color.white.opacity(0.15)
    var digitTextColor: Color = .white
    var functionTextColor: Color = .white
    
    var yellowShiftColor: Color = Color.orange
    var blueShiftColor: Color = Color.cyan
    
    var shift1Label: LocalizedStringKey = "\(Image(systemName: "arrow.turn.up.left"))"
    var shift2Label: LocalizedStringKey = "\(Image(systemName: "arrow.turn.up.right"))"
    var backspaceLabel: LocalizedStringKey = "\(Image(systemName: "delete.left.fill"))"
    
    var lcdBackgroundColor: Color = Color(red: 0.61, green: 0.68, blue: 0.56)
    var lcdTextColor: Color = Color(red: 0.1, green: 0.12, blue: 0.1)
    
    var isDarkChassis: Bool = true
}

class ThemeManager: ObservableObject {
    @Published var activeThemeType: ThemeType = {
        if let themeString = UserDefaults.standard.string(forKey: "ForceTheme"), let theme = ThemeType(rawValue: themeString) {
            return theme
        }
        return .beta
    }()
    
    var theme: AppTheme {
        switch activeThemeType {
        case .beta: return BetaTheme()
        case .pioneerBrown: return PioneerBrownTheme()
        case .pioneerPurpleGreen: return PioneerPurpleGreenTheme()
        case .modern: return DM32Theme()
        case .retro: return RetroTheme()
        }
    }
}

