import SwiftUI
import RPNCore

struct EquationListView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    var isFNMode = false
    
    var body: some View {
        List {
                Button {
                    engine.isWaitingForLabel = true
                    engine.startAlpha()
                    engine.alphaPrompt = "LBL _"
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("New Equation")
                    }
                }
                .accessibilityIdentifier("btn_add_eqn")
                
                ForEach(engine.programs) { program in
                    Button {
                        if isFNMode {
                            engine.currentProgramLabel = program.label
                        } else {
                            engine.editEquation(program)
                        }
                        dismiss()
                    } label: {
                        HStack {
                            Text(program.label)
                                .font(.headline)
                            Spacer()
                            Text(program.steps.joined(separator: " "))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    engine.programs.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Equations")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
        }
    }
}
