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
                
            }
            .navigationTitle(engine.currentEvaluatingEquation?.label ?? "Variables")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        engine.currentEvaluatingEquation = nil
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Execute") {
                        executeEquation()
                    }
                }
            }
            .onAppear {
                if let equation = engine.currentEvaluatingEquation {
                    variables = equation.extractVariables()
                    
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
    
    private func executeEquation() {
        guard let equation = engine.currentEvaluatingEquation else { return }
        
        // Update stored variables in engine
        for (varName, valString) in values {
            if let d = Double(valString) {
                engine.variables[varName] = CalculatorValue(real: d)
            }
        }
        
        if let result = engine.evaluateEquation(equation) {
            engine.push(result)
        }
        
        engine.currentEvaluatingEquation = nil
        dismiss()
    }
}
