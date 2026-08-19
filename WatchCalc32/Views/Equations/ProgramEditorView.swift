import SwiftUI
import RPNCore

struct ProgramEditorView: View {
    @Environment(CalculatorEngine.self) var engine
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    // Line 00
                    Button(action: {
                        engine.currentProgramStepIndex = 0
                        engine.updateProgramDisplay()
                        dismiss()
                    }) {
                        HStack {
                            Text("00\tLBL \(engine.currentProgramLabel)")
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                            Spacer()
                            if engine.currentProgramStepIndex == 0 {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .id(0)
                    
                    // Program Steps
                    ForEach(Array(engine.currentProgramSteps.enumerated()), id: \.offset) { index, step in
                        Button(action: {
                            engine.currentProgramStepIndex = index + 1
                            engine.updateProgramDisplay()
                            dismiss()
                        }) {
                            HStack {
                                Text("\(String(format: "%02d", index + 1))\t\(step)")
                                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                                Spacer()
                                if engine.currentProgramStepIndex == index + 1 {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .id(index + 1)
                    }
                }
                .navigationTitle(engine.isEquationMode ? "EQN" : "Program Editor")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .onAppear {
                    proxy.scrollTo(engine.currentProgramStepIndex, anchor: .center)
                }
            }
        }
    }
}
