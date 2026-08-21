import SwiftUI
import RPNCore

struct IntegratePromptView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    @State private var variables: [String] = []
    @State private var selectedProgramLabel = ""
    @State private var selectedVar = ""
    @State private var lowerLimit = "0"
    @State private var upperLimit = "1"
    @State private var shouldEvaluate = false
    
    private func updateVariables() {
        if let program = engine.programs.first(where: { $0.label == selectedProgramLabel }) {
            variables = program.extractVariables()
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
                if engine.programs.isEmpty {
                    Text("No equations available.")
                } else {
                    Section("Equation") {
                        ForEach(engine.programs) { program in
                            Button {
                                selectedProgramLabel = program.label
                                updateVariables()
                            } label: {
                                HStack {
                                    if program.label.isEmpty {
                                        Text("Equation")
                                            .foregroundColor(.white)
                                    } else {
                                        Text(program.label)
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    Text(program.steps.joined(separator: " "))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .foregroundColor(.secondary)
                                        .layoutPriority(-1)
                                    if selectedProgramLabel == program.label {
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
                Section {
                    Button {
                        if !selectedProgramLabel.isEmpty {
                            engine.currentProgramLabel = selectedProgramLabel
                        }
                        shouldEvaluate = true
                        dismiss()
                    } label: {
                        Text("Evaluate")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    // .disabled(variables.isEmpty)
                }
            }
            .navigationTitle("Integrate")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if engine.stack.count >= 2 {
                    let y = engine.stack[1].real
                    let x = engine.stack[0].real
                    lowerLimit = String(format: "%g", y)
                    upperLimit = String(format: "%g", x)
                }
                if let label = engine.currentProgramLabel.isEmpty ? nil : engine.currentProgramLabel,
                   engine.programs.contains(where: { $0.label == label }) {
                    selectedProgramLabel = label
                } else if let first = engine.programs.first {
                    selectedProgramLabel = first.label
                }
                updateVariables()
            }
            .onDisappear {
                if shouldEvaluate {
                    if let program = engine.programs.first(where: { $0.label == selectedProgramLabel }),
                       let low = Double(lowerLimit),
                       let up = Double(upperLimit) {
                        if engine.stack.count >= 2 {
                            engine.drop()
                            engine.drop()
                        }
                        engine.statusMessage = "INTEGRATING"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            _ = engine.integrate(variable: selectedVar, lower: low, upper: up, program: program)
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
