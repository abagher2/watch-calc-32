import SwiftUI
import RPNCore

public struct LCDDisplayView: View {
    @Bindable var engine: CalculatorEngine
    var font: Font
    var foregroundColor: Color
    
    public init(engine: CalculatorEngine, font: Font, foregroundColor: Color) {
        self.engine = engine
        self.font = font
        self.foregroundColor = foregroundColor
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            if (engine.isBuildingNumber || engine.prgmIsBuildingNumber || engine.isWaitingForAlpha) && engine.statusMessage == nil && engine.errorMessage == nil && engine.transientMessage == nil {
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { proxy in
                        HStack(spacing: 0) {
                            if let prompt = engine.promptString {
                                Text(prompt)
                                    .accessibilityIdentifier("lcd_display")
                                    .lineLimit(1)
                            } else {
                                Text(engine.displayX)
                                    .accessibilityIdentifier("lcd_display")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                            Text("_")
                                .id("cursor")
                        }
                        .id("lcd_content")
                        .padding(.trailing, 2)
                        .onChange(of: engine.displayX) { _, _ in proxy.scrollTo("cursor", anchor: .trailing) }
                        .onChange(of: engine.promptString) { _, _ in proxy.scrollTo("cursor", anchor: .trailing) }
                        .onAppear { proxy.scrollTo("cursor", anchor: .trailing) }
                    }
                }
                .font(font)
                .foregroundColor(foregroundColor)
            } else {
                if let status = engine.statusMessage {
                    HStack(spacing: 0) {
                        Text(status)
                            .accessibilityIdentifier("lcd_display")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .bold()
                        Spacer(minLength: 0)
                    }
                    .id("lcd_content")
                    .font(font)
                    .foregroundColor(foregroundColor)
                } else if let error = engine.errorMessage {
                    HStack(spacing: 0) {
                        Text(error)
                            .accessibilityIdentifier("lcd_display")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .bold()
                        Spacer(minLength: 0)
                    }
                    .id("lcd_content")
                    .font(font)
                    .foregroundColor(foregroundColor)
                } else if let transient = engine.transientMessage {
                    // SHOW (and YES/NO) — use ScrollView so the full precision
                    // string is always visible without truncation/ellipsis
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(transient)
                            .accessibilityIdentifier("lcd_display")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .bold()
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .id("lcd_content")
                    .font(font)
                    .foregroundColor(foregroundColor)
                } else if let prompt = engine.promptString {
                    HStack(spacing: 0) {
                        Text(prompt)
                            .accessibilityIdentifier("lcd_display")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Spacer(minLength: 0)
                    }
                    .id("lcd_content")
                    .font(font)
                    .foregroundColor(foregroundColor)
                } else {
                    HStack(spacing: 0) {
                        Text(engine.displayX)
                            .accessibilityIdentifier("lcd_display")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Spacer(minLength: 0)
                    }
                    .id("lcd_content")
                    .font(font)
                    .foregroundColor(foregroundColor)
                }
            }
        }
    }
}
import SwiftUI
public struct LCDAnnunciatorsView: View {
    @Bindable var engine: CalculatorEngine
    var font: Font
    var foregroundColor: Color
    var yellowShiftColor: Color
    var blueShiftColor: Color
    var shift1Label: String
    var shift2Label: String
    var spacing: CGFloat?
    
    public init(
        engine: CalculatorEngine,
        font: Font,
        foregroundColor: Color,
        yellowShiftColor: Color,
        blueShiftColor: Color,
        shift1Label: String,
        shift2Label: String,
        spacing: CGFloat? = nil
    ) {
        self.engine = engine
        self.font = font
        self.foregroundColor = foregroundColor
        self.yellowShiftColor = yellowShiftColor
        self.blueShiftColor = blueShiftColor
        self.shift1Label = shift1Label
        self.shift2Label = shift2Label
        self.spacing = spacing
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            ZStack(alignment: .leading) {
                Text(shift1Label)
                    .foregroundColor(yellowShiftColor)
                    .opacity(engine.shiftState == 1 ? 1.0 : 0.0)
                Text(shift2Label)
                    .foregroundColor(blueShiftColor)
                    .opacity(engine.shiftState == 2 ? 1.0 : 0.0)
                Text(" ") // Keeps the space reserved so it doesn't collapse
                    .foregroundColor(.clear)
            }
            .frame(width: 16, alignment: .leading)
            
            if engine.angleMode == .rad {
                Text("RAD").foregroundColor(foregroundColor)
            } else if engine.angleMode == .grd {
                Text("GRD").foregroundColor(foregroundColor)
            }
            
            if engine.complexMode {
                Text("CMPLX").foregroundColor(foregroundColor)
            }
            
            if engine.isExamMode {
                Text("🔒 EXAM").foregroundColor(.yellow)
                    .accessibilityIdentifier("exam_indicator")
            }
            
            if !engine.autoReturnToMainPad {
                Text("STAY").foregroundColor(foregroundColor)
            }
            
            if engine.isEquationMode {
                Text("EQN").foregroundColor(foregroundColor)
            }
            
            if engine.isHypPending {
                Text("HYP").foregroundColor(foregroundColor)
            }
            
            if engine.hasStackData {
                Text("↑").foregroundColor(foregroundColor)
                    .accessibilityIdentifier("stack_indicator")
            } else {
                Text(" ").foregroundColor(.clear)
            }
            
            if engine.isProgrammingMode {
                Text("EQN").foregroundColor(foregroundColor)
            }
            
            if engine.baseMode == .hex {
                Text("HEX").foregroundColor(foregroundColor)
            } else if engine.baseMode == .oct {
                Text("OCT").foregroundColor(foregroundColor)
            } else if engine.baseMode == .bin {
                Text("BIN").foregroundColor(foregroundColor)
            }
            
            Spacer()
        }
        .font(font)
    }
}
