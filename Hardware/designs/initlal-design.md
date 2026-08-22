WatchCalc32: Apple Watch RPN CalculatorVersion: 1.0 (Architecture & UI Specification)Target Platform: watchOS 10+ (Apple Watch Series 7, 8, 9, Ultra)Frameworks: SwiftUI, Charts, Swift 5.9, C/C++Core Engine: Advanced (WP43S) or Free42 C/C++ Core1. Executive SummaryWatchCalc32 brings the mathematical rigor of the HP-32SII and Advanced to the Apple Watch. It solves the "micro-button" problem of watch calculators by utilizing a Continuous Vertical Ribbon (a scrolling UI), Screen-Wide Gestures (eliminating modifier keys), and Native Apple Input (for variables and equations). The aesthetic mimics the molded plastic of the Pioneer chassis (e.g., SwissMicros Modern).2. System ArchitectureThe application strictly decouples the UI from the math engine using a Local Swift Package Manager (SPM) architecture.2.1 Workspace StructureWatchCalcWorkspace/
├── WatchCalc32_AppTarget/
│   ├── UI Components (SwiftUI)
│   └── App.swift
└── RPNCore (Local Swift Package)/
    ├── Package.swift
    ├── Sources/
    │   ├── CEngine/
    │   │   ├── include/CEngine.h (C Public API)
    │   │   └── core_logic.c (Advanced/Free42 source)
    │   └── RPNCore/
    │       └── CalculatorEngine.swift (Swift Wrapper)
2.2 The State Machine (CalculatorEngine.swift)The Swift layer acts as a bidirectional terminal between SwiftUI and the C core.import Foundation
import CEngine
import SwiftUI

@Observable
public class CalculatorEngine {
    // Standard Display State
    public var displayX: String = "0.0000"
    public var promptString: String? = nil // Handles display takeovers e.g. "STO _"
    
    // Shift State: 0=None, 1=Yellow(f), 2=Blue(g)
    public var shiftState: Int = 0 
    
    // 8-Level Stack Array (For Overlay)
    public var stack: [String] = Array(repeating: "0.0000", count: 8)
    
    // Mode Tracking
    public var isEquationMode: Bool = false
    public var equationString: String = ""
    
    public init() {
        c47_init()
        updateState()
    }
    
    public func execute(command: String) {
        // Map string identifier to C command and execute
        c47_execute_cmd(mapToID(command))
        updateState()
    }
    
    public func setShift(_ state: Int) {
        self.shiftState = state
        WKInterfaceDevice.current().play(.click)
    }
    
    private func updateState() {
        // Pseudo-logic to query C Engine
        if c47_is_waiting_for_input() {
            self.promptString = String(cString: c47_get_prompt())
        } else {
            self.promptString = nil
            self.displayX = String(cString: c47_get_display_x())
        }
        
        // Update deep stack
        for i in 0..<8 {
            if let val = c47_get_stack_level(Int32(i)) {
                self.stack[i] = String(cString: val)
            }
        }
    }
}
3. The Universal Gesture MatrixButtons on the screen act as static spatial targets. All modifiers and actions are routed through watchOS screen gestures.GestureActionEngine CommandHaptic FeedbackSwipe UpPush to StackENTER.successSwipe DownClear X / Cancel MenuCLx / EXIT.retrySwipe LeftReveal Math Operators PadN/A (UI state).directionUpSwipe RightReveal ASSIGN (LFU) MenuN/A (UI state).directionDownSwipe Display LeftToggle Yellow Shift (f)N/A (UI state).clickSwipe Display RightToggle Blue Shift (g)N/A (UI state).click (Double)Tap DisplayOpen 8-Level Stack OverlayN/A (UI state).clickDigital CrownScroll Keyboard RibbonN/A (UI state)Native Detents4. Visual Language & AestheticsThe UI simulates molded plastic with inner highlights and drop shadows, avoiding bitmaps for Retina sharpness.4.1 Color Paletteextension Color {
    static let dmChassis = Color(white: 0.1) // Background
    static let dmDigitKey = Color(white: 0.85) // 0-9
    static let dmFunctionKey = Color(white: 0.25) // Math functions
    static let dmYellowShift = Color(red: 1.0, green: 0.8, blue: 0.1)
    static let dmBlueShift = Color(red: 0.2, green: 0.8, blue: 1.0)
}
4.2 The Pioneer Button Stylestruct PioneerButtonStyle: ButtonStyle {
    var isDigit: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isDigit ? Color.dmDigitKey : Color.dmFunctionKey)
            )
            .overlay( // 3D Top Bevel
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.4), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(configuration.isPressed ? 0.0 : 0.6), radius: configuration.isPressed ? 0 : 2, y: configuration.isPressed ? 0 : 2)
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
    }
}
5. Viewport / Layout SpecificationsThe UI exists in a single vertical ScrollView. As the user scrolls up via the Crown, the grid safely expands from 3 columns to 4.5.1 The LCD Display (Pinned Header)A static, single-line display pinned to the top of the screen. Utilizes SF Mono Bold. If promptString is active, it takes over the X-register view.5.2 The Bottom Viewport (Data Entry - 3x4 Grid)Scroll Offset = 0.7, 8, 94, 5, 61, 2, 30, ., +/-5.3 The Upper Matrix (Scientific - 4x5 Grid)Scroll Offset < 0. Located directly above the Numpad.STO, RCL, x><y, R↓1/x, √x, LN, LOGSIN, COS, TAN, R/SFN=, ∫, ABS, INTGLBL, GTO, EQN, SOLVE5.4 The "Hold to Preview" LogicTo prevent accidental shifted clicks, custom gesture logic replaces standard buttons in the Upper Matrix:Touch Down: Shows the key's target function (e.g., "ASIN") on the LCD promptString.Drag Away: Cancels the press and clears the LCD preview.Release inside bounds: Executes the function.6. Advanced Subsystems6.1 Native Alpha Entry (Variables / STO)When the Advanced engine waits for a variable (e.g., STO _), the UI must trigger the native watchOS text entry.engine.promptString updates to "STO _".SwiftUI triggers .sheet(isPresented: $isWaitingForAlpha).User utilizes Apple Scribble or QWERTY keyboard.OnSubmit, Swift sanitizes to a single uppercased String and passes CMD_ALPHA_A to Advanced.6.2 Equation & Solve EngineWhen EQN is active, the single-line LCD swaps to a horizontal ScrollView (Ticker).Users can type equations via the 4x5 ribbon OR tap a keyboard icon to open native watchOS dictation/keyboard.Swift parses Y=3X^2 string into sequential Advanced engine commands.6.3 Plotting / Graphing Engine (Oscilloscope Mode)Integrated via SwiftUI Charts. Triggered from Equation mode.struct FullScreenPlotView: View {
    @StateObject var plotEngine: PlotEngine // Runs loop to evaluate Advanced equation 150 times
    @State private var crownZoom: Double = 10.0
    
    var body: some View {
        Chart(plotEngine.dataPoints) { point in
            LineMark(x: .value("X", point.x), y: .value("Y", point.y))
                .interpolationMethod(.monotone)
                .foregroundStyle(Color.dmBlueShift)
        }
        .chartXScale(domain: -crownZoom...crownZoom)
        .chartYScale(domain: -crownZoom...crownZoom)
        .focusable(true)
        .digitalCrownRotation($crownZoom, from: 1, through: 100, sensitivity: .medium)
    }
}
7. Recommended Development PhasesPhase 1: SPM & Engine. Create local package, wrap Advanced/Free42 C code, build bidirectional @Observable engine class.Phase 2: Skin & Gestures. Build the Modern UI components, the 3x4 Numpad, and wire the Swipe Up/Down/Left gestures.Phase 3: The Ribbon. Implement the ScrollView, the 4x5 upper matrix, and the display header logic (shift states).Phase 4: Integrations. Add the Native watchOS text field handoffs for Alpha entry and the SwiftUI Charts for plotting.