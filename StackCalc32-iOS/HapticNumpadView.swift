import SwiftUI
import RPNCore
import AudioToolbox



struct HapticNumpadView: View {
    @Environment(CalculatorEngine.self) var engine
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    
    @State private var hoveredKey: HP32Key? = nil
    @State private var lastActionTime: Date = .distantPast
    @State private var lastTextureLocation: CGPoint = .zero
    @State private var hasPlayedCenterPopForCurrentKey: Bool = false
    
    var onMenuAction: ((CalculatorOperation) -> Void)?
    var keys: [HP32Key] = HP32KeyMap.standardGrid
    

    var body: some View {
        let _ = engine.lfuManager.slots
        let isYellowShift = key.primaryAction == .shiftYellow
        let isBlueShift = key.primaryAction == .shiftBlue
        let isClear = key.primaryAction == .clear
        
        let isDigit = key.primaryAction?.stringValue.count == 1 && key.primaryAction?.stringValue.first?.isNumber == true || key.primaryAction == .decimal
        let baseColor = isDigit ? themeManager.theme.digitKeyColor : themeManager.theme.functionKeyColor
        
        let mainFontSize: CGFloat = themeManager.activeThemeType == .retro ? 14 : 14
        let shiftFontSize: CGFloat = themeManager.activeThemeType == .retro ? 9 : 10
        let alphaFontSize: CGFloat = themeManager.activeThemeType == .retro ? 11 : 11
        
        let bgColor = isYellowShift ? themeManager.theme.yellowShiftColor :
                      isBlueShift ? themeManager.theme.blueShiftColor :
                      isClear ? Color(red: 0.5, green: 0.35, blue: 0.25) :
                      isHovered ? baseColor.opacity(0.7) : baseColor
                      
        let isAlphaMode = engine.isWaitingForAlpha && !key.alphaLabel.isEmpty
                      
        let labelText: String = isYellowShift ? "yellow" :
                        isBlueShift ? "blue" :
                        (resolvedLabel == "<-" ? "<-" : resolvedLabel)
                        
        let textColor = isYellowShift || isBlueShift || isClear ? Color.white :
                        (isDigit ? themeManager.theme.digitTextColor : themeManager.theme.functionTextColor)

        if themeManager.activeThemeType == .retro {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [
                            isHovered ? Color.black.opacity(0.3) : bgColor.opacity(0.9),
                            isHovered ? Color.black.opacity(0.5) : bgColor.opacity(0.5)
                        ]), startPoint: .top, endPoint: .bottom)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .strokeBorder(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.5), .clear, .black.opacity(0.8)]), startPoint: .top, endPoint: .bottom), lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.5), radius: isHovered ? 0 : 1.5, x: 0, y: isHovered ? 1 : 4)
                
                if isYellowShift {
                    Text(themeManager.theme.shift1Label)
                        .font(.system(size: mainFontSize, weight: .bold))
                        .foregroundColor(textColor)
                        .opacity(isAlphaMode ? 0.15 : 1.0)
                        .lineLimit(1)
                } else if isBlueShift {
                    Text(themeManager.theme.shift2Label)
                        .font(.system(size: mainFontSize, weight: .bold))
                        .foregroundColor(textColor)
                        .opacity(isAlphaMode ? 0.15 : 1.0)
                        .lineLimit(1)
                } else if resolvedLabel == "<-" {
                    Text(themeManager.theme.backspaceLabel)
                        .font(.system(size: mainFontSize, weight: .bold))
                        .foregroundColor(textColor)
                        .opacity(isAlphaMode ? 0.15 : 1.0)
                        .lineLimit(1)
                } else {
                    renderLabel(isAlphaMode ? key.alphaLabel : labelText, size: mainFontSize)
                        .foregroundColor(textColor)
                        .opacity(isAlphaMode ? 0.15 : 1.0)
                        .lineLimit(1)
                }
            }
            .frame(width: width - 4, height: height - 4)
            .overlay(
                // Top shift labels
                HStack(alignment: .bottom, spacing: 0) {
                    renderLabel(resolvedYellowLabel, size: shiftFontSize)
                        .foregroundColor(themeManager.theme.yellowShiftColor)
                        .opacity(isAlphaMode ? 0.15 : (engine.shiftState == 0 ? 1.0 : (engine.shiftState == 1 ? 1.0 : 0.3)))
                        .lineLimit(1)
                    Spacer(minLength: 2)
                    renderLabel(resolvedBlueLabel, size: shiftFontSize)
                        .foregroundColor(themeManager.theme.blueShiftColor)
                        .opacity(isAlphaMode ? 0.15 : (engine.shiftState == 0 ? 1.0 : (engine.shiftState == 2 ? 1.0 : 0.3)))
                        .lineLimit(1)
                }
                .frame(width: width + 6)
                .offset(y: -height/2 - 6) // Position above squircle
            )
            .overlay(
                // Right alpha label
                Group {
                    if !key.alphaLabel.isEmpty {
                        Text(key.alphaLabel)
                            .font(.system(size: alphaFontSize, weight: .bold))
                            .foregroundColor(engine.isWaitingForAlpha ? .primary : .gray)
                            .offset(x: width/2 + 5)
                    }
                }
            )
            .overlay(
                // Bottom ON label
                Group {
                    if key.primaryAction == .c {
                        Text("ON")
                            .font(.system(size: shiftFontSize, weight: .bold))
                            .foregroundColor(themeManager.theme.digitTextColor.opacity(0.8))
                            .offset(y: height/2 + 6)
                    }
                }
            )
            .opacity(isYellowShift && engine.shiftState == 2 ? 0.5 : isBlueShift && engine.shiftState == 1 ? 0.5 : 1.0)
        } else {
            ZStack {
                let fillOpacity = (isYellowShift || isBlueShift || isClear) ? 0.85 : 0.15
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(bgColor.opacity(fillOpacity))
                    .background(
                        Group {
                            if !isYellowShift && !isBlueShift && !isClear {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                HStack(spacing: 4) {
                    Spacer().frame(width: 8)
                    
                    ZStack {
                        if isYellowShift {
                            Text(themeManager.theme.shift1Label)
                                .font(.system(size: mainFontSize, weight: .bold))
                                .minimumScaleFactor(0.1)
                                .foregroundColor(textColor)
                                .opacity(isAlphaMode ? 0.15 : 1.0)
                                .lineLimit(1)
                        } else if isBlueShift {
                            Text(themeManager.theme.shift2Label)
                                .font(.system(size: mainFontSize, weight: .bold))
                                .minimumScaleFactor(0.1)
                                .foregroundColor(textColor)
                                .opacity(isAlphaMode ? 0.15 : 1.0)
                                .lineLimit(1)
                        } else if resolvedLabel == "<-" {
                            Text(themeManager.theme.backspaceLabel)
                                .font(.system(size: mainFontSize, weight: .bold))
                                .minimumScaleFactor(0.1)
                                .foregroundColor(textColor)
                                .opacity(isAlphaMode ? 0.15 : 1.0)
                                .lineLimit(1)
                        } else {
                            renderLabel(isAlphaMode ? key.alphaLabel : labelText, size: mainFontSize)
                                .minimumScaleFactor(0.1)
                                .foregroundColor(textColor)
                                .opacity(isAlphaMode ? 0.15 : 1.0)
                                .lineLimit(1)
                        }
                    }
                    
                    // Alpha label — always in its side position, highlighted in alpha mode
                    if !key.alphaLabel.isEmpty {
                        Text(key.alphaLabel)
                            .font(.system(size: alphaFontSize, weight: .bold))
                            .minimumScaleFactor(0.1)
                            .foregroundColor(engine.isWaitingForAlpha ? .primary : .gray)
                            .frame(width: 8, alignment: .leading)
                    } else {
                        Spacer().frame(width: 8)
                    }
                }
            }
            .frame(width: width - 4, height: height - 4)
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
            .opacity(isYellowShift && engine.shiftState == 2 ? 0.5 : isBlueShift && engine.shiftState == 1 ? 0.5 : 1.0)
        }
    }

}



import CoreHaptics
import UIKit

class HapticManager {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
    
    init() {
        prepareEngine()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func handleForeground() {
        prepareEngine()
    }
    
    func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            if engine == nil {
                engine = try CHHapticEngine()
                engine?.playsHapticsOnly = true
                engine?.stoppedHandler = { [weak self] _ in
                    self?.engine = nil
                }
                engine?.resetHandler = { [weak self] in
                    try? self?.engine?.start()
                }
            }
            try engine?.start()
        } catch {
            engine = nil
        }
    }
    
    private func playPattern(intensity: Float, sharpness: Float) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        prepareEngine()
        do {
            let hapticEvent = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0
            )
            
            let pattern = try CHHapticPattern(events: [hapticEvent], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            engine = nil
        }
    }
    
    func playBoundary() { playPattern(intensity: 0.7, sharpness: 0.5) }
    func playTexture(intensity: Float, sharpness: Float) { playPattern(intensity: intensity, sharpness: sharpness) }
    func playCenterPop() { playPattern(intensity: 1.0, sharpness: 1.0) }
}
