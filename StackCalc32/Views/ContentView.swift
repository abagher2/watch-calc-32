import SwiftUI
import RPNCore

struct ContentView: View {
    @Environment(CalculatorEngine.self) var engine
    @EnvironmentObject var themeManager: ThemeManager

    @AppStorage("hasSeenEnterTip") private var hasSeenEnterTip = false
    @State private var showingPlot = false
    @State private var showEquations = false
    @State private var showClearMenu = false
    @State private var showProbMenu = false
    @State private var showPartsMenu = false
    @State private var showLRMenu = false
    @State private var showSumsMenu = false
    @State private var showMeanMenu = false
    @State private var showStdDevMenu = false
    @State private var showFN = false
    @State private var showSolve = false
    @State private var showXEQ = false
    @State private var showConstMenu = false
    @State private var showIntegrate = false
    @State private var showPlotPrompt = false
    @State private var showShow = false
    @State private var showMemMenu = false
    @State private var showRegsMenu = false
    @State private var showProgramEditor = false
    @State private var crownValue: Double = 0.0
    @FocusState private var isFocused: Bool
    @FocusState private var isAlphaFocused: Bool
    @State private var alphaInput = ""
    @State private var showDisp = false
    @State private var showModes = false
    @State private var showTestXY = false
    @State private var showTestX0 = false
    @State private var showBaseMenu = false
    @State private var showFlagsMenu = false
    
    @State private var horizontalPage: Int = 1
    @State private var verticalPage: Int = 0
    @State private var dispPrecision: Int = 4
    
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
                        .digitalCrownRotation($crownValue)
                        .onChange(of: crownValue) { old, new in
                            let delta = new - engine.lastCrownValue
                            if abs(delta) > 0.5 {
                                if engine.isProgrammingMode {
                                    showProgramEditor = true
                                } else if engine.isEquationMode {
                                    showEquations = true
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
                        
                    BottomNumpadView(showDisp: $showDisp, showModes: $showModes, showTestXY: $showTestXY, showTestX0: $showTestX0, showBaseMenu: $showBaseMenu, showFlagsMenu: $showFlagsMenu, showingPlot: $showingPlot, showPlotPrompt: $showPlotPrompt, showEquations: $showEquations, showShow: $showShow, showFN: $showFN, showSolve: $showSolve, showIntegrate: $showIntegrate, showClearMenu: $showClearMenu, showProbMenu: $showProbMenu, showPartsMenu: $showPartsMenu, showLRMenu: $showLRMenu, showSumsMenu: $showSumsMenu, showMeanMenu: $showMeanMenu, showStdDevMenu: $showStdDevMenu, showMemMenu: $showMemMenu, showRegsMenu: $showRegsMenu, showXEQ: $showXEQ, showConstMenu: $showConstMenu, horizontalPage: $horizontalPage, verticalPage: $verticalPage)
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
                        }
                        .padding(.top, 40)
                        Spacer()
                    }
                    .zIndex(100) // Ensure it's on top of everything
                }
            }
        )
        .overlay(
            Group {
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
        )
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
        .onChange(of: bindableEngine.isWaitingForAlpha) { oldValue, newValue in
            if newValue && bindableEngine.usesContextualAlphaPad {
                withAnimation {
                    horizontalPage = 0
                    verticalPage = 0
                }
            } else if !newValue {
                withAnimation {
                    horizontalPage = 1
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { bindableEngine.isWaitingForAlpha && !bindableEngine.usesContextualAlphaPad && !bindableEngine.isProgrammingMode },
            set: { if !$0 { bindableEngine.cancelAlpha() } }
        )) {
            NavigationStack {
                Form {
                    Section {
                        TextField(bindableEngine.alphaPrompt ?? "Alpha", text: $alphaInput)
                            .accessibilityIdentifier("tf_alpha_input")
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .onAppear {
                                alphaInput = ""
                            }
                    }
                    
                    Section("Existing") {
                        let existingKeys = bindableEngine.alphaAction == .evalEquation 
                            ? bindableEngine.programs.map(\.label).sorted() 
                            : Array(bindableEngine.variables.keys).sorted()
                            
                        ForEach(existingKeys, id: \.self) { key in
                            Button(key) {
                                bindableEngine.submitAlpha(key)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                .navigationTitle(bindableEngine.alphaPrompt ?? "Alpha")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            bindableEngine.cancelAlpha()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Submit") {
                            bindableEngine.submitAlpha(alphaInput)
                        }
                        .accessibilityIdentifier("btn_alpha_submit")
                    }
                }
            }
        }
        .sheet(isPresented: $showingPlot) {
            FullScreenPlotView()
        }
        .sheet(isPresented: $showPlotPrompt) {
            PlotPromptView()
                .environment(engine)
        }
        .sheet(isPresented: $showEquations) {
            EquationListView(isFNMode: false)
                .environment(engine)
        }
        .sheet(isPresented: $showFN) {
            EquationListView(isFNMode: true)
                .environment(engine)
        }
        .sheet(isPresented: $showSolve) {
            SolvePromptView()
                .environment(engine)
        }
        .sheet(isPresented: $showXEQ) {
            XEQPromptView()
                .environment(engine)
        }
        .sheet(isPresented: $showIntegrate) {
            IntegratePromptView()
                .environment(engine)
        }
        .sheet(isPresented: $showShow) {
            ShowView(rawValue: engine.stack.first?.real ?? 0)
        }
        .sheet(isPresented: $showProgramEditor) {
            ProgramEditorView()
        }
        .sheet(isPresented: $showRegsMenu) {
            RegsMenuView()
                .environment(engine)
        }
        .onChange(of: bindableEngine.isProgrammingMode) { oldValue, newValue in
            if !newValue {
                showProgramEditor = false
            }
        }
        .sheet(isPresented: Binding(
            get: { bindableEngine.currentEvaluatingProgram != nil },
            set: { if !$0 { bindableEngine.currentEvaluatingProgram = nil } }
        )) {
            VariablePromptView()
        }
        .sheet(isPresented: $showDisp) {
            NavigationStack {
                Form {
                    Picker("Precision (Digits)", selection: $dispPrecision) {
                        ForEach(0...9, id: \.self) { val in
                            Text("\(val)").tag(val)
                        }
                    }
                    Button("Fixed Precision (FIX)") { engine.executeMath("FIX \(dispPrecision)"); showDisp = false }
                    Button("Scientific (SCI)") { engine.executeMath("SCI \(dispPrecision)"); showDisp = false }
                    Button("Engineering (ENG)") { engine.executeMath("ENG \(dispPrecision)"); showDisp = false }
                    Button("All (ALL)") { engine.executeMath("ALL"); showDisp = false }
                }
                .navigationTitle("Display")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("C") { showDisp = false }.accessibilityIdentifier("sheet_dismiss_btn")
                    }
                }
            }
        }
        .sheet(isPresented: $showModes) {
            NavigationStack {
                List {
                    Section(header: Text("Angle Mode")) {
                        Button("Degrees (DEG)") { engine.executeMath("DEG"); showModes = false }
                        Button("Radians (RAD)") { engine.executeMath("RAD"); showModes = false }
                        Button("Gradians (GRD)") { engine.executeMath("GRD"); showModes = false }
                    }
                    Section(header: Text("Haptics")) {
                        Button("Mechanical" + (hapticsMode == 0 ? " ✓" : "")) { hapticsMode = 0; showModes = false }
                        Button("Soft" + (hapticsMode == 1 ? " ✓" : "")) { hapticsMode = 1; showModes = false }
                        Button("Muted" + (hapticsMode == 2 ? " ✓" : "")) { hapticsMode = 2; showModes = false }
                    }
                }
                .navigationTitle("Modes")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("C") { showModes = false }.accessibilityIdentifier("sheet_dismiss_btn")
                    }
                }
            }
        }
        .sheet(isPresented: $showTestXY) {
            NavigationStack {
                List {
                    Button("x = y") { engine.executeMath("x=y"); showTestXY = false }
                    Button("x ≠ y") { engine.executeMath("x!=y"); showTestXY = false }
                    Button("x > y") { engine.executeMath("x>y"); showTestXY = false }
                    Button("x < y") { engine.executeMath("x<y"); showTestXY = false }
                    Button("x ≤ y") { engine.executeMath("x<=y"); showTestXY = false }
                }
                .navigationTitle("Test x ? y")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("C") { showTestXY = false }.accessibilityIdentifier("sheet_dismiss_btn") } }
            }
        }
        .sheet(isPresented: $showTestX0) {
            NavigationStack {
                List {
                    Button("x = 0") { engine.executeMath("x=0"); showTestX0 = false }
                    Button("x ≠ 0") { engine.executeMath("x!=0"); showTestX0 = false }
                    Button("x > 0") { engine.executeMath("x>0"); showTestX0 = false }
                    Button("x < 0") { engine.executeMath("x<0"); showTestX0 = false }
                    Button("x ≤ 0") { engine.executeMath("x<=0"); showTestX0 = false }
                }
                .navigationTitle("Test x ? 0")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("C") { showTestX0 = false }.accessibilityIdentifier("sheet_dismiss_btn") } }
            }
        }
        .sheet(isPresented: $showBaseMenu) {
            NavigationStack {
                List {
                    Section("Base") {
                        Button("Hexadecimal (HEX)") { engine.executeMath("HEX"); showBaseMenu = false }
                        Button("Decimal (DEC)") { engine.executeMath("DEC"); showBaseMenu = false }
                        Button("Octal (OCT)") { engine.executeMath("OCT"); showBaseMenu = false }
                        Button("Binary (BIN)") { engine.executeMath("BIN"); showBaseMenu = false }
                    }
                    Section("Bitwise Logic") {
                        Button("AND") { engine.executeOp(.and); showBaseMenu = false }
                        Button("OR") { engine.executeOp(.or); showBaseMenu = false }
                        Button("XOR") { engine.executeOp(.xor); showBaseMenu = false }
                        Button("NOT") { engine.executeOp(.not); showBaseMenu = false }
                    }
                }
                .navigationTitle("Base")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("C") { showBaseMenu = false }.accessibilityIdentifier("sheet_dismiss_btn") } }
            }
        }
        .sheet(isPresented: $showFlagsMenu) {
            FlagsMenuView(engine: engine, isPresented: $showFlagsMenu)
        }
        .sheet(isPresented: $showMeanMenu) {
            NavigationStack {
                List {
                    Button("x̄ (Mean of x)") { engine.executeMath("x-bar"); showMeanMenu = false }
                    Button("ȳ (Mean of y)") { engine.executeMath("y-bar"); showMeanMenu = false }
                    Button("x̄w (Weighted Mean)") { engine.executeMath("xw"); showMeanMenu = false }
                }
                .navigationTitle("MEAN")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("C") { showMeanMenu = false }.accessibilityIdentifier("sheet_dismiss_btn")
                    }
                }
            }
        }
        .sheet(isPresented: $showStdDevMenu) {
            StdDevMenuSheetView(engine: engine, showStdDevMenu: $showStdDevMenu)
        }
        .sheet(isPresented: $showSumsMenu) {
            SumsMenuSheetView(engine: engine, showSumsMenu: $showSumsMenu)
        }
        .sheet(isPresented: $showLRMenu) {
            LRMenuSheetView(engine: engine, showLRMenu: $showLRMenu)
        }

        .sheet(isPresented: $showConstMenu) {
            ConstantsMenuView(engine: engine, isPresented: $showConstMenu)
        }
        .sheet(isPresented: $showPartsMenu) {
            PartsMenuSheetView(engine: engine, showPartsMenu: $showPartsMenu)
        }
        .sheet(isPresented: $showProbMenu) {
            ProbMenuSheetView(engine: engine, showProbMenu: $showProbMenu)
        }
        .sheet(isPresented: $showClearMenu) {
            ClearMenuSheetView(engine: engine, showClearMenu: $showClearMenu)
        }
        .sheet(isPresented: $showMemMenu) {
            MemMenuView()
                .environment(engine)
        }
        .onChange(of: bindableEngine.requestPlot) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingPlot = true
                    bindableEngine.requestPlot = false
                }
            }
        }
        .onChange(of: bindableEngine.requestPlotPrompt) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showPlotPrompt = true
                    bindableEngine.requestPlotPrompt = false
                }
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
        let fontSize = displayHeight * 0.35
        
        return VStack(spacing: 2) {
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
            LCDDisplayView(
                engine: engine,
                font: .system(size: fontSize, weight: .medium, design: .monospaced),
                foregroundColor: themeManager.theme.lcdTextColor
            )
            .padding(.bottom, 2) // small padding so descenders don't touch the absolute bottom edge
            
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
            let isEnterZone = location.x < WKInterfaceDevice.current().screenBounds.width * 0.75
            if isEnterZone {
                hasSeenEnterTip = true
                engine.enter()
            } else {
                engine.backspace()
            }
        }

    }
}




struct FlagsMenuView: View {
    @Bindable var engine: CalculatorEngine
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isPresented: Bool
    @State private var selectedAction = "SF"
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Settings") {
                    Toggle("Exam Mode", isOn: $engine.isExamMode)
                        .tint(.yellow)
                        
                    Picker("Theme", selection: $themeManager.activeThemeType) {
                        ForEach(ThemeType.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    
                    Toggle("Auto-Return to Main Pad", isOn: $engine.autoReturnToMainPad)
                    
                    HStack {
                        Text("Stack Size: \(engine.stackSizeLimit)")
                            .font(.system(size: 14))
                        Spacer()
                        Stepper("", value: $engine.stackSizeLimit, in: 4...100)
                            .labelsHidden()
                    }
                }
                
                Section("Flags (0-11)") {
                    ForEach(0..<12, id: \.self) { i in
                        Toggle(isOn: Bindable(engine).flags[i]) {
                            Text("User Flag \(i)")
                        }
                    }
                }
            }
            .navigationTitle("Flags")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { isPresented = false }.accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
        }
    }
}

struct SumsMenuSheetView: View {
    @Bindable var engine: CalculatorEngine
    @Binding var showSumsMenu: Bool

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Sums")) {
                    Button("n") { engine.executeMath("n"); showSumsMenu = false }
                    Button("Σx") { engine.executeMath("Σx"); showSumsMenu = false }
                    Button("Σy") { engine.executeMath("Σy"); showSumsMenu = false }
                    Button("Σx²") { engine.executeMath("Σx²"); showSumsMenu = false }
                    Button("Σy²") { engine.executeMath("Σy²"); showSumsMenu = false }
                    Button("Σxy") { engine.executeMath("Σxy"); showSumsMenu = false }
                }
                
                if !engine.statPoints.isEmpty {
                    Section(header: Text("Data Points")) {
                        ForEach(Array(engine.statPoints.enumerated()), id: \.offset) { index, point in
                            VStack(alignment: .leading) {
                                Text("X: \(point.x)")
                                Text("Y: \(point.y)")
                            }
                        }
                        .onDelete { offsets in
                            engine.statPoints.remove(atOffsets: offsets)
                        }
                    }
                }
            }
            .navigationTitle("SUMS")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("C") { showSumsMenu = false }.accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
        }
    }
}

struct StdDevMenuSheetView: View {
    @Bindable var engine: CalculatorEngine
    @Binding var showStdDevMenu: Bool

    var body: some View {
        NavigationStack {
            List {
                Button("sx (Sample SD of x)") { engine.executeMath("s"); showStdDevMenu = false }
                Button("sy (Sample SD of y)") { engine.executeMath("sy"); showStdDevMenu = false }
                Button("σx (Population SD of x)") { engine.executeMath("σ"); showStdDevMenu = false }
                Button("σy (Population SD of y)") { engine.executeMath("σy"); showStdDevMenu = false }
            }
            .navigationTitle("STD DEV")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("C") { showStdDevMenu = false }.accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
        }
    }
}

struct LRMenuSheetView: View {
    @Bindable var engine: CalculatorEngine
    @Binding var showLRMenu: Bool

    var body: some View {
        NavigationStack {
            List {
                Button("ŷ,r (Estimate y and Correlation)") { engine.executeMath("ŷ,r"); showLRMenu = false }
                Button("x̂ (Estimate x)") { engine.executeMath("x̂"); showLRMenu = false }
            }
            .navigationTitle("L.R.")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("C") { showLRMenu = false }.accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
        }
    }
}

struct PartsMenuSheetView: View {
    @Bindable var engine: CalculatorEngine
    @Binding var showPartsMenu: Bool

    var body: some View {
        NavigationStack {
            List {
                Button("IP (Integer Part)") { engine.executeOp(.intg); showPartsMenu = false }
                Button("FP (Fractional Part)") { engine.executeOp(.frac); showPartsMenu = false }
                Button("ABS (Absolute Value)") { engine.executeOp(.abs); showPartsMenu = false }
            }
            .navigationTitle("PARTS")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("C") { showPartsMenu = false }.accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
        }
    }
}

struct ProbMenuSheetView: View {
    @Bindable var engine: CalculatorEngine
    @Binding var showProbMenu: Bool

    var body: some View {
        NavigationStack {
            List {
                Button("Cn,r (Combinations)") { engine.executeOp(.nCr); showProbMenu = false }
                Button("Pn,r (Permutations)") { engine.executeOp(.nPr); showProbMenu = false }
                Button("SD (Seed Random)") { engine.executeMath("SD"); showProbMenu = false }
                Button("R# (Random Number)") { engine.executeMath("R#"); showProbMenu = false }
            }
            .navigationTitle("PROB")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("C") { showProbMenu = false }.accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
        }
    }
}

struct ClearMenuSheetView: View {
    @Bindable var engine: CalculatorEngine
    @Binding var showClearMenu: Bool

    var body: some View {
        NavigationStack {
            Form {
                Button("Clear x") { 
                    engine.executeOp(.clear); 
                    showClearMenu = false 
                }
                Button("Clear VARS") { 
                    engine.clearVars(); 
                    showClearMenu = false 
                }
                Button("Clear ALL") { 
                    engine.clearAll(); 
                    showClearMenu = false 
                }
                Button("Clear Σ (Stats)") { 
                    engine.clearStats(); 
                    showClearMenu = false 
                }
            }
            .navigationTitle("Clear")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("C") { showClearMenu = false }.accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
        }
    }
}
