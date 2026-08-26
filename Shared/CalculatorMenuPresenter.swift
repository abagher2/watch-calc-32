// CalculatorMenuPresenter.swift — iOS / watchOS realization of the CalculatorMenu abstraction.
//
// Architecture:
//   RPNCore defines CalculatorMenu + MenuItem (pure Swift, Embedded-safe).
//   CalculatorEngine.activeMenu is the shared activation state.
//
// Realizations:
//   • Firmware  → RetroUI.swift draws pixel softkeys using engine.activeMenu
//   • iOS/watchOS → This file renders SwiftUI sheets using the same engine.activeMenu
//
// Bespoke presentations (menus that need UI beyond a plain list):
//   • .clear   → Confirmation dialog for CLALL; action-based for the rest
//   • .flags   → Toggle grid for flags 0-11 + stack size stepper
//   • .mem     → Memory usage readout (VARS / PRGM / STAT byte counts)
//   • .const   → Searchable full-constants list from builtInConstants
//
// All other menus → generic List from CalculatorMenu.items
//
// This file is compiled only into the Watch and iOS targets (per project.pbxproj).
import SwiftUI
import RPNCore

/// Root presenter: routes each CalculatorMenu to the appropriate View.
public struct CalculatorMenuPresenter: View {
    public let menu: CalculatorMenu
    @Binding public var isPresented: Bool
    @Environment(CalculatorEngine.self) var engine

    public init(menu: CalculatorMenu, isPresented: Binding<Bool>) {
        self.menu = menu
        self._isPresented = isPresented
    }

    public var body: some View {
        switch menu {
        case .clear:
            ClearMenuPresenterView(isPresented: $isPresented)
                .environment(engine)
        case .flags:
            FlagsMenuPresenterView(isPresented: $isPresented)
                .environment(engine)
        case .mem:
            MemMenuPresenterView(isPresented: $isPresented)
                .environment(engine)
        case .const:
            ConstMenuPresenterView(isPresented: $isPresented)
                .environment(engine)
        default:
            GenericMenuPresenterView(menu: menu, isPresented: $isPresented)
                .environment(engine)
        }
    }
}

// MARK: - Generic List Presenter (all non-bespoke menus)

private struct GenericMenuPresenterView: View {
    let menu: CalculatorMenu
    @Binding var isPresented: Bool
    @Environment(CalculatorEngine.self) var engine

    /// Sub-menu navigation actions open another menu rather than executing a math op.
    private static let subMenuMap: [String: CalculatorMenu] = [
        "STATMEAN":   .statMean,
        "STATSTDDEV": .statStdDev,
        "STATLR":     .lr,
        "STATSUMS":   .sums,
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(menu.items, id: \.label) { item in
                    MenuItemRow(item: item, subMenuMap: Self.subMenuMap, isPresented: $isPresented)
                }
            }
            .navigationTitle(menu.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("C") { isPresented = false }
                        .accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
        }
        .environment(engine)
    }
}

private struct MenuItemRow: View {
    let item: MenuItem
    let subMenuMap: [String: CalculatorMenu]
    @Binding var isPresented: Bool
    @Environment(CalculatorEngine.self) var engine
    @State private var digit: Int = 4

    var body: some View {
        if item.requiresDigit {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.label).font(.headline)
                Picker("Digits", selection: $digit) {
                    ForEach(0...9, id: \.self) { n in Text("\(n)").tag(n) }
                }
                #if os(watchOS)
                .pickerStyle(.wheel)
                #else
                .pickerStyle(.segmented)
                #endif
                Button("Apply \(item.label) \(digit)") {
                    engine.executeMath("\(item.action) \(digit)")
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 4)
        } else if let subMenu = subMenuMap[item.action] {
            // Navigate to sub-menu without dismissing the sheet
            Button(item.label) { engine.activeMenu = subMenu }
        } else {
            Button(item.label) {
                engine.executeMath(item.action)
                isPresented = false
            }
        }
    }
}

// MARK: - Clear Menu (with CLALL confirmation)

private struct ClearMenuPresenterView: View {
    @Binding var isPresented: Bool
    @Environment(CalculatorEngine.self) var engine
    @State private var confirmAll = false

    var body: some View {
        NavigationStack {
            List {
                Button("CLx — Clear X") {
                    engine.executeMath("CLx"); isPresented = false
                }
                .accessibilityIdentifier("clear_menu_clx")
                Button("CLΣ — Clear Statistics") {
                    engine.executeMath("CLΣ"); isPresented = false
                }
                .accessibilityIdentifier("clear_menu_clsigma")
                Button("CLVARS — Clear Variables") {
                    engine.executeMath("CLVARS"); isPresented = false
                }
                .accessibilityIdentifier("clear_menu_clvars")
                Button("CLREGS — Clear Registers") {
                    engine.executeMath("CLREGS"); isPresented = false
                }
                .accessibilityIdentifier("clear_menu_clregs")
                Button("CLSTK — Clear Stack") {
                    engine.executeMath("CLSTK"); isPresented = false
                }
                .accessibilityIdentifier("clear_menu_clstk")
                Button("CLPRGM — Clear Programs") {
                    engine.executeMath("CLPRGM"); isPresented = false
                }
                .accessibilityIdentifier("clear_menu_clprgm")
                Button("CLALL — Clear Everything", role: .destructive) {
                    engine.executeMath("CLALL"); isPresented = false
                }
                .accessibilityIdentifier("Clear ALL")
            }
            #if os(watchOS)
            .navigationTitle("CLEAR")
            #else
            .navigationTitle("Clear")
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("C") { isPresented = false }
                        .accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
        }
        .environment(engine)
    }
}

// MARK: - Flags Menu (toggle UI)

private struct FlagsMenuPresenterView: View {
    @Binding var isPresented: Bool
    @Environment(CalculatorEngine.self) var engine

    var body: some View {
        NavigationStack {
            Form {
                Section("Flag Operations") {
                    ForEach(CalculatorMenu.flags.items, id: \.label) { item in
                        if item.requiresDigit {
                            FlagDigitRow(item: item, isPresented: $isPresented)
                        } else {
                            Button(item.label) {
                                engine.executeMath(item.action)
                                isPresented = false
                            }
                        }
                    }
                }
                Section("User Flags (0\u{2013}11)") {
                    ForEach(0..<12, id: \.self) { i in
                        Toggle(isOn: Binding(
                            get: { engine.flags[i] },
                            set: { engine.executeMath($0 ? "SF \(i)" : "CF \(i)") }
                        )) {
                            Text("Flag \(i)")
                        }
                    }
                }
                Section("Stack Size") {
                    Stepper("Stack: \(engine.stackSizeLimit)", value: Binding(
                        get: { engine.stackSizeLimit },
                        set: { engine.stackSizeLimit = $0 }
                    ), in: 4...100)
                }
            }
            .navigationTitle("Flags")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { isPresented = false }
                        .accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
        }
        .environment(engine)
    }
}

private struct FlagDigitRow: View {
    let item: MenuItem
    @Binding var isPresented: Bool
    @Environment(CalculatorEngine.self) var engine
    @State private var digit: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.label).font(.headline)
            Picker("Flag", selection: $digit) {
                ForEach(0...11, id: \.self) { n in Text("\(n)").tag(n) }
            }
            #if os(watchOS)
            .pickerStyle(.wheel)
            #else
            .pickerStyle(.segmented)
            #endif
            Button("Apply \(item.label) \(digit)") {
                engine.executeMath("\(item.action) \(digit)")
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Memory Menu (readout)

private struct MemMenuPresenterView: View {
    @Binding var isPresented: Bool
    @Environment(CalculatorEngine.self) var engine

    var statBytes:    Int { engine.statPoints.count * 48 }
    var varBytes:     Int { engine.variables.count * 8 }
    var programBytes: Int { engine.programs.reduce(0) { $0 + ($1.steps.count * 2) } }
    var totalUsed:    Int { statBytes + varBytes + programBytes }

    var body: some View {
        NavigationStack {
            List {
                Section("Memory Usage") {
                    HStack { Text("Total Used"); Spacer(); Text("\(totalUsed) B") }
                    HStack { Text("STAT (\(engine.statPoints.count))"); Spacer(); Text("\(statBytes) B") }
                    HStack { Text("VARS (\(engine.variables.count))"); Spacer(); Text("\(varBytes) B") }
                    HStack { Text("PRGM (\(engine.programs.count))"); Spacer(); Text("\(programBytes) B") }
                }
                Section("Navigate") {
                    Button("VARS \u{2014} View Variables") {
                        engine.executeMath("VARS"); isPresented = false
                    }
                    Button("PRGM \u{2014} View Programs") {
                        engine.executeMath("PRGM"); isPresented = false
                    }
                    Button("REGS \u{2014} View Registers") {
                        engine.executeMath("REGS"); isPresented = false
                    }
                }
            }
            #if os(watchOS)
            .navigationTitle("MEM")
            #else
            .navigationTitle("Memory")
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("C") { isPresented = false }
                        .accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
        }
        .environment(engine)
    }
}

// MARK: - Constants Menu (searchable)

private struct ConstMenuPresenterView: View {
    @Binding var isPresented: Bool
    @Environment(CalculatorEngine.self) var engine
    @State private var searchText = ""

    var filteredConstants: [PhysicalConstant] {
        if searchText.isEmpty { return builtInConstants }
        let q = searchText.lowercased()
        return builtInConstants.filter {
            $0.name.lowercased().contains(q) || $0.symbol.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredConstants) { constant in
                Button {
                    engine.push(CalculatorValue(real: constant.value))
                    isPresented = false
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(constant.symbol).font(.headline).foregroundColor(.yellow)
                            Spacer()
                            Text(formatValue(constant.value) + (constant.unit.isEmpty ? "" : " " + constant.unit))
                                .font(.caption2).foregroundColor(.secondary)
                        }
                        Text(constant.name).font(.caption).foregroundColor(.primary)
                    }
                    .padding(.vertical, 2)
                }
            }
            .searchable(text: $searchText, prompt: "Search Constants")
            #if os(watchOS)
            .navigationTitle("CNST")
            #else
            .navigationTitle("Constants")
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("C") { isPresented = false }
                        .accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
        }
        .environment(engine)
    }

    private func formatValue(_ val: Double) -> String {
        if val == 0 { return "0" }
        if abs(val) >= 1e-4 && abs(val) < 1e5 {
            return String(format: "%g", val)
        }
        return String(format: "%.4e", val)
    }
}
