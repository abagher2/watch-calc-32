import SwiftUI
import RPNCore

struct ContentView: View {
    @Environment(CalculatorEngine.self) var engine
    @EnvironmentObject var themeManager: ThemeManager

    @AppStorage("hasSeenEnterTip") private var hasSeenEnterTip = false
    @State private var crownValue: Double = 0.0
    @FocusState private var isFocused: Bool
    @FocusState private var isAlphaFocused: Bool
    @State private var alphaInput = ""

    @State private var horizontalPage: Int = 1
    @State private var verticalPage: Int = 0

    #if os(watchOS)
    @AppStorage("hapticsMode") private var hapticsMode: Int = 2
#else
    @AppStorage("hapticsMode") private var hapticsMode: Int = 0
#endif

    private func simulateSwipe(width: CGFloat, height: CGFloat) {
        withAnimation {
            if abs(width) > abs(height) {
                let maxPage = 3
                if width > 15 && horizontalPage > 0 {
                    horizontalPage -= 1
                } else if width < -15 && horizontalPage < maxPage {
                    horizontalPage += 1
                }
            } else {
                if horizontalPage == 1 {
                    if height > 15 && verticalPage < 3 {
                        verticalPage += 1
                    } else if height < -15 {
                        if verticalPage > 0 {
                            verticalPage -= 1
                        } else {
                            engine.enter()
                        }
                    }
                } else {
                    if height < -15 {
                        engine.enter()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var plotProgressOverlay: some View {
        if engine.isGeneratingPlot {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .position(x: 30, y: 30)
        }
    }

    var body: some View {
        @Bindable var bindableEngine = engine
        GeometryReader { geo in
            let totalHeight = geo.size.height
            let toolbarHeight = totalHeight * 0.10
            
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    // LCD Display Header
                    lcdDisplay(totalHeight: totalHeight)
                        .frame(height: totalHeight * 0.2864)
                        .focusable()
                        .focused($isFocused)
                        #if os(watchOS)
                        .digitalCrownRotation($crownValue)
                        #endif
                        .onChange(of: crownValue) { new in
                            let delta = new - engine.lastCrownValue
                            if abs(delta) > 0.5 {
                                if engine.isProgrammingMode {
                                    if delta > 0 {
                                        engine.scrollDown()
                                    } else {
                                        engine.scrollUp()
                                    }
                                }
                                engine.lastCrownValue = new
                            }
                        }
                        .onAppear {
                            isFocused = true
                        }
                        .overlay(alignment: .bottomTrailing) {
                            Button("") {}
                            .frame(width: 10, height: 10)
                            .opacity(0.01)
                        }
                        
                    BottomNumpadView(
                        horizontalPage: $horizontalPage,
                        verticalPage: $verticalPage
                    )
                        .frame(height: totalHeight - (totalHeight * 0.2864) - 8 - toolbarHeight)
                        .clipped()
                }
                
                // Sticky Toolbar strictly anchored to the bottom
                stickyToolbar
                    .frame(height: toolbarHeight)
                    .position(x: geo.size.width / 2, y: geo.size.height - toolbarHeight / 2)
            }
            .gesture(
                DragGesture(minimumDistance: 15)
                    .onEnded { value in
                        simulateSwipe(width: value.translation.width, height: value.translation.height)
                    }
            )
        }
        
        .overlay(
            Group {
                if ProcessInfo.processInfo.arguments.contains("-UITesting") {
                    VStack {
                        HStack(spacing: 5) {
                            Button("L") { simulateSwipe(width: -20, height: 0) }.accessibilityIdentifier("sim_swipe_left").frame(width: 15, height: 15).foregroundColor(.clear).background(Color.clear)
                            Button("R") { simulateSwipe(width: 20, height: 0) }.accessibilityIdentifier("sim_swipe_right").frame(width: 15, height: 15).foregroundColor(.clear).background(Color.clear)
                            Button("U") { simulateSwipe(width: 0, height: -20) }.accessibilityIdentifier("sim_swipe_up").frame(width: 15, height: 15).foregroundColor(.clear).background(Color.clear)
                            Button("D") { simulateSwipe(width: 0, height: 20) }.accessibilityIdentifier("sim_swipe_down").frame(width: 15, height: 15).foregroundColor(.clear).background(Color.clear)
                            Button("RST") { 
                                horizontalPage = 1
                                verticalPage = 0
                            }.accessibilityIdentifier("sim_reset_pads").frame(width: 15, height: 15).foregroundColor(.clear).background(Color.clear)
                        }
                        .padding(.top, 40)
                        Spacer()
                    }
                    .zIndex(100) // Ensure it's on top of everything
                }
            }
        )
        .overlay(plotProgressOverlay)
        .ignoresSafeArea()
        .background(
            Group {
                if themeManager.activeThemeType == .beta {
                    Color.black
                        .ignoresSafeArea()
                        .opacity(bindableEngine.requestPlot || bindableEngine.requestPlotPrompt ? 1 : 1)
                } else {
                    themeManager.theme.chassisColor.ignoresSafeArea().opacity(bindableEngine.requestPlot || bindableEngine.requestPlotPrompt ? 1 : 1)
                }
            }
        )
        .modifier(WatchMenuModifier())
        .onChange(of: bindableEngine.isWaitingForAlpha) { _, newValue in
            if newValue {
                withAnimation { horizontalPage = 0 }
            } else {
                withAnimation { horizontalPage = 1 }
            }
        }
    }

    var stickyToolbar: some View {
        HStack(spacing: 0) {
            // Yellow Shift
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    engine.shiftState = (engine.shiftState == 1) ? 0 : 1
                }
            }) {
                if themeManager.activeThemeType == .retro {
                    Text(" ")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                } else {
                    Text(themeManager.theme.shift1Label)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(engine.shiftState == 2 ? .white.opacity(0.3) : .white)
                }
            }
            .buttonStyle(BezelButtonStyle(bgColor: themeManager.theme.yellowShiftColor, bottomLeadingRadius: 0))
            .accessibilityIdentifier("btn_yellow_shift")
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
            // C / CLEAR
            Button(action: {
                if horizontalPage != 1 || verticalPage != 0 {
                    // Just exit menu
                    withAnimation {
                        horizontalPage = 1
                        verticalPage = 0
                    }
                    engine.shiftState = 0
                } else {
                    if engine.shiftState == 1 {
                        engine.executeOp(.clear)
                        engine.shiftState = 0
                    } else {
                        engine.executeMath("C")
                    }
                }
            }) {
                Text("C")
                    .font(.system(size: 14, weight: .bold, design: .monospaced)) // Emphasized C button
                    .minimumScaleFactor(0.1)
                    .lineLimit(1)
                    .foregroundColor(.white)
            }
            .buttonStyle(BezelButtonStyle(bgColor: Color(red: 0.5, green: 0.35, blue: 0.0)))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
            // Blue Shift
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    engine.shiftState = (engine.shiftState == 2) ? 0 : 2
                }
            }) {
                if themeManager.activeThemeType == .retro {
                    Text(" ")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                } else {
                    Text(themeManager.theme.shift2Label)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(engine.shiftState == 1 ? .white.opacity(0.3) : .white)
                }
            }
            .buttonStyle(BezelButtonStyle(bgColor: themeManager.theme.blueShiftColor, bottomTrailingRadius: 0))
            .accessibilityIdentifier("btn_blue_shift")
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }

    func lcdDisplay(totalHeight: CGFloat) -> some View {
        let displayHeight = totalHeight * 0.2864
        let fontSize = displayHeight * 0.45
        
        return VStack(spacing: 2) {
            Color.clear.frame(height: 18) // Padding for watchOS status bar (time)
            // Indicators Row
            LCDAnnunciatorsView(
                engine: engine,
                font: .system(size: 10, weight: .bold),
                foregroundColor: .gray,
                yellowShiftColor: themeManager.theme.yellowShiftColor,
                blueShiftColor: themeManager.theme.blueShiftColor,
                shift1Label: themeManager.theme.shift1Label,
                shift2Label: themeManager.theme.shift2Label
            )
            .padding(.leading, 16)
            
            // Number DisplayRow
            if themeManager.activeThemeType == .retro {
                RetroLCDView(engine: engine)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 2)
            } else {
                LCDDisplayView(
                    engine: engine,
                    font: .system(size: fontSize, weight: .regular).monospacedDigit(),
                    foregroundColor: themeManager.theme.lcdTextColor
                )
                .padding(.bottom, 2) // small padding so descenders don't touch the absolute bottom edge
            }
            
            if engine.isBuildingNumber && !hasSeenEnterTip && engine.promptString == nil {
                Text("Tap for ENTER, Swipe for ops")
                    .font(.system(size: 8, weight: .regular))
                    .foregroundColor(.yellow)
                    .lineLimit(1)
                    .transition(.opacity)
                    .padding(.bottom, 2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        .overlay(
            Group {
                if themeManager.activeThemeType != .beta {
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.black.opacity(0.8))
                            .frame(height: 2)
                            .shadow(color: .white.opacity(0.2), radius: 1, x: 0, y: 1)
                    }
                }
            }
            .allowsHitTesting(false)
        )
        .background(
            Color(white: 0.12).ignoresSafeArea(edges: .top)
                .overlay(
                    HStack(spacing: 0) {
                        Color.clear.accessibilityIdentifier("invisible_ENTER")
                        Color.clear
                    }
                    .allowsHitTesting(false)
                )
        )
        .onTapGesture(coordinateSpace: .local) { location in
            #if os(watchOS)
            let screenWidth = WKInterfaceDevice.current().screenBounds.width
            #else
            let screenWidth = UIScreen.main.bounds.width
            #endif
            let isEnterZone = location.x < screenWidth * 0.75
            if isEnterZone {
                hasSeenEnterTip = true
                engine.enter()
            } else {
                engine.backspace()
            }
        }

    }
}


// MARK: - WatchMenuModifier
/// Holds all .sheet() and menu-related .onChange() modifiers for ContentView.
/// Extracted from body to keep the modifier chain within Swift's type-check limit.
/// Mirrors the iOS iOSMenuModifier pattern.
struct WatchMenuModifier: ViewModifier {
    @Environment(CalculatorEngine.self) var engine
    @EnvironmentObject var themeManager: ThemeManager

    @State private var showingPlot = false
    @State private var showPlotPrompt = false

    @State private var showSolve = false
    @State private var showXEQ = false
    @State private var showIntegrate = false
    @State private var showShow = false
    @State private var showProgramEditor = false
    @State private var showRegs = false

    func body(content: Content) -> some View {
        @Bindable var bindableEngine = engine
        content
            .sheet(isPresented: $showingPlot) { FullScreenPlotView() }
            .sheet(isPresented: $showPlotPrompt) { PlotPromptView().environment(engine) }
            .sheet(isPresented: $showSolve) { SolvePromptView().environment(engine) }
            .sheet(isPresented: $showXEQ) { XEQPromptView().environment(engine) }
            .sheet(isPresented: $showIntegrate) { IntegratePromptView().environment(engine) }
            .sheet(isPresented: $showShow) { ShowView(rawValue: engine.stack.first?.real ?? 0) }
            .sheet(isPresented: $showRegs) { RegsView() }
            .sheet(isPresented: $showProgramEditor) { EquationEditorView() }
            .sheet(isPresented: Binding(
                get: { bindableEngine.currentEvaluatingProgram != nil },
                set: { if !$0 { bindableEngine.currentEvaluatingProgram = nil } }
            )) { VariablePromptView() }
            // All CalculatorMenu menus (disp, modes, base, clear, flags, mem, const, etc.)
            // route through engine.activeMenu → CalculatorMenuPresenter.
            .sheet(item: Binding(
                get: { engine.activeMenu },
                set: { engine.activeMenu = $0 }
            )) { menu in
                CalculatorMenuPresenter(menu: menu, isPresented: Binding(
                    get: { engine.activeMenu == menu },
                    set: { if !$0 { engine.activeMenu = nil } }
                ))
                .environment(engine)
            }
            .onChange(of: bindableEngine.isProgrammingMode) { _, newValue in
                if !newValue { showProgramEditor = false }
            }
            .onChange(of: bindableEngine.requestPlot) { _, newValue in
                if newValue {
                    if themeManager.activeThemeType == .retro {
                        // Keep requestPlot true so RetroUI handles the rendering!
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showingPlot = true
                            bindableEngine.requestPlot = false
                        }
                    }
                }
            }
            .onChange(of: bindableEngine.requestPlotPrompt) { _, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showPlotPrompt = true
                        bindableEngine.requestPlotPrompt = false
                    }
                }
            }
            .onChange(of: bindableEngine.requestThemeChange) { _, newValue in
                if newValue {
                    let allThemes = ThemeType.allCases
                    if let currentIndex = allThemes.firstIndex(of: themeManager.activeThemeType) {
                        let nextIndex = (currentIndex + 1) % allThemes.count
                        themeManager.activeThemeType = allThemes[nextIndex]
                    }
                    bindableEngine.requestThemeChange = false
                }
            }
            .onChange(of: bindableEngine.requestEqn) { _, newValue in
                if newValue {
                    engine.activeMenu = .eqn
                    bindableEngine.requestEqn = false
                }
            }
            .onChange(of: bindableEngine.requestFnEq) { _, newValue in
                if newValue {
                    engine.activeMenu = .eqn
                    bindableEngine.requestFnEq = false
                }
            }
            .onChange(of: bindableEngine.requestSolve) { _, newValue in
                if newValue {
                    showSolve = true
                    bindableEngine.requestSolve = false
                }
            }
            .onChange(of: bindableEngine.requestIntegrate) { _, newValue in
                if newValue {
                    showIntegrate = true
                    bindableEngine.requestIntegrate = false
                }
            }
            .onChange(of: bindableEngine.requestXEQ) { _, newValue in
                if newValue {
                    showXEQ = true
                    bindableEngine.requestXEQ = false
                }
            }
            .onChange(of: bindableEngine.requestShow) { _, newValue in
                if newValue {
                    showShow = true
                    bindableEngine.requestShow = false
                }
            }
    }
}


#if DEBUG
struct WatchContentView_Previews: PreviewProvider {
    static var previews: some View {
        let engine = CalculatorEngine()
        engine.isProgrammingMode = true
        engine.currentProgramLabel = "NPDF"
        if let p = engine.programs.first(where: { $0.label == "NPDF" }) {
            engine.currentProgramSteps = p.steps.map { $0.stringValue }
        }
        engine.currentProgramStepIndex = 5
        
        return ContentView()
            .environment(engine)
            .previewDisplayName("Watch Multi-Line Editor")
            .previewDevice("Apple Watch Ultra 2 (49mm)")
    }
}
#endif
