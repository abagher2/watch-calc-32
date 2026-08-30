import SwiftUI
import RPNCore

struct SolvePromptView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    @State private var variables: [String] = []
    @State private var selectedEquationLabel = ""
    @State private var selectedVar = ""
    @State private var targetSelection = "0"
    
    private func updateVariables() {
        if let equation = engine.equations.first(where: { $0.label == selectedEquationLabel }) {
            variables = equation.extractVariables()
        } else {
            variables = []
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if engine.equations.isEmpty {
                    Text("No equations available.")
                } else {
                    Picker("Equation", selection: $selectedEquationLabel) {
                        ForEach(engine.equations) { equation in
                            Text(equation.label).tag(equation.label)
                        }
                    }
                    .onChange(of: selectedEquationLabel) { _, _ in updateVariables() }
                    
                    if variables.isEmpty {
                        Text("No variables found in equation")
                    } else {
                        Picker("Detected Variables", selection: $selectedVar) {
                            ForEach(variables, id: \.self) { varName in
                                Text(varName).tag(varName)
                            }
                        }
                        .onChange(of: selectedVar) { _, newValue in
                            // If user picks from picker, update the text field?
                            // SwiftUI handles selection directly, we just bind Picker to selectedVar
                        }
                    }
                    
                    TextField("Variable to Solve", text: $selectedVar)
                        .textInputAutocapitalization(.characters)
                        .disableAutocorrection(true)
                    
                    Picker("Target Value", selection: $targetSelection) {
                        Text("0").tag("0")
                        Text("X Register").tag("X")
                    }
#if os(iOS)
                    .pickerStyle(.segmented)
#endif
                }
            }
            .navigationTitle("Solve")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Solve") {
                        if !selectedEquationLabel.isEmpty {
                            engine.currentEquationLabel = selectedEquationLabel
                        }
                        if let equation = engine.equations.first(where: { $0.label == selectedEquationLabel }) {
                            engine.statusMessage = "CALCULATING"
                            let targetValue = targetSelection == "X" ? (engine.stack.first?.real ?? 0.0) : 0.0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                _ = engine.solve(for: selectedVar.uppercased(), equation: equation, target: targetValue)
                                engine.statusMessage = nil
                            }
                        }
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let label = engine.currentEquationLabel.isEmpty ? nil : engine.currentEquationLabel,
                   engine.equations.contains(where: { $0.label == label }) {
                    selectedEquationLabel = label
                } else if let first = engine.equations.first {
                    selectedEquationLabel = first.label
                }
                updateVariables()
            }
        }
    }
}
struct XEQPromptView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedEquationLabel = ""
    
    var body: some View {
        NavigationStack {
            List {
                if engine.equations.isEmpty {
                    Text("No equations available.")
                } else {
                    Picker("Equation", selection: $selectedEquationLabel) {
                        ForEach(engine.equations) { equation in
                            Text(equation.label).tag(equation.label)
                        }
                    }
                    
                }
            }
            .navigationTitle("XEQ")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Evaluate") {
                        if !selectedEquationLabel.isEmpty {
                            engine.currentEquationLabel = selectedEquationLabel
                        }
                        if let equation = engine.equations.first(where: { $0.label == selectedEquationLabel }) {
                            engine.currentEvaluatingEquation = equation
                            engine.pendingEquationVars = equation.extractVariables()
                            engine.promptNextEquationVar()
                        }
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let label = engine.currentEquationLabel.isEmpty ? nil : engine.currentEquationLabel,
                   engine.equations.contains(where: { $0.label == label }) {
                    selectedEquationLabel = label
                } else if let first = engine.equations.first {
                    selectedEquationLabel = first.label
                }
            }
        }
    }
}
