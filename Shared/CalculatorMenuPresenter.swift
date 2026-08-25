// CalculatorMenuPresenter.swift — iOS / watchOS realization of the CalculatorMenu abstraction.
//
// Architecture:
//   RPNCore defines CalculatorMenu + MenuItem (pure Swift, Embedded-safe).
//   CalculatorEngine.activeMenu is the shared activation state.
//
// Realizations:
//   • Firmware  → RetroUI.swift draws pixel softkeys using engine.activeMenu
//   • iOS/watchOS → This file renders a SwiftUI sheet using the same engine.activeMenu
//
// This file is compiled only into the Watch and iOS targets (per project.pbxproj).
// No #if hasFeature(Embedded) guards are needed here.
import SwiftUI
import RPNCore

/// Renders a `CalculatorMenu` as a native SwiftUI `List` sheet.
///
/// Both iOS and watchOS present this identically for list-style menus.
/// Items that `requiresDigit` (FIX, SCI, ENG …) show an inline digit picker.
/// On watchOS the picker uses `.wheel` (Digital Crown friendly);
/// on iOS it uses `.segmented`.
public struct CalculatorMenuPresenter: View {
    public let menu: CalculatorMenu
    @Binding public var isPresented: Bool
    @Environment(CalculatorEngine.self) var engine

    public init(menu: CalculatorMenu, isPresented: Binding<Bool>) {
        self.menu = menu
        self._isPresented = isPresented
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(menu.items, id: \.label) { item in
                    MenuItemRow(item: item, isPresented: $isPresented)
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
    @Binding var isPresented: Bool
    @Environment(CalculatorEngine.self) var engine
    @State private var digit: Int = 4

    /// Maps sub-menu navigation action strings to the target CalculatorMenu.
    /// These actions open a different menu rather than executing a math operation.
    private static let subMenuMap: [String: CalculatorMenu] = [
        "STATMEAN":   .statMean,
        "STATSTDDEV": .statStdDev,
        "STATLR":     .lr,
        "STATSUMS":   .sums,
    ]

    var body: some View {
        if item.requiresDigit {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.label)
                    .font(.headline)
                Picker("Digits", selection: $digit) {
                    ForEach(0...9, id: \.self) { n in
                        Text("\(n)").tag(n)
                    }
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
        } else if let subMenu = Self.subMenuMap[item.action] {
            // Sub-menu navigation: opens a different CalculatorMenu
            Button(item.label) {
                engine.activeMenu = subMenu
                // Don't dismiss — the sheet(item:) will re-present with the new menu
            }
        } else {
            Button(item.label) {
                engine.executeMath(item.action)
                isPresented = false
            }
        }
    }
}

