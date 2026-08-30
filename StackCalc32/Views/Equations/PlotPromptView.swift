import SwiftUI
import RPNCore

struct PlotPromptView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    @State private var plotSource = "Equation"
    @State private var variables: [String] = []
    @State private var selectedEquationLabel = ""
    @State private var selectedVar = ""
    @State private var lowerLimit = "-3"
    @State private var upperLimit = "3"
    @AppStorage("plotPushMode") private var plotPushMode: Int = 0
    @State private var actionToExecute: String? = nil
    
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
                Picker("Source", selection: $plotSource) {
                    Text("Equation").tag("Equation")
                    Text("Statistics Data").tag("Statistics Data")
                }
                .pickerStyle(.inline)
                
                Section("Plot Interaction") {
                    Picker("Tap Action", selection: $plotPushMode) {
                        Text("Push X Only").tag(0)
                        Text("Push Y Only").tag(1)
                        Text("Push Both (Y, then X)").tag(2)
                    }
                }
                
                if plotSource == "Equation" {
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
                            Section("Variable") {
                                Picker("Detected Variables", selection: $selectedVar) {
                                    ForEach(variables, id: \.self) { v in
                                        Text(v).tag(v)
                                    }
                                }
                                
                                TextField("Variable to Plot", text: $selectedVar)
                                    .textInputAutocapitalization(.characters)
                                    .disableAutocorrection(true)
                            }
                            
                            Section("Limits") {
                                TextField("X-Min", text: $lowerLimit)
                                    .textContentType(.telephoneNumber)

                                TextField("X-Max", text: $upperLimit)
                                    .textContentType(.telephoneNumber)

                            }
                        }
                    }
                } else {
                    Text("Linear Regression")
                        .foregroundColor(.gray)
                    Text("\(engine.statPoints.count) Points")
                        .foregroundColor(.gray)
                }
                
                if plotSource == "Equation" {
                    Section {
                        Button {
                            actionToExecute = "integrate"
                            dismiss()
                        } label: {
                            Text("Integrate & Plot Area")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.green)
                                .fontWeight(.bold)
                        }
                        .accessibilityIdentifier("btn_integrate_execute")
                    }
                }
            }
            .navigationTitle("Plot")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Plot") {
                        actionToExecute = "plot"
                        dismiss()
                    }
                    .accessibilityIdentifier("btn_plot_execute")
                }
            }
            .onAppear {
                print("PLOT_PROMPT_DEBUG: equations = \(engine.equations.map { "\($0.label):\($0.steps)" })")
                if engine.isBuildingNumber {
                    engine.commitInput()
                }
                
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
                if actionToExecute == "plot" {
                    if plotSource == "Statistics Data" {
                        engine.statusMessage = "CALCULATING"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            engine.generatePlot()
                            engine.statusMessage = nil
                        }
                    } else {
                        if !selectedEquationLabel.isEmpty {
                            engine.currentEquationLabel = selectedEquationLabel
                        }
                        if let low = Double(lowerLimit), let up = Double(upperLimit) {
                            engine.startPlot(variable: selectedVar, lower: low, upper: up)
                        }
                    }
                } else if actionToExecute == "integrate" {
                    if !selectedEquationLabel.isEmpty {
                        engine.currentEquationLabel = selectedEquationLabel
                    }
                    if let low = Double(lowerLimit), let up = Double(upperLimit) {
                        engine.startIntegrate(variable: selectedVar, lower: low, upper: up, requestPlotAfter: true)
                    }
                }
            }
        }
    }
}
