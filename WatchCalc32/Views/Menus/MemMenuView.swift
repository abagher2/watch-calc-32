import SwiftUI
import RPNCore

struct MemMenuView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    var statBytes: Int {
        // Each stat record is 6 doubles (6 * 8 = 48 bytes)
        return engine.statPoints.count * 48
    }
    
    var varBytes: Int {
        // Each variable is a double (8 bytes)
        return engine.variables.count * 8
    }
    
    var programBytes: Int {
        // Each program step is roughly 2 bytes
        return engine.programs.reduce(0) { $0 + ($1.steps.count * 2) }
    }
    
    var totalUsed: Int {
        return statBytes + varBytes + programBytes
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Memory Status")) {
                    HStack {
                        Text("Total Used")
                        Spacer()
                        Text("\(totalUsed) B")
                    }
                    HStack {
                        Text("STAT (\(engine.statPoints.count))")
                        Spacer()
                        Text("\(statBytes) B")
                    }
                    HStack {
                        Text("VARS (\(engine.variables.count))")
                        Spacer()
                        Text("\(varBytes) B")
                    }
                    HStack {
                        Text("PRGM (\(engine.programs.count))")
                        Spacer()
                        Text("\(programBytes) B")
                    }
                }
                

            }
            .navigationTitle("MEM")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
