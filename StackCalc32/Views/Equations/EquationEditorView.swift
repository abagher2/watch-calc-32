import SwiftUI
import RPNCore

struct EquationEditorView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    var isPresented: Binding<Bool>? = nil
    var isFNMode = false
    
    var body: some View {
        List {
                Button {
                    engine.isWaitingForLabel = true
                    engine.startAlpha()
                    engine.alphaPrompt = "LBL _"
                    if let isPresented {
                        isPresented.wrappedValue = false
                    } else {
                        dismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("New Equation")
                    }
                }
                .accessibilityIdentifier("btn_add_eqn")
                
                ForEach(engine.equations) { equation in
                    Button {
                        if isFNMode {
                            engine.currentEquationLabel = equation.label
                        } else {
                            engine.editEquation(equation)
                        }
                        if let isPresented {
                            isPresented.wrappedValue = false
                        } else {
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Text(equation.label)
                                .font(.headline)
                            Spacer()
                            Text(equation.steps.map { $0.stringValue }.joined(separator: " "))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    engine.equations.remove(atOffsets: indexSet)
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
