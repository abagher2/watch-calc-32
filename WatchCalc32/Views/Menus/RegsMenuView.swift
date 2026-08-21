import SwiftUI
import RPNCore

struct RegsMenuView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    let logicalStack = engine.getLogicalStack()
                    
                    // T at top, X at bottom — natural RPN stack convention
                    Section(header: Text("Stack Registers")) {
                        // Show from T down to X (reversed so X is at the bottom)
                        ForEach((0..<logicalStack.count).reversed(), id: \.self) { index in
                            HStack {
                                Text(labelForIndex(index, total: logicalStack.count))
                                    .fontWeight(.semibold)
                                    .foregroundColor(index == 0 ? .primary : .secondary)
                                    .frame(width: 44, alignment: .leading)
                                Spacer()
                                Text(formatValue(logicalStack[index]))
                                    .font(.system(.body, design: .monospaced))
                            }
                            .id(index == 0 ? "xReg" : "reg_\(index)")
                        }
                    }
                    
                    Section(header: Text("Last X")) {
                        HStack {
                            Text("LASTx")
                                .fontWeight(.semibold)
                                .frame(width: 44, alignment: .leading)
                            Spacer()
                            Text(formatValue(engine.lastX))
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    
                    let storedVars = engine.variables.filter { !$0.key.isEmpty }
                        .sorted { $0.key < $1.key }
                    if !storedVars.isEmpty {
                        Section(header: Text("Variables")) {
                            ForEach(storedVars, id: \.key) { key, value in
                                HStack {
                                    Text(key)
                                        .fontWeight(.semibold)
                                        .frame(width: 44, alignment: .leading)
                                    Spacer()
                                    Text(formatValue(value))
                                        .font(.system(.body, design: .monospaced))
                                }
                            }
                        }
                    }
                }
                #if os(watchOS)
                .navigationTitle("REGS")
                #else
                .navigationTitle("Registers")
                #endif
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    // Scroll to X register (bottom) on open
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo("xReg", anchor: .bottom)
                        }
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
        return "L\(index + 1)"
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
