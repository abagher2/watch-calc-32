import SwiftUI
import RPNCore

struct ClearMenuView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Button("Clear Stats (Σ)") {
                    engine.clearStats()
                    dismiss()
                }
                
                Button("Clear Variables (VARS)") {
                    engine.clearVars()
                    dismiss()
                }
                
                Button("Clear Memory (ALL)") {
                    engine.clearAll()
                    dismiss()
                }
                
                Button("Clear Stack (STK)") {
                    engine.executeOp(.clear)
                    dismiss()
                }
            }
            .navigationTitle("Clear Menu")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
