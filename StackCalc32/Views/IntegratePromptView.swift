import SwiftUI
import RPNCore

struct IntegratePromptView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    @State private var variables: [String] = []
    @State private var selectedEquationLabel = ""
    @State private var selectedVar = ""
    @State private var lowerLimit = "0"
    @State private var upperLimit = "1"
    @State private var shouldEvaluate = false
    
    private func updateVariables() {
        if let equation = engine.equations.first(where: { $0.label == selectedEquationLabel }) {
            variables = equation.extractVariables()
            if let first = variables.first {
                selectedVar = first
            }
        } else {
            variables = []
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if engine.equations.isEmpty {
                    Text("No equations available.")
                } else {
                    Section("Equation") {
                        ForEach(engine.equations) { equation in
                            Button {
                                selectedEquationLabel = equation.label
                                updateVariables()
                            } label: {
                                HStack {
                                    if equation.label.isEmpty {
                                        Text("Equation")
                                            .foregroundColor(.white)
                                    } else {
                                        Text(equation.label)
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    Text(equation.steps.map { $0.stringValue }.joined(separator: " "))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundColor(.secondary)
                                        .layoutPriority(-1)
                                    if selectedEquationLabel == equation.label {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    
                    if variables.isEmpty {
                        Text("No variables found in equation")
                    } else {
                        Picker("Detected Variables", selection: $selectedVar) {
                            ForEach(variables, id: \.self) {
                                Text($0)
                            }
                        }
                        
                        TextField("Variable to Integrate", text: $selectedVar)
                            .textInputAutocapitalization(.characters)
                            .disableAutocorrection(true)
                        
                        TextField("Lower Limit", text: $lowerLimit)
                        .textContentType(.telephoneNumber)

                        TextField("Upper Limit", text: $upperLimit)
                        .textContentType(.telephoneNumber)

                    }
                }
            }
            .navigationTitle("Integrate")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Evaluate") {
                        if !selectedEquationLabel.isEmpty {
                            engine.currentEquationLabel = selectedEquationLabel
                        }
                        shouldEvaluate = true
                        dismiss()
                    }
                }
            }
            .onAppear {
                if engine.stack.count >= 2 {
                    let y = engine.stack[1].real
                    let x = engine.stack[0].real
                    lowerLimit = String(format: "%g", y)
                    upperLimit = String(format: "%g", x)
                }
                if let label = engine.currentEquationLabel.isEmpty ? nil : engine.currentEquationLabel,
                   engine.equations.contains(where: { $0.label == label }) {
                    selectedEquationLabel = label
                } else if let first = engine.equations.first {
                    selectedEquationLabel = first.label
                }
                updateVariables()
            }
            .onDisappear {
                if shouldEvaluate {
                    if let equation = engine.equations.first(where: { $0.label == selectedEquationLabel }),
                       let low = Double(lowerLimit),
                       let up = Double(upperLimit) {
                        if engine.stack.count >= 2 {
                            engine.drop()
                            engine.drop()
                        }
                        engine.statusMessage = "INTEGRATING"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            _ = engine.integrate(variable: selectedVar, lower: low, upper: up, equation: equation)
                            if engine.isPlotSRequested {
                                engine.isPlotSRequested = false
                                engine.integrationLimits = (min(low, up), max(low, up))
                                engine.generatePlot(variable: selectedVar, explicitMin: low, explicitMax: up)
                                engine.requestPlot = true
                            }
                            engine.statusMessage = nil
                        }
                    }
                }
            }
        }
    }
}
