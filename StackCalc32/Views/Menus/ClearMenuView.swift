import SwiftUI
import RPNCore

struct ClearMenuView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    @State private var confirmAll = false

    var body: some View {
        NavigationStack {
            List {
                Button("Clear X (CLx)") {
                    engine.executeOp(.clear); dismiss()
                }
                Button("Clear Statistics (CLΣ)") {
                    engine.clearStats(); dismiss()
                }
                Button("Clear Variables (CLVARS)") {
                    engine.clearVars(); dismiss()
                }
                Button("Clear Programs (CLPRGM)") {
                    engine.executeMath("CLPRGM"); dismiss()
                }
                Button("Clear Registers (CLREGS)") {
                    engine.executeMath("CLREGS"); dismiss()
                }
                Button("Clear Stack (CLSTK)") {
                    engine.executeMath("CLSTK"); dismiss()
                }
                Button("Clear ALL", role: .destructive) {
                    confirmAll = true
                }
            }
            #if os(watchOS)
            .navigationTitle("CLEAR")
            #else
            .navigationTitle("Clear")
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("C") { dismiss() }
                        .accessibilityIdentifier("sheet_dismiss_btn")
                }
            }
            .confirmationDialog("Clear ALL?", isPresented: $confirmAll, titleVisibility: .visible) {
                Button("Clear Everything", role: .destructive) {
                    engine.clearAll(); dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will erase all variables, programs, statistics, and registers.")
            }
        }
    }
}
