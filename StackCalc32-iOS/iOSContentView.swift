import SwiftUI
import RPNCore

struct iOSContentView: View {
    @State private var deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
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
            let standardLcdHeight: CGFloat = landscape ? (isPad ? 130 : 110) : (isPad ? 160 : 120)
            let isRetro = themeManager.activeThemeType == .retro
            
            // In Retro mode, the LCD is strictly 400x240 (5:3 aspect ratio). To align the 6 menu columns 
            // with the 6 LFU buttons perfectly, the LCD must span the exact same width as the keypad.
            // On the physical device (STL), the keypad is ~84% of the chassis width. So we use 8% bezel on each side.
            let baseNumpadPadHoriz: CGFloat = isPad ? 24 : 8
            let retroNumpadPadHoriz: CGFloat = geo.size.width * 0.08
            let numpadPadHoriz: CGFloat = isRetro ? retroNumpadPadHoriz : baseNumpadPadHoriz
            
            // In Retro mode, the LCD is strictly 400x240 (5:3 aspect ratio).
            // We use the exact 5:3 aspect ratio to ensure no letterboxing padding occurs.
            let retroLcdHeight: CGFloat = min((geo.size.width - (numpadPadHoriz * 2)) * (240.0 / 400.0), geo.size.height * 0.35)
            
            let lcdHeight: CGFloat = isRetro ? retroLcdHeight : standardLcdHeight
            
            let extraPadding: CGFloat = isRetro ? 16 : (landscape ? (isPad ? 132 : 40) : (isPad ? 160 : 125))
            let availableHForNumpad = geo.size.height - lcdHeight - extraPadding
            let maxHMultiplier: CGFloat = isRetro ? 1.35 : 1.1
            let maxH = geo.size.width / totalCols * maxHMultiplier
            let rawH = availableHForNumpad / totalRows
            let h = (isPad || isRetro) ? min(rawH, maxH) : rawH
            
            // In Retro mode, we apply an affine transformation to map the physical FDM faceplate into the available screen height exactly.
            let numpadHeight = isRetro ? availableHForNumpad : (h * totalRows)

            
            mainContent(geo: geo, landscape: landscape, isPad: isPad, numpadHeight: numpadHeight, retroLcdHeight: retroLcdHeight)
        }
        .modifier(KeyboardSupportModifier())
        .modifier(iOSMenuModifier())
        .modifier(AlphaPromptModifier(engine: engine))
        .foregroundColor(.white)
        .opacity(engine.requestPlot ? 1.0 : 1.0)
        .fullScreenCover(isPresented: $showingPlot) {
            FullScreenPlotView()
                .environment(engine)
        }
        .onChange(of: engine.requestPlot) { oldValue, newValue in
            if newValue {
                if themeManager.activeThemeType == .retro {
                    // Let the simulated LCD Hardware grid handle the plot rendering directly!
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        showingPlot = true
                        engine.requestPlot = false
                    }
                }
            }
        }
    }
    
    private func mainContent(geo: GeometryProxy, landscape: Bool, isPad: Bool, numpadHeight: CGFloat, retroLcdHeight: CGFloat) -> AnyView {
        let content = VStack(spacing: 0) {
            if isPad {
                Spacer(minLength: 0)
            }
            
            // Calculator Branding Nameplate
            if !landscape && themeManager.activeThemeType != .retro {
                HStack {
                    if isPad { Spacer() }
                    nameplateView(compact: false)
                        .padding(.horizontal, isPad ? 48 : 24)
                        .padding(.top, isPad ? 32 : 16)
                    if !isPad { Spacer() }
                }
            }
            
            // 1-Line LCD Display (HP32SII style)
            if landscape {
                landscapeView(geo: geo, numpadHeight: numpadHeight, isPad: isPad, retroLcdHeight: retroLcdHeight)
            } else {
                portraitView(geo: geo, numpadHeight: numpadHeight, isPad: isPad, retroLcdHeight: retroLcdHeight)
            }
        }
        
        let bgView: AnyView
        if themeManager.activeThemeType == .retro {
            bgView = AnyView(Color.black.ignoresSafeArea())
        } else if themeManager.activeThemeType == .beta {
            bgView = AnyView(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        } else {
            if landscape {
                bgView = AnyView(Color(white: colorScheme == .dark ? 0.08 : 0.85).ignoresSafeArea())
            } else {
                bgView = AnyView(themeManager.theme.chassisColor.ignoresSafeArea())
            }
        }
        
        return AnyView(
            content.background(bgView)
                .rotationEffect((deviceOrientation == .portraitUpsideDown && UIDevice.current.userInterfaceIdiom == .phone) ? .degrees(180) : .zero)
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    let orientation = UIDevice.current.orientation
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        // Force OS to re-evaluate AppDelegate's supportedInterfaceOrientations
                        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            for window in windowScene.windows {
                                window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                            }
                            UIViewController.attemptRotationToDeviceOrientation()
                            
                            // Fallback to requestGeometryUpdate just in case
                            if orientation == .portraitUpsideDown {
                                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { _ in }
                            } else if orientation.isLandscape || orientation == .portrait {
                                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .allButUpsideDown)) { _ in }
                            }
                        }
                    }
                    withAnimation {
                        deviceOrientation = orientation
                    }
                }
                .onAppear {
                    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                    deviceOrientation = UIDevice.current.orientation
                }
        )
    }
    
    @ViewBuilder
    private func landscapeView(geo: GeometryProxy, numpadHeight: CGFloat, isPad: Bool, retroLcdHeight: CGFloat) -> some View {
        let padAll: CGFloat = isPad ? 24 : 0
        let padHoriz: CGFloat = isPad ? 16 : 0
        let padBottom: CGFloat = isPad ? 16 : 0
        let padTop: CGFloat = isPad ? 16 : 0
        
        let lcdPadHoriz: CGFloat = isPad ? 32 : 16
        let lcdPadTop: CGFloat = isPad ? 32 : 16
        
        let nameplatePadTop: CGFloat = isPad ? 48 : 24
        let nameplatePadTrailing: CGFloat = isPad ? 48 : 24
        
        let baseNumpadPadHoriz: CGFloat = isPad ? 24 : 12
        let numpadPadHoriz: CGFloat = (themeManager.activeThemeType == .retro) ? (geo.size.width * 0.08) : baseNumpadPadHoriz
        let numpadPadBottom: CGFloat = isPad ? 32 : 16
        
        let lcdMaxWidth: CGFloat = .infinity
        
        VStack(alignment: .trailing, spacing: 2) {
            HStack(alignment: .top) {
                if themeManager.activeThemeType == .retro {
                    RetroLCDView(engine: engine)
                        .frame(maxWidth: lcdMaxWidth, maxHeight: retroLcdHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(themeManager.theme.lcdBackgroundColor)
                        )
                        .padding(.horizontal, numpadPadHoriz)
                        .padding(.top, lcdPadTop)
                } else {
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
                            font: .system(size: 46, weight: .regular).monospacedDigit(),
                            foregroundColor: themeManager.theme.lcdTextColor
                        )
                    }
                    .padding()
                    .frame(maxWidth: lcdMaxWidth, maxHeight: isPad ? 130 : 110, alignment: .bottomLeading)
                    .layoutPriority(1)
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
                }
                
                Spacer()
                nameplateView(compact: true)
                    .padding(.top, nameplatePadTop)
                    .padding(.trailing, nameplatePadTrailing)
            }
            
            if themeManager.activeThemeType != .retro {
                Spacer(minLength: 16)
            }
            
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
    private func portraitView(geo: GeometryProxy, numpadHeight: CGFloat, isPad: Bool, retroLcdHeight: CGFloat) -> some View {
        let lcdPadHoriz: CGFloat = isPad ? 32 : 16
        let lcdPadTop: CGFloat = isPad ? 32 : 16
        let lcdMaxWidth: CGFloat = isPad ? 600 : .infinity
        let lcdMaxHeight: CGFloat = isPad ? 160 : 120
        let lcdFontSize: CGFloat = isPad ? 56 : 46
        
        let baseNumpadPadHoriz: CGFloat = isPad ? 24 : 8
        let numpadPadHoriz: CGFloat = (themeManager.activeThemeType == .retro) ? (geo.size.width * 0.08) : baseNumpadPadHoriz
        let numpadPadBottom: CGFloat = isPad ? 48 : 32
        
        if themeManager.activeThemeType == .retro {
            RetroLCDView(engine: engine)
                .frame(maxWidth: .infinity, maxHeight: retroLcdHeight)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(themeManager.theme.lcdBackgroundColor)
                )
                .padding(.horizontal, numpadPadHoriz)
                .padding(.top, lcdPadTop)
        } else {
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
                    font: .system(size: lcdFontSize, weight: .regular).monospacedDigit(),
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
        }

        
        
        if themeManager.activeThemeType != .retro {
            Spacer(minLength: 16)
        }
        
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
                Text("StackCalc")
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
                Text("STACK CALCULATOR")
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
    
    @EnvironmentObject var themeManager: ThemeManager

    func body(content: Content) -> some View {
        if CommandLine.arguments.contains("-UITesting") {
            return AnyView(content)
        }
        return AnyView(content
            .sheet(isPresented: Binding(
                get: { engine.isWaitingForAlpha && !engine.usesContextualAlphaPad && !engine.isEquationEditMode && themeManager.activeThemeType != .retro },
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
    case base, testXY, testX0, mean, sums, stdDev, lr, parts, prob, clear, flags, regs, mem, const, disp, modes, eqn, show, integrate, solve
    var id: String { self.rawValue }

    /// Maps this ActiveMenu to the corresponding RPNCore CalculatorMenu, if one exists.
    /// Menus that return nil have presentations outside CalculatorMenuPresenter
    /// (show, eqn, regs, plot, integrate, solve, xeq).
    var calculatorMenu: CalculatorMenu? {
        switch self {
        case .disp:    return .disp
        case .modes:   return .modes
        case .base:    return .base
        case .testXY:  return .testXY
        case .testX0:  return .testX0
        case .mean:    return .statMean
        case .sums:    return .sums
        case .stdDev:  return .statStdDev
        case .lr:      return .lr
        case .parts:   return .parts
        case .prob:    return .prob
        case .clear:   return .clear   // bespoke in CalculatorMenuPresenter (confirm dialog)
        case .flags:   return .flags   // bespoke in CalculatorMenuPresenter (toggles)
        case .mem:     return .mem     // bespoke in CalculatorMenuPresenter (readout)
        case .const:   return .const   // bespoke in CalculatorMenuPresenter (searchable)
        default:       return nil
        }
    }
}

struct iOSMenuModifier: ViewModifier {
    @Environment(CalculatorEngine.self) var engine
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var activeMenu: ActiveMenu?
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
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("iOSThemeChangeTrigger"))) { _ in
                let allThemes = ThemeType.allCases
                if let currentIndex = allThemes.firstIndex(of: themeManager.activeThemeType) {
                    let nextIndex = (currentIndex + 1) % allThemes.count
                    themeManager.activeThemeType = allThemes[nextIndex]
                }
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
            // .regs uses a bespoke scrollable register table, not a CalculatorMenu.items list.
            return AnyView(NavigationStack { RegsMenuView() }.environment(engine).presentationDetents([.medium, .large]))
        case .eqn:
            return AnyView(NavigationStack {
                EquationEditorView(isPresented: Binding(
                    get: { activeMenu == .eqn },
                    set: { if !$0 { activeMenu = nil } }
                ))
                .environment(engine)
                .environmentObject(themeManager)
            })
        case .integrate:
            return AnyView(IntegratePromptView().environment(engine))
        case .solve:
            return AnyView(SolvePromptView().environment(engine))
        default:
            // Generic menus — delegate to shared CalculatorMenuPresenter
            if let calcMenu = menu.calculatorMenu {
                return AnyView(
                    CalculatorMenuPresenter(
                        menu: calcMenu,
                        isPresented: Binding(
                            get: { activeMenu != nil },
                            set: { if !$0 { activeMenu = nil } }
                        )
                    )
                    .environment(engine)
                    .presentationDetents([.medium, .large])
                )
            }
            return AnyView(EmptyView())
        }
    }
    
    private func handleMenuCommand(_ command: CalculatorOperation) {
        if themeManager.activeThemeType == .retro {
            if command == .flags {
                activeMenu = .flags
            }
            // Retro theme processes all other menu commands via RetroUIController directly on the pixel LCD.
            return
        }
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
        case .show: activeMenu = .show
        case .integrate: activeMenu = .integrate
        case .solve: activeMenu = .solve
        case .lfu0, .lfu1, .lfu2, .lfu3, .lfu4, .lfu5:
            let index = command.rawValue - CalculatorOperation.lfu0.rawValue
            let funcStr = engine.lfuManager.getFunction(for: index)
            if !funcStr.isEmpty {
                engine.executeMath(funcStr)
            }
        default:
            print("Unhandled iOS Menu: \(command)")
        }
    }

}


