import SwiftUI
import RPNCore

struct RegsView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Stack") {
                    Text("T: \(engine.formatNumber(engine.stack[3].real))")
                    Text("Z: \(engine.formatNumber(engine.stack[2].real))")
                    Text("Y: \(engine.formatNumber(engine.stack[1].real))")
                    Text("X: \(engine.formatNumber(engine.stack[0].real))")
                    Text("LAST X: \(engine.formatNumber(engine.lastX.real))")
                }
                Section("Variables") {
                    ForEach(0..<26, id: \.self) { i in
                        let val = engine.storedVariablesArray[i]
                        if val != 0.0 {
                            let letter = String(Character(UnicodeScalar(65 + i)!))
                            Text("\(letter): \(engine.formatNumber(val))")
                        }
                    }
                }
            }
            .navigationTitle("REGS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
