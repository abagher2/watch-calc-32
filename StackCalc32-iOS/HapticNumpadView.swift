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
        GeometryReader { geo in
            let totalRows = (keys.map { $0.row }.max() ?? 0) + 1
            let isVoyager = totalRows == 4
            let totalCols: CGFloat = isVoyager ? 11 : 6
            
            // Limit max height on iPad so landscape keys don't stretch vertically in portrait
            let maxH = geo.size.width / totalCols * 0.85
            let rawH = geo.size.height / CGFloat(totalRows)
            let h = UIDevice.current.userInterfaceIdiom == .pad ? min(rawH, maxH) : rawH
            
            let isRetro = themeManager.activeThemeType == .retro
            let physKeypadW: CGFloat = 68.0
            // In Retro mode, total height = LCD (35.28) + gap (4.0) + keypad (94.0)
            let physKeypadH: CGFloat = isRetro ? 133.28 : 94.0
            let uniformScale = min(geo.size.width / physKeypadW, geo.size.height / physKeypadH)
            
            // In Retro mode, place the entire block (LCD + keypad) at the bottom of the view.
            let emptySpaceY = geo.size.height - (physKeypadH * uniformScale)
            let offsetY_retro = isRetro ? (emptySpaceY + 39.28 * uniformScale) : emptySpaceY
            let offsetX_retro = (geo.size.width - (physKeypadW * uniformScale)) / 2
            
            let topW = geo.size.width / 6
            let bottomW = geo.size.width / 5
            let voyagerW = geo.size.width / 11

            let gridHeight = h * CGFloat(totalRows)
            let offsetY = isVoyager ? geo.size.height * 0.05 : 0

            ZStack(alignment: .topLeading) {
                // Background is handled by iOSContentView's chassisColor
                
                if isRetro {
                    // Physical LCD Active Area is 58.8 x 35.28 mm
                    // Center of LCD is at x = 34.0 mm, which means it starts at 4.6 mm
                    let lcdWidth = 58.8 * uniformScale
                    let lcdHeight = 35.28 * uniformScale
                    let lcdX = (34.0 - (58.8 / 2)) * uniformScale + offsetX_retro
                    
                    // The LCD is placed at the top of the block
                    let lcdY = emptySpaceY
                    
                    RetroLCDView(engine: engine, pixelColor: (15, 20, 15, 255), backgroundColor: (0, 0, 0, 0))
                        .frame(width: lcdWidth, height: lcdHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(themeManager.theme.lcdBackgroundColor)
                        )
                        .position(x: lcdX + lcdWidth/2, y: lcdY + lcdHeight/2)
                        
                    // X-center of the empty gap is 22.35mm
                    let logoX = offsetX_retro + ((22.35 - 3.85) / physKeypadW) * (physKeypadW * uniformScale)
                    let logoY = offsetY_retro + (94.0 * uniformScale) - (((28.0 - 7.0) / 94.0) * (94.0 * uniformScale))
                    
                    Text("STACK\nCALC 32")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.85))
                        .multilineTextAlignment(.leading)
                        .fixedSize()
                        .position(x: logoX, y: logoY)
                }
                
                ForEach(keys) { key in
                    let isRetro = themeManager.activeThemeType == .retro
                    let phys = isRetro ? physicalKeyOffsets[physicalKeyFor(key: key)] : nil
                    
                    let colW = isVoyager ? voyagerW : (key.row < 4 ? topW : bottomW)
                    
                    let w = phys != nil ? phys!.w * uniformScale : colW * CGFloat(key.colSpan)
                    let buttonHeight = phys != nil ? phys!.h * uniformScale : h * CGFloat(key.rowSpan)
                    
                    // In retro mode, X calculation must account for the centering offset
                    let normX = phys != nil ? (phys!.x - 3.85) / physKeypadW : 0
                    let normY = phys != nil ? (phys!.y - 7.0) / physKeypadH : 0
                    
                    let xOffset = phys != nil ? (offsetX_retro + (normX * (physKeypadW * uniformScale)) - (w / 2)) : (CGFloat(key.col) * colW)
                    let yOffset = phys != nil ? (offsetY_retro + (physKeypadH * uniformScale) - (normY * (physKeypadH * uniformScale)) - (buttonHeight / 2)) : (offsetY + (CGFloat(key.row) * h))
                    
                    let adjustedWidth = phys != nil ? w + (3.5 * uniformScale) : w
                    let adjustedHeight = phys != nil ? buttonHeight + (6.0 * uniformScale) : buttonHeight
                    
                    ButtonView(key: key, isHovered: hoveredKey == key, width: w, height: buttonHeight)
                        .frame(width: adjustedWidth, height: adjustedHeight)
                        .contentShape(Rectangle())
                        .offset(x: phys != nil ? xOffset - (adjustedWidth - w)/2 : xOffset, y: phys != nil ? yOffset - (adjustedHeight - buttonHeight)/2 : yOffset)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(key.label.isEmpty ? (key.primaryAction?.stringValue ?? "") : key.label)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier(identifier(for: key))
                        .accessibilityAction {
                            triggerHaptic(for: key, at: CGPoint(x: xOffset + w/2, y: yOffset + buttonHeight/2), in: geo.size)
                            executeAction(for: key)
                        }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            .contentShape(Rectangle())

            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDrag(location: value.location, size: geo.size)
                    }
                    .onEnded { value in
                        print("HAPTIC_DEBUG: DragGesture onEnded fired.")
                        let keyToExecute = hoveredKey ?? keyAt(location: value.location, size: geo.size)
                        if let key = keyToExecute {
                            executeAction(for: key)
                        }
                        hoveredKey = nil
                    }
            )
        }
    }
    
    private func identifier(for key: HP32Key) -> String {
        if key.primaryAction == .shiftYellow { return "btn_yellow_shift" }
        if key.primaryAction == .shiftBlue { return "btn_blue_shift" }
        if key.primaryAction == .enter { return "invisible_ENTER" }
        let actStr = key.primaryAction?.stringValue ?? ""
        if Int(actStr) != nil || actStr == "." { return "btn_\(actStr)" }
        return "func_\(actStr)"
    }
    
    private func physicalKeyFor(key: HP32Key) -> String {
        if key.primaryAction == .lfu0 { return "SOFT1" }
        if key.primaryAction == .lfu1 { return "SOFT2" }
        if key.primaryAction == .lfu2 { return "SOFT3" }
        if key.primaryAction == .lfu3 { return "SOFT4" }
        if key.primaryAction == .lfu4 { return "SOFT5" }
        if key.primaryAction == .lfu5 { return "SOFT6" }
        if key.primaryAction == .shiftYellow { return "f" }
        if key.primaryAction == .shiftBlue { return "g" }
        if key.primaryAction == .reciprocal { return "1/𝑥" }
        if key.label.isEmpty {
            if key.primaryAction == .enter { return "ENTER" }
            if key.primaryAction == .backspace { return "<-" }
            return key.primaryAction?.stringValue ?? ""
        }
        return key.label
    }
    
    private func handleDrag(location: CGPoint, size: CGSize) {
        if let newKey = keyAt(location: location, size: size) {
            let centerAndMax = getCenterAndMaxDistance(for: newKey, size: size)
            let dist = hypot(location.x - centerAndMax.center.x, location.y - centerAndMax.center.y)
            let normalizedDist = min(1.0, max(0.0, dist / centerAndMax.maxDistance))
            
            if newKey != hoveredKey {
                hoveredKey = newKey
                hasPlayedCenterPopForCurrentKey = false
                lastTextureLocation = location
                if hapticsEnabled { HapticManager.shared.playBoundary() }
            } else {
                if !hapticsEnabled { return }
                let dragDist = hypot(location.x - lastTextureLocation.x, location.y - lastTextureLocation.y)
                if dragDist > 3.0 {
                    lastTextureLocation = location
                    if normalizedDist < 0.15 {
                        if !hasPlayedCenterPopForCurrentKey {
                            hasPlayedCenterPopForCurrentKey = true
                            HapticManager.shared.playCenterPop()
                        }
                    } else {
                        hasPlayedCenterPopForCurrentKey = false
                        let totalRows = (keys.map { $0.row }.max() ?? 0) + 1
                        let sharpness = 1.0 - (Float(newKey.row) / Float(max(1, totalRows - 1)))
                        let textureIntensity = Float(1.0 - normalizedDist) * 0.8
                        HapticManager.shared.playTexture(intensity: max(0.2, textureIntensity), sharpness: max(0.1, sharpness))
                    }
                }
            }
        } else {
            if hoveredKey != nil {
                if hapticsEnabled {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.warning)
                }
                hoveredKey = nil
            }
        }
    }
    
    private func getCenterAndMaxDistance(for key: HP32Key, size: CGSize) -> (center: CGPoint, maxDistance: CGFloat) {
        let totalRows = (keys.map { $0.row }.max() ?? 0) + 1
        let isVoyager = totalRows == 4
        let totalCols: CGFloat = isVoyager ? 11 : 6
        
        let maxH = size.width / totalCols * 0.85
        let rawH = size.height / CGFloat(totalRows)
        let h = UIDevice.current.userInterfaceIdiom == .pad ? min(rawH, maxH) : rawH
        
        let gridHeight = h * CGFloat(totalRows)
        let offsetY = size.height - gridHeight
        
        let colW = isVoyager ? (size.width / 11) : (key.row < 4 ? (size.width / 6) : (size.width / 5))
        
        let w = colW * CGFloat(key.colSpan)
        let buttonHeight = h * CGFloat(key.rowSpan)
        
        let xOffset = CGFloat(key.col) * colW
        let yOffset = offsetY + (CGFloat(key.row) * h)
        
        let center = CGPoint(x: xOffset + w/2, y: yOffset + buttonHeight/2)
        let maxDistance = hypot(w/2, buttonHeight/2)
        
        return (center, maxDistance)
    }

    private func keyAt(location: CGPoint, size: CGSize) -> HP32Key? {
        let totalRows = (keys.map { $0.row }.max() ?? 0) + 1
        let isVoyager = totalRows == 4
        let totalCols: CGFloat = isVoyager ? 11 : 6
        
        let maxH = size.width / totalCols * 0.85
        let rawH = size.height / CGFloat(totalRows)
        let h = UIDevice.current.userInterfaceIdiom == .pad ? min(rawH, maxH) : rawH
        
        let gridHeight = h * CGFloat(totalRows)
        let offsetY = size.height - gridHeight
        
        let adjustedY = location.y - offsetY
        if adjustedY < 0 { return nil }
        
        let row = Int(adjustedY / h)
        if row < 0 || row >= totalRows { return nil }
        
        let colW = isVoyager ? (size.width / 11) : (row < 4 ? (size.width / 6) : (size.width / 5))
        let col = Int(location.x / colW)
        
        return keys.first { key in
            col >= key.col && col < (key.col + key.colSpan) &&
            row >= key.row && row < (key.row + key.rowSpan)
        }
    }
    
    private func triggerHaptic(for key: HP32Key, at location: CGPoint, in size: CGSize) {
        // Obsolete, logic moved to handleDrag
    }
    
    private func executeAction(for key: HP32Key) {
        if Date().timeIntervalSince(lastActionTime) < 0.1 { return }
        lastActionTime = Date()
        
        let opToExecute: CalculatorOperation?
        switch engine.shiftState {
        case 1: opToExecute = key.yellowAction ?? key.primaryAction
        case 2: opToExecute = key.blueAction ?? key.primaryAction
        default: opToExecute = key.primaryAction
        }
        
        guard let command = opToExecute else { return }
        
        print("UI_TEST_DEBUG: executing action for key: \(command) label: \(key.label)")
        if command == .shiftYellow {
            engine.shiftState = (engine.shiftState == 1) ? 0 : 1
        } else if command == .shiftBlue {
            engine.shiftState = (engine.shiftState == 2) ? 0 : 2
        } else {
            dispatchKey(command, engine: engine, onMenuAction: onMenuAction)
            engine.shiftState = 0
        }
    }
    // mapOp() and dispatchKey() live in Shared/KeyActionDispatcher.swift
}

struct ButtonView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(CalculatorEngine.self) var engine
    let key: HP32Key
    let isHovered: Bool
    let width: CGFloat
    let height: CGFloat
    
    private func uiLabel(for op: String) -> String {
        if op.isEmpty { return "" }
        switch op {
        case "𝑦ˣ": return "𝑦ˣ"
        case "xVy": return "ˣ√𝑦"
        case "x,y": return "𝑥,𝑦"
        case "1/𝑥": return "¹/𝑥"
        case "𝑥!": return "𝑥!"
        case "√𝑥": return "√𝑥"
        case "𝑥²": return "𝑥²"
        case "𝑒ˣ": return "𝑒ˣ"
        case "10ˣ": return "10ˣ"
        default: return op
        }
    }
    
    var resolvedLabel: String {
        if themeManager.activeThemeType == .retro && key.row == 0 {
            return ""
        }
        if let primary = key.primaryAction, primary.rawValue >= CalculatorOperation.lfu0.rawValue && primary.rawValue <= CalculatorOperation.lfu5.rawValue {
            let slot = primary.rawValue - CalculatorOperation.lfu0.rawValue
            return uiLabel(for: engine.lfuManager.getFunction(for: slot))
        }
        return key.label
    }
    
    var resolvedYellowLabel: String {
        if let yellow = key.yellowAction, yellow.rawValue >= CalculatorOperation.lfu0.rawValue && yellow.rawValue <= CalculatorOperation.lfu5.rawValue {
            let slot = yellow.rawValue - CalculatorOperation.lfu0.rawValue
            return uiLabel(for: engine.lfuManager.getFunction(for: slot))
        }
        return key.yellowLabel
    }
    
    @ViewBuilder
    func renderLabel(_ str: String, size: CGFloat) -> some View {
        let mathFont = Font.system(size: size, weight: .bold, design: .serif).italic()
        let subFont = Font.system(size: size * 0.65, weight: .bold)
        let mathSubFont = Font.system(size: size * 0.65, weight: .bold, design: .serif).italic()
        
        if str == "𝑒ˣ" || str == "e^x" {
            HStack(spacing: 0) {
                Text("e").font(mathFont)
                Text("x").font(mathSubFont).baselineOffset(size * 0.4)
            }
        } else if str == "𝑦ˣ" || str == "y^x" {
            HStack(spacing: 0) {
                Text("y").font(mathFont)
                Text("x").font(mathSubFont).baselineOffset(size * 0.4)
            }
        } else if str == "10ˣ" || str == "10^x" {
            HStack(spacing: 0) {
                Text("10").font(.system(size: size, weight: .bold))
                Text("x").font(mathSubFont).baselineOffset(size * 0.4)
            }
        } else if str == "𝑥²" || str == "x^2" {
            HStack(spacing: 0) {
                Text("x").font(mathFont)
                Text("2").font(subFont).baselineOffset(size * 0.4)
            }
        } else if str == "¹/𝑥" || str == "1/x" {
            HStack(spacing: 0) {
                Text("1/").font(.system(size: size, weight: .bold))
                Text("x").font(mathFont)
            }
        } else if str == "√𝑥" || str == "sqrt(x)" {
            HStack(spacing: 0) {
                Text("√").font(.system(size: size, weight: .bold))
                Text("x").font(mathFont)
            }
        } else if str == "𝑥!" || str == "x!" {
            HStack(spacing: 0) {
                Text("x").font(mathFont)
                Text("!").font(.system(size: size, weight: .bold))
            }
        } else if str == "𝑥≷𝑦" || str == "x<>y" {
            HStack(spacing: 2) {
                Text("x").font(mathFont)
                Image(systemName: "arrow.left.and.right").font(.system(size: size * 0.75, weight: .bold))
                Text("y").font(mathFont)
            }
        } else if str == "𝑥≷?" || str == "x<>?" {
            HStack(spacing: 2) {
                Text("x").font(mathFont)
                Image(systemName: "arrow.left.and.right").font(.system(size: size * 0.75, weight: .bold))
                Text("?").font(.system(size: size, weight: .bold))
            }
        } else {
            Text(str).font(.system(size: size, weight: .bold))
        }
    }

    var resolvedBlueLabel: String {
        if let blue = key.blueAction, blue.rawValue >= CalculatorOperation.lfu0.rawValue && blue.rawValue <= CalculatorOperation.lfu5.rawValue {
            let slot = blue.rawValue - CalculatorOperation.lfu0.rawValue
            return uiLabel(for: engine.lfuManager.getFunction(for: slot))
        }
#if os(iOS) || os(watchOS)
        if key.blueLabel == "OFF" { return "" }
#endif
        return key.blueLabel
    }

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
                      
        VStack(spacing: 2) {
            // Top shift labels (above the button)
            HStack(alignment: .bottom, spacing: 0) {
                renderLabel(resolvedYellowLabel, size: shiftFontSize)
                    .minimumScaleFactor(themeManager.activeThemeType == .retro ? 1.0 : 0.1)
                    .fixedSize(horizontal: themeManager.activeThemeType == .retro, vertical: false)
                    .foregroundColor(themeManager.theme.yellowShiftColor)
                    .opacity(isAlphaMode ? 0.15 : (engine.shiftState == 0 ? 1.0 : (engine.shiftState == 1 ? 1.0 : 0.3)))
                    .lineLimit(1)
                Spacer(minLength: 4)
                renderLabel(resolvedBlueLabel, size: shiftFontSize)
                    .minimumScaleFactor(themeManager.activeThemeType == .retro ? 1.0 : 0.1)
                    .fixedSize(horizontal: themeManager.activeThemeType == .retro, vertical: false)
                    .foregroundColor(themeManager.theme.blueShiftColor)
                    .opacity(isAlphaMode ? 0.15 : (engine.shiftState == 0 ? 1.0 : (engine.shiftState == 2 ? 1.0 : 0.3)))
                    .lineLimit(1)
            }
            .padding(.horizontal, 2)
            .frame(height: 14)
            
            // Button and Alpha label row
            HStack(alignment: .bottom, spacing: 2) {
                // Button
                ZStack {
                    let labelText: String = isYellowShift ? "yellow" :
                                    isBlueShift ? "blue" :
                                    (resolvedLabel == "<-" ? "<-" : resolvedLabel)
                                    
                    if themeManager.activeThemeType == .beta {
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
                    } else if themeManager.activeThemeType == .retro {
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
                    } else {
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
                    }
                    
                    let textColor = isYellowShift || isBlueShift || isClear ? Color.white :
                                    (isDigit ? themeManager.theme.digitTextColor : themeManager.theme.functionTextColor)
                    
                    if isYellowShift {
                        Text(themeManager.theme.shift1Label)
                            .font(.system(size: mainFontSize, weight: .bold))
                            .minimumScaleFactor(themeManager.activeThemeType == .retro ? 1.0 : 0.1)
                            .fixedSize(horizontal: themeManager.activeThemeType == .retro, vertical: false)
                            .foregroundColor(textColor)
                            .opacity(isAlphaMode ? 0.15 : 1.0)
                            .lineLimit(1)
                    } else if isBlueShift {
                        Text(themeManager.theme.shift2Label)
                            .font(.system(size: mainFontSize, weight: .bold))
                            .minimumScaleFactor(themeManager.activeThemeType == .retro ? 1.0 : 0.1)
                            .fixedSize(horizontal: themeManager.activeThemeType == .retro, vertical: false)
                            .foregroundColor(textColor)
                            .opacity(isAlphaMode ? 0.15 : 1.0)
                            .lineLimit(1)
                    } else if resolvedLabel == "<-" {
                        Text(themeManager.theme.backspaceLabel)
                            .font(.system(size: mainFontSize, weight: .bold))
                            .minimumScaleFactor(themeManager.activeThemeType == .retro ? 1.0 : 0.1)
                            .fixedSize(horizontal: themeManager.activeThemeType == .retro, vertical: false)
                            .foregroundColor(textColor)
                            .opacity(isAlphaMode ? 0.15 : 1.0)
                            .lineLimit(1)
                    } else {
                        renderLabel(isAlphaMode ? key.alphaLabel : labelText, size: mainFontSize)
                            .minimumScaleFactor(themeManager.activeThemeType == .retro ? 1.0 : 0.1)
                            .fixedSize(horizontal: themeManager.activeThemeType == .retro, vertical: false)
                            .foregroundColor(textColor)
                            .opacity(isAlphaMode ? 0.15 : 1.0)
                            .lineLimit(1)
                    }
                }
                
                // Alpha label — always in its side position, highlighted in alpha mode
                if !key.alphaLabel.isEmpty {
                    Text(key.alphaLabel)
                        .font(.system(size: alphaFontSize, weight: .bold))
                        .minimumScaleFactor(themeManager.activeThemeType == .retro ? 1.0 : 0.1)
                        .fixedSize(horizontal: themeManager.activeThemeType == .retro, vertical: false)
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
