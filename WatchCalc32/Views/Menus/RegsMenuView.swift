import SwiftUI
import RPNCore

struct RegsMenuView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                let logicalStack = engine.getLogicalStack()
                
                Section(header: Text("Stack Registers")) {
                    ForEach((0..<logicalStack.count).reversed(), id: \.self) { index in
                        HStack {
                            Text(labelForIndex(index, total: logicalStack.count))
                            Spacer()
                            Text(formatValue(logicalStack[index]))
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
                
                Section(header: Text("Last X")) {
                    HStack {
                        Text("LASTx")
                        Spacer()
                        Text(formatValue(engine.lastX))
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
            .navigationTitle("REGS")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func labelForIndex(_ index: Int, total: Int) -> String {
        if index == 0 { return "X" }
        if index == 1 { return "Y" }
        if index == 2 { return "Z" }
        if index == total - 1 { return "T" }
        return "Reg \(index + 1)"
    }
    
    private func formatValue(_ value: CalculatorValue) -> String {
        if value.isComplex {
            return "\(formatNumber(value.real)) + \(formatNumber(value.imag))i"
        }
        return formatNumber(value.real)
    }
    
    private func formatNumber(_ val: Double) -> String {
        return String(format: "%.6g", val)
    }
}
