import SwiftUI
import RPNCore

struct PioneerButtonStyle: ButtonStyle {
    var isDigit: Bool
    var theme: AppTheme
    var textColor: Color? = nil
    
    var topLeadingRadius: CGFloat = 6
    var topTrailingRadius: CGFloat = 6
    var bottomLeadingRadius: CGFloat = 6
    var bottomTrailingRadius: CGFloat = 6
    var fontSize: CGFloat = 14

    func makeBody(configuration: Configuration) -> some View {
        let bgColor = isDigit ? theme.digitKeyColor : theme.functionKeyColor
        let baseFgColor = isDigit ? theme.digitTextColor : theme.functionTextColor
        let fgColor = textColor ?? baseFgColor
        
        configuration.label
            .font(.system(size: fontSize, weight: .bold, design: .monospaced)) // Match shift label size
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        theme is BetaTheme ? 
                            AnyShapeStyle(configuration.isPressed ? bgColor.opacity(0.3) : bgColor.opacity(0.15)) :
                            AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [
                                configuration.isPressed ? Color.black.opacity(0.3) : bgColor.opacity(0.8),
                                configuration.isPressed ? Color.black.opacity(0.5) : bgColor.opacity(0.5)
                            ]), startPoint: .top, endPoint: .bottom))
                    )
                    .background(
                        Group {
                            if theme is BetaTheme {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(.ultraThinMaterial)
                            }
                        }
                    )
                    .overlay(
                        Group {
                            if theme is BetaTheme {
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                            } else {
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.5), .clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom), lineWidth: 1.5)
                            }
                        }
                    )
                    .shadow(color: theme is BetaTheme ? .clear : Color.black.opacity(0.5), radius: theme is BetaTheme ? 0 : (configuration.isPressed ? 0 : 1.5), x: 0, y: theme is BetaTheme ? 0 : (configuration.isPressed ? 1 : 3))
            )
            .foregroundColor(fgColor)
            .overlay(
                RoundedRectangle(cornerRadius: 3).stroke(Color.white.opacity(0.15), lineWidth: 1) // subtle highlight
            )
            // Removed text shadow: .shadow(color: Color.black.opacity(0.8), radius: configuration.isPressed ? 0 : 1, x: 0, y: configuration.isPressed ? 0 : 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ShiftedPioneerButtonStyle: ButtonStyle {
    var yellow: String
    var blue: String
    var isDigit: Bool
    var isAlpha: Bool = false
    var theme: AppTheme
    var textColor: Color? = nil
    var activeShift: Int = 0
    
    var topLeadingRadius: CGFloat = 3
    var topTrailingRadius: CGFloat = 3
    var bottomLeadingRadius: CGFloat = 3
    var bottomTrailingRadius: CGFloat = 3
    var fontSize: CGFloat = 14

    func makeBody(configuration: Configuration) -> some View {
        let bgColor = theme is BetaTheme ? theme.digitKeyColor : (isDigit ? theme.digitKeyColor : theme.functionKeyColor)
        let baseFgColor = theme is BetaTheme ? theme.digitTextColor : (isDigit ? theme.digitTextColor : theme.functionTextColor)
        let fgColor = textColor ?? baseFgColor
        let displayFgColor = activeShift == 0 ? fgColor : fgColor.opacity(0.3)
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(yellow)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.yellowShiftColor.opacity(activeShift == 0 ? 1.0 : (activeShift == 1 ? 1.0 : 0.3)))
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text(blue)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(theme.blueShiftColor.opacity(activeShift == 0 ? 1.0 : (activeShift == 2 ? 1.0 : 0.3)))
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
            }
            .frame(height: 12)
            .opacity(yellow.isEmpty && blue.isEmpty ? 0 : 1)
            
            configuration.label
                .font(.system(size: fontSize, weight: .bold, design: .monospaced)) // Dynamic shift label size
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            theme is BetaTheme ? 
                                AnyShapeStyle(configuration.isPressed ? bgColor.opacity(0.3) : bgColor.opacity(0.15)) :
                                AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [
                                    configuration.isPressed ? Color.black.opacity(0.3) : bgColor.opacity(0.8),
                                    configuration.isPressed ? Color.black.opacity(0.5) : bgColor.opacity(0.5)
                                ]), startPoint: .top, endPoint: .bottom))
                        )
                        .background(
                            Group {
                                if theme is BetaTheme {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(.ultraThinMaterial)
                                }
                            }
                        )
                        .overlay(
                            Group {
                                if theme is BetaTheme {
                                    RoundedRectangle(cornerRadius: 3)
                                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                                } else {
                                    RoundedRectangle(cornerRadius: 3)
                                        .strokeBorder(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.5), .clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom), lineWidth: 1.5)
                                }
                            }
                        )
                        .shadow(color: theme is BetaTheme ? .clear : Color.black.opacity(0.5), radius: theme is BetaTheme ? 0 : (configuration.isPressed ? 0 : 1.5), x: 0, y: theme is BetaTheme ? 0 : (configuration.isPressed ? 1 : 3))
                )
                .foregroundColor(displayFgColor)
        }
        .frame(minHeight: 0)
        .contentShape(Rectangle()) // Make the whole VStack clickable (including the labels)
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
