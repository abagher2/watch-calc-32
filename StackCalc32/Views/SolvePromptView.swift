import SwiftUI
import RPNCore

struct SolvePromptView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    @State private var variables: [String] = []
    @State private var selectedProgramLabel = ""
    @State private var selectedVar = ""
    @State private var targetSelection = "0"
    
    private func updateVariables() {
        if let program = engine.programs.first(where: { $0.label == selectedProgramLabel }) {
            variables = program.extractVariables()
        } else {
            variables = []
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if engine.programs.isEmpty {
                    Text("No equations available.")
                } else {
                    Picker("Equation", selection: $selectedProgramLabel) {
                        ForEach(engine.programs) { program in
                            Text(program.label).tag(program.label)
                        }
                    }
                    .onChange(of: selectedProgramLabel) { _, _ in updateVariables() }
                    
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
                    
                    Button {
                        if !selectedProgramLabel.isEmpty {
                            engine.currentProgramLabel = selectedProgramLabel
                        }
                        if let program = engine.programs.first(where: { $0.label == selectedProgramLabel }) {
                            engine.statusMessage = "CALCULATING"
                            let targetValue = targetSelection == "X" ? (engine.stack.first?.real ?? 0.0) : 0.0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                _ = engine.solve(for: selectedVar.uppercased(), program: program, target: targetValue)
                                engine.statusMessage = nil
                            }
                        }
                        dismiss()
                    } label: {
                        Text("Solve")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("Solve")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if let label = engine.currentProgramLabel.isEmpty ? nil : engine.currentProgramLabel,
                   engine.programs.contains(where: { $0.label == label }) {
                    selectedProgramLabel = label
                } else if let first = engine.programs.first {
                    selectedProgramLabel = first.label
                }
                updateVariables()
            }
        }
    }
}
struct XEQPromptView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedProgramLabel = ""
    
    var body: some View {
        NavigationStack {
            List {
                if engine.programs.isEmpty {
                    Text("No equations available.")
                } else {
                    Picker("Equation", selection: $selectedProgramLabel) {
                        ForEach(engine.programs) { program in
                            Text(program.label).tag(program.label)
                        }
                    }
                    
                    Button {
                        if !selectedProgramLabel.isEmpty {
                            engine.currentProgramLabel = selectedProgramLabel
                        }
                        if let program = engine.programs.first(where: { $0.label == selectedProgramLabel }) {
                            engine.currentEvaluatingProgram = program
                            let bareVars = program.steps.filter { $0.count == 1 && "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains($0) }
                            var seen = Set<String>()
                            engine.pendingEquationVars = bareVars.filter { seen.insert($0).inserted }
                            engine.promptNextEquationVar()
                        }
                        dismiss()
                    } label: {
                        Text("Evaluate")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("XEQ")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if let label = engine.currentProgramLabel.isEmpty ? nil : engine.currentProgramLabel,
                   engine.programs.contains(where: { $0.label == label }) {
                    selectedProgramLabel = label
                } else if let first = engine.programs.first {
                    selectedProgramLabel = first.label
                }
            }
        }
    }
}
