import SwiftUI
import RPNCore

struct VariablePromptView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    // Extracted variables
    @State private var variables: [String] = []
    // Local values
    @State private var values: [String: String] = [:]
    
    var body: some View {
        NavigationStack {
            Form {
                ForEach(variables, id: \.self) { varName in
                    HStack {
                        Text(varName)
                        Spacer()
                        TextField("Value", text: Binding(
                            get: { values[varName] ?? "" },
                            set: { values[varName] = $0 }
                        ))
                        .textContentType(.telephoneNumber)
                        .multilineTextAlignment(.trailing)
                    }
                }
                
                Section {
                    Button(action: executeProgram) {
                        Text("Execute")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle(engine.currentEvaluatingProgram?.label ?? "Variables")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        engine.currentEvaluatingProgram = nil
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Execute") {
                        executeProgram()
                    }
                }
            }
            .onAppear {
                if let program = engine.currentEvaluatingProgram {
                    variables = program.extractVariables()
                    
                    for v in variables {
                        if let stored = engine.variables[v] {
                            values[v] = engine.formatNumber(stored.real)
                        } else {
                            values[v] = "0"
                        }
                    }
                }
            }
        }
    }
    
    private func executeProgram() {
        guard let program = engine.currentEvaluatingProgram else { return }
        
        // Update stored variables in engine
        for (varName, valString) in values {
            if let d = Double(valString) {
                engine.variables[varName] = CalculatorValue(real: d)
            }
        }
        
        if let result = engine.evaluateProgram(program, variables: engine.variables) {
            engine.push(result)
        }
        
        engine.currentEvaluatingProgram = nil
        dismiss()
    }
}
