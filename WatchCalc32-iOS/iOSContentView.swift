import SwiftUI
import RPNCore

struct iOSContentView: View {
    @Environment(CalculatorEngine.self) var engine
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.colorScheme) var colorScheme
    
    
    @State private var showingPlot = false
    
    func isLandscape(geo: GeometryProxy) -> Bool {
        return geo.size.width > geo.size.height
    }

    var body: some View {
        GeometryReader { geo in
            let landscape = isLandscape(geo: geo)
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            
            // Calculate exact height for keypad to prevent GeometryReader from ballooning empty space
            let totalCols: CGFloat = landscape ? 11 : 6
            let totalRows: CGFloat = landscape ? 4 : 8
            let lcdHeight: CGFloat = landscape ? (isPad ? 130 : 90) : (isPad ? 160 : 120)
            let extraPadding: CGFloat = landscape ? (isPad ? 132 : 40) : (isPad ? 160 : 125)
            let availableHForNumpad = geo.size.height - lcdHeight - extraPadding
            let maxH = geo.size.width / totalCols * 1.1
            let rawH = availableHForNumpad / totalRows
            let h = isPad ? min(rawH, maxH) : rawH
            let numpadHeight = h * totalRows
            
            mainContent(geo: geo, landscape: landscape, isPad: isPad, numpadHeight: numpadHeight)
        }
        .modifier(KeyboardSupportModifier())
        .modifier(iOSMenuModifier())
        .modifier(AlphaPromptModifier(engine: engine))
        .foregroundColor(.white)
        .sheet(isPresented: $showingPlot) {
            FullScreenPlotView()
                .environment(engine)
        }
        .onChange(of: engine.requestPlot) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showingPlot = true
                    engine.requestPlot = false
                }
            }
        }
    }
    
    private func mainContent(geo: GeometryProxy, landscape: Bool, isPad: Bool, numpadHeight: CGFloat) -> AnyView {
        let content = VStack(spacing: 0) {
            if isPad {
                Spacer(minLength: 0)
            }
            
            // Calculator Branding Nameplate
            if !landscape && !isPad {
                nameplateView(compact: false)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
            }
            
            // 1-Line LCD Display (HP32SII style)
            if landscape {
                landscapeView(geo: geo, numpadHeight: numpadHeight, isPad: isPad)
            } else {
                portraitView(geo: geo, numpadHeight: numpadHeight, isPad: isPad)
            }
        }
        
        let bgView: AnyView
        if themeManager.activeThemeType == .beta {
            bgView = AnyView(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        } else {
            if landscape {
                bgView = AnyView(Color(white: colorScheme == .dark ? 0.08 : 0.85).ignoresSafeArea())
            } else {
                bgView = AnyView(themeManager.theme.chassisColor.ignoresSafeArea())
            }
        }
        
        return AnyView(content.background(bgView))
    }
    
    @ViewBuilder
    private func landscapeView(geo: GeometryProxy, numpadHeight: CGFloat, isPad: Bool) -> some View {
        let padAll: CGFloat = isPad ? 24 : 0
        let padHoriz: CGFloat = isPad ? 16 : 0
        let padBottom: CGFloat = isPad ? 16 : 0
        let padTop: CGFloat = isPad ? 16 : 0
        
        let lcdPadHoriz: CGFloat = isPad ? 32 : 16
        let lcdPadTop: CGFloat = isPad ? 32 : 16
        
        let nameplatePadTop: CGFloat = isPad ? 48 : 24
        let nameplatePadTrailing: CGFloat = isPad ? 48 : 24
        
        let numpadPadHoriz: CGFloat = isPad ? 24 : 12
        let numpadPadBottom: CGFloat = isPad ? 32 : 16
        
        let lcdMaxWidth: CGFloat = .infinity
        
        VStack(alignment: .trailing, spacing: 2) {
            HStack(alignment: .top) {
                
                VStack(alignment: .trailing, spacing: 2) {
                    LCDAnnunciatorsView(
                        engine: engine,
                        font: .system(size: 12, weight: .bold),
                        foregroundColor: themeManager.theme.lcdTextColor.opacity(0.6),
                        yellowShiftColor: themeManager.theme.yellowShiftColor,
                        blueShiftColor: themeManager.theme.blueShiftColor,
                        shift1Label: themeManager.theme.shift1Label,
                        shift2Label: themeManager.theme.shift2Label,
                        spacing: 12
                    )
                    .padding(.horizontal, 8)
                    Spacer()
                    LCDDisplayView(
                        engine: engine,
                        font: .system(size: 38, weight: .medium, design: .monospaced),
                        foregroundColor: themeManager.theme.lcdTextColor
                    )
                }
                .padding()
                .frame(maxWidth: lcdMaxWidth, maxHeight: 90, alignment: .bottomLeading)
                .background(
                    AnyView(
                        Group {
                            if themeManager.activeThemeType == .beta {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white.opacity(0.05))
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(.ultraThinMaterial)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themeManager.theme.lcdBackgroundColor.shadow(.inner(color: themeManager.theme.lcdTextColor.opacity(0.6), radius: 4, x: 0, y: 3)))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(LinearGradient(gradient: Gradient(colors: [.black.opacity(0.5), .black.opacity(0.1), .white.opacity(0.2)]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
                                    )
                            }
                        }
                    )
                )
                .padding(.horizontal, lcdPadHoriz)
                .padding(.top, lcdPadTop)
                
                Spacer()
                nameplateView(compact: true)
                    .padding(.top, nameplatePadTop)
                    .padding(.trailing, nameplatePadTrailing)
            }
            
            Spacer(minLength: 16)
            
            HapticNumpadView(onMenuAction: { command in
                NotificationCenter.default.post(name: NSNotification.Name("iOSMenuTrigger"), object: nil, userInfo: ["command": command])
            }, keys: HP32KeyMap.landscapeGrid)
            .frame(height: numpadHeight)
            .padding(.horizontal, numpadPadHoriz)
            .padding(.bottom, numpadPadBottom)
        }
        .padding(.top, padTop)
        .background(
            AnyView(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(themeManager.theme.chassisColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
            )
        )
        .padding(padAll)
        .padding(.horizontal, padHoriz)
        .padding(.bottom, padBottom)
    }

    @ViewBuilder
    private func portraitView(geo: GeometryProxy, numpadHeight: CGFloat, isPad: Bool) -> some View {
        let lcdPadHoriz: CGFloat = isPad ? 32 : 16
        let lcdPadTop: CGFloat = isPad ? 32 : 16
        let lcdMaxWidth: CGFloat = isPad ? 600 : .infinity
        let lcdMaxHeight: CGFloat = isPad ? 160 : 120
        let lcdFontSize: CGFloat = isPad ? 48 : 42
        
        let numpadPadHoriz: CGFloat = isPad ? 24 : 8
        let numpadPadBottom: CGFloat = isPad ? 48 : 32
        
        VStack(alignment: .trailing, spacing: 2) {
            LCDAnnunciatorsView(
                engine: engine,
                font: .system(size: 12, weight: .bold),
                foregroundColor: themeManager.theme.lcdTextColor.opacity(0.6),
                yellowShiftColor: themeManager.theme.yellowShiftColor,
                blueShiftColor: themeManager.theme.blueShiftColor,
                shift1Label: themeManager.theme.shift1Label,
                shift2Label: themeManager.theme.shift2Label,
                spacing: 12
            )
            .padding(.horizontal, 8)
            Spacer()
            LCDDisplayView(
                engine: engine,
                font: .system(size: lcdFontSize, weight: .medium, design: .monospaced),
                foregroundColor: themeManager.theme.lcdTextColor
            )
        }
        .padding()
        .frame(maxWidth: lcdMaxWidth, maxHeight: .infinity, alignment: .bottomTrailing)
        .frame(maxHeight: lcdMaxHeight)
        .background(
            AnyView(
                Group {
                    if themeManager.activeThemeType == .beta {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.primary.opacity(0.08))
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.theme.lcdBackgroundColor.shadow(.inner(color: themeManager.theme.lcdTextColor.opacity(0.6), radius: 4, x: 0, y: 3)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(LinearGradient(gradient: Gradient(colors: [.black.opacity(0.5), .black.opacity(0.1), .white.opacity(0.2)]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
                            )
                    }
                }
            )
        )
        .padding(.horizontal, lcdPadHoriz)
        .padding(.top, lcdPadTop)
        
        if isPad {
            HStack {
                Spacer()
                nameplateView()
                    .padding(.top, 32)
                    .padding(.trailing, 48)
            }
        }
        
        Spacer(minLength: 16)
        
        HapticNumpadView(onMenuAction: { command in
            NotificationCenter.default.post(name: NSNotification.Name("iOSMenuTrigger"), object: nil, userInfo: ["command": command])
        }, keys: HP32KeyMap.standardGrid)
        .frame(height: numpadHeight)
        .padding(.horizontal, numpadPadHoriz)
        .padding(.bottom, numpadPadBottom)
    }

    private func nameplateView(compact: Bool = false) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: -4) {
                Text("WatchCalc")
                    .font(.system(size: 16, weight: .black, design: .default))
                    .italic()
                    .foregroundColor(themeManager.theme.functionTextColor)
                Text("32")
                    .font(.system(size: 28, weight: .black, design: .default))
                    .italic()
                    .foregroundColor(themeManager.theme.blueShiftColor)
            }
            if !compact {
                Spacer()
                Text("RPN SCIENTIFIC CALCULATOR")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(themeManager.theme.functionTextColor.opacity(0.6))
                    .padding(.top, 6)
            }
        }
    }
}

struct AlphaPromptModifier: ViewModifier {
    @Bindable var engine: CalculatorEngine
    @State private var alphaInput: String = ""
    
    func body(content: Content) -> some View {
        if CommandLine.arguments.contains("-UITesting") {
            return AnyView(content)
        }
        return AnyView(content
            .sheet(isPresented: Binding(
                get: { engine.isWaitingForAlpha && !engine.usesContextualAlphaPad && !engine.isProgrammingMode },
                set: { if !$0 { engine.cancelAlpha() } }
            )) {
                NavigationStack {
                    Form {
                        Section {
                            TextField(engine.alphaPrompt, text: $alphaInput)
                                .textInputAutocapitalization(.characters)
                                .disableAutocorrection(true)
                                .onSubmit {
                                    if !alphaInput.isEmpty {
                                        engine.submitAlpha(alphaInput)
                                        alphaInput = ""
                                    }
                                }
                        }
                    }
                    .navigationTitle(engine.alphaPrompt)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                engine.isWaitingForAlpha = false
                                alphaInput = ""
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Submit") {
                                if alphaInput.isEmpty { alphaInput = "A" }
                                engine.submitAlpha(alphaInput)
                                alphaInput = ""
                            }
                            .bold()
                        }
                    }
                }
                .tint(.blue)
                .foregroundColor(.primary)
                .presentationDetents([.medium])
            })
    }
}

struct KeyboardSupportModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(KeyCommandReceiver())
    }
}

struct KeyCommandReceiver: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> KeyCommandViewController {
        return KeyCommandViewController()
    }
    
    func updateUIViewController(_ uiViewController: KeyCommandViewController, context: Context) {}
}

class KeyCommandViewController: UIViewController {
    override var canBecomeFirstResponder: Bool { true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    override var keyCommands: [UIKeyCommand]? {
        var commands = [UIKeyCommand]()
        let keys = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "+", "-", "*", "/", "=", "e", "c"]
        for key in keys {
            commands.append(UIKeyCommand(input: key, modifierFlags: [], action: #selector(handleKeyCommand(_:))))
        }
        commands.append(UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(handleKeyCommand(_:))))
        commands.append(UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(handleKeyCommand(_:))))
        commands.append(UIKeyCommand(input: UIKeyCommand.inputDelete, modifierFlags: [], action: #selector(handleKeyCommand(_:))))
        return commands
    }
    
    @objc func handleKeyCommand(_ command: UIKeyCommand) {
        var cmd = command.input ?? ""
        if cmd == "\r" || cmd == "=" { cmd = "ENTER" }
        if cmd == UIKeyCommand.inputEscape || cmd == "c" { cmd = "C" }
        if cmd == UIKeyCommand.inputDelete { cmd = "<-" }
        if cmd == "e" { cmd = "E" }
        if cmd == "*" { cmd = "×" }
        
        NotificationCenter.default.post(name: NSNotification.Name("iOSMenuTrigger"), object: nil, userInfo: ["command": mapOp(cmd)])
    }
}

enum ActiveMenu: String, Identifiable {
    case base, testXY, testX0, mean, sums, stdDev, lr, parts, prob, clear, flags, regs, mem, const, disp, modes, eqn, plot, show, integrate, solve, xeq
    var id: String { self.rawValue }
}

struct iOSMenuModifier: ViewModifier {
    @Environment(CalculatorEngine.self) var engine
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var activeMenu: ActiveMenu?
    @State private var dispPrecision: Int = 4
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("iOSMenuTrigger"))) { notification in
                if let command = notification.userInfo?["command"] as? CalculatorOperation {
                    handleMenuCommand(command)
                }
            }
            .sheet(item: $activeMenu) { menu in
                presentMenu(menu)
                    .foregroundColor(.primary)
            }
    }
    
    private func presentMenu(_ menu: ActiveMenu) -> AnyView {
        switch menu {
        case .show:
            // Full-precision SHOW sheet — mirrors Watch's ShowView exactly.
            // Read engine.stack.first directly so value is always current.
            return AnyView(
                NavigationStack {
                    ScrollView {
                        Text(String(engine.stack.first?.real ?? 0.0))
                            .font(.system(size: 32, weight: .medium, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .textSelection(.enabled)
                    }
                    .navigationTitle("SHOW")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { activeMenu = nil }
                        }
                    }
                }
                .presentationDetents([.medium])
            )
        case .regs:
            return AnyView(NavigationStack { RegsMenuView() }.presentationDetents([.medium, .large]))
        case .mem:
            return AnyView(NavigationStack { MemMenuView() }.presentationDetents([.medium, .large]))
        case .const:
            return AnyView(
                ConstantsMenuView(engine: engine, isPresented: Binding(
                    get: { activeMenu == .const },
                    set: { if !$0 { activeMenu = nil } }
                ))
                .presentationDetents([.large])
            )
        case .eqn:
            return AnyView(NavigationStack {
                EquationListView(isPresented: Binding(
                    get: { activeMenu == .eqn },
                    set: { if !$0 { activeMenu = nil } }
                ))
                .environment(engine)
                .environmentObject(themeManager)
            })
        case .plot:
            // PlotPromptView (from Watch target, compiled into iOS via shared Sources)
            return AnyView(PlotPromptView().environment(engine))
        case .integrate:
            return AnyView(IntegratePromptView().environment(engine))
        case .solve:
            return AnyView(SolvePromptView().environment(engine))
        case .xeq:
            return AnyView(XEQPromptView().environment(engine))
        default:
            return AnyView(
                NavigationStack {
                    menuView(for: menu)
                }
                .tint(.blue)
                .foregroundColor(.primary)
            )
        }
    }
    
    private func menuView(for menu: ActiveMenu) -> AnyView {
        switch menu {
        case .disp:
            if let calcMenu = CalculatorMenu(rawValue: "DISP") {
                return AnyView(Form {
                    Picker("Precision (Digits)", selection: $dispPrecision) {
                        ForEach(0...9, id: \.self) { val in
                            Text("\(val)").tag(val)
                        }
                    }
                    ForEach(calcMenu.items, id: \.label) { item in
                        Button("\(item.label)") {
                            if item.requiresDigit {
                                engine.executeMath("\(item.action) \(dispPrecision)")
                            } else {
                                engine.executeMath(item.action)
                            }
                            activeMenu = nil
                        }
                    }
                }.navigationTitle("Display"))
            } else { return AnyView(EmptyView()) }
        case .modes:
            if let calcMenu = CalculatorMenu(rawValue: "MODES") {
                return AnyView(List {
                    ForEach(calcMenu.items, id: \.label) { item in
                        Button(item.label) { engine.executeMath(item.action); activeMenu = nil }
                    }
                }.navigationTitle("Modes"))
            } else { return AnyView(EmptyView()) }
        case .base:
            if let calcMenu = CalculatorMenu(rawValue: "BASE") {
                return AnyView(List {
                    Section("Base") {
                        ForEach(calcMenu.items, id: \.label) { item in
                            Button(item.label) { engine.executeMath(item.action); activeMenu = nil }
                        }
                    }
                    Section("Bitwise Logic") {
                        Button("AND") { engine.executeOp(.and); activeMenu = nil }
                        Button("OR") { engine.executeOp(.or); activeMenu = nil }
                        Button("XOR") { engine.executeOp(.xor); activeMenu = nil }
                        Button("NOT") { engine.executeOp(.not); activeMenu = nil }
                    }
                }.navigationTitle("Base"))
            } else { return AnyView(EmptyView()) }
        case .testXY:
            if let calcMenu = CalculatorMenu(rawValue: "x?y") {
                return AnyView(List {
                    ForEach(calcMenu.items, id: \.label) { item in
                        Button(item.label) { engine.executeMath(item.action); activeMenu = nil }
                    }
                }.navigationTitle("Test x ? y"))
            } else { return AnyView(EmptyView()) }
        case .testX0:
            if let calcMenu = CalculatorMenu(rawValue: "x?0") {
                return AnyView(List {
                    ForEach(calcMenu.items, id: \.label) { item in
                        Button(item.label) { engine.executeMath(item.action); activeMenu = nil }
                    }
                }.navigationTitle("Test x ? 0"))
            } else { return AnyView(EmptyView()) }
        case .mean:
            return AnyView(List {
                Button("x̄ (Mean of x)") { engine.executeMath("x-bar"); activeMenu = nil }
                Button("ȳ (Mean of y)") { engine.executeMath("y-bar"); activeMenu = nil }
                Button("x̄w (Weighted Mean)") { engine.executeMath("xw"); activeMenu = nil }
            }
            .navigationTitle("MEAN"))
        case .sums:
            return AnyView(List {
                Section("Sums") {
                    Button("n") { engine.executeMath("n"); activeMenu = nil }
                    Button("Σx") { engine.executeMath("Σx"); activeMenu = nil }
                    Button("Σy") { engine.executeMath("Σy"); activeMenu = nil }
                    Button("Σx²") { engine.executeMath("Σx²"); activeMenu = nil }
                    Button("Σy²") { engine.executeMath("Σy²"); activeMenu = nil }
                    Button("Σxy") { engine.executeMath("Σxy"); activeMenu = nil }
                }
            }
            .navigationTitle("SUMS"))
        case .stdDev:
            return AnyView(List {
                Button("sx (Sample SD of x)") { engine.executeMath("s"); activeMenu = nil }
                Button("sy (Sample SD of y)") { engine.executeMath("sy"); activeMenu = nil }
                Button("σx (Population SD of x)") { engine.executeMath("σx"); activeMenu = nil }
                Button("σy (Population SD of y)") { engine.executeMath("σy"); activeMenu = nil }
            }
            .navigationTitle("Std Dev"))
        case .lr:
            return AnyView(List {
                Button("ŷ (Estimate y)") { engine.executeMath("y-hat"); activeMenu = nil }
                Button("x̂ (Estimate x)") { engine.executeMath("x-hat"); activeMenu = nil }
                Button("r (Correlation)") { engine.executeMath("r"); activeMenu = nil }
                Button("m (Slope)") { engine.executeMath("m"); activeMenu = nil }
                Button("b (Y-Intercept)") { engine.executeMath("b"); activeMenu = nil }
            }
            .navigationTitle("Linear Reg"))
        case .parts:
            return AnyView(List {
                Button("Integer Part") { engine.executeOp(.intg); activeMenu = nil }
                Button("Fractional Part") { engine.executeOp(.frac); activeMenu = nil }
                Button("Absolute Value") { engine.executeOp(.abs); activeMenu = nil }
                Button("Round") { engine.executeOp(.rnd); activeMenu = nil }
            }
            .navigationTitle("Parts"))
        case .prob:
            return AnyView(List {
                Button("Cn,r (Combinations)") { engine.executeOp(.nCr); activeMenu = nil }
                Button("Pn,r (Permutations)") { engine.executeOp(.nPr); activeMenu = nil }
                Button("SD (Seed Random)") { engine.executeMath("SD"); activeMenu = nil }
                Button("R# (Random Number)") { engine.executeMath("R#"); activeMenu = nil }
            }
            .navigationTitle("Probability"))
        case .clear:
            return AnyView(List {
                Button("Clear X") { engine.executeOp(.clear); activeMenu = nil }
                Button("Clear Statistics (Σ)") { engine.executeMath("CLΣ"); activeMenu = nil }
                Button("Clear ALL") { engine.executeMath("CLALL"); activeMenu = nil }
            }
            .navigationTitle("Clear"))
        case .flags:
            return AnyView(FlagsMenuView(engine: engine).environmentObject(themeManager))
        case .regs, .mem, .const, .eqn, .plot, .show, .integrate, .solve, .xeq:
            return AnyView(EmptyView())
        }
    }
    
    private func handleMenuCommand(_ command: CalculatorOperation) {
        switch command {
        case .base: activeMenu = .base
        case .flags: activeMenu = .flags
        case .testXY: activeMenu = .testXY
        case .testX0: activeMenu = .testX0
        case .clear: activeMenu = .clear
        case .prob: activeMenu = .prob
        case .parts: activeMenu = .parts
        case .lr: activeMenu = .lr
        case .sums: activeMenu = .sums
        case .statMean: activeMenu = .mean
        case .statStdDev: activeMenu = .stdDev
        case .regs: activeMenu = .regs
        case .mem: activeMenu = .mem
        case .const: activeMenu = .const
        case .disp: activeMenu = .disp
        case .modes: activeMenu = .modes
        case .eqn: activeMenu = .eqn
        case .fnEq: activeMenu = .eqn
        case .plot: activeMenu = .plot
        case .show: activeMenu = .show
        case .integrate: activeMenu = .integrate
        case .solve: activeMenu = .solve
        case .xeq: activeMenu = .xeq
        default:
            print("Unhandled iOS Menu: \(command)")
        }
    }
}

struct FlagsMenuView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @Bindable var engine: CalculatorEngine
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    
    var body: some View {
        List {
            Section("Settings") {
                Toggle("Exam Mode", isOn: $engine.isExamMode)
                    .tint(.yellow)
                Toggle("Enable Haptics", isOn: $hapticsEnabled)
                    .tint(.blue)
                Picker("Theme", selection: $themeManager.activeThemeType) {
                    ForEach(ThemeType.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                Stepper(value: $engine.stackSizeLimit, in: 4...100) {
                    Text("Stack Size Limit: \(engine.stackSizeLimit)")
                }
            }
            Section("Flags (0-11)") {
                ForEach(0..<12, id: \.self) { i in
                    Toggle(isOn: $engine.flags[i]) {
                        Text("User Flag \(i)")
                    }
                }
            }
        }
        .navigationTitle("Flags")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(Color(red: 0.5, green: 0.35, blue: 0.25))
            }
        }
    }
}



