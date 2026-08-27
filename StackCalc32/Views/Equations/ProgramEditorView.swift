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
                .navigationTitle("Program Editor")
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

#if DEBUG
struct ProgramEditorView_Previews: PreviewProvider {
    static var previews: some View {
        let engine = CalculatorEngine()
        engine.isProgrammingMode = true
        engine.currentProgramLabel = "NPDF"
        // Load the NPDF program from default engine
        if let p = engine.programs.first(where: { $0.label == "NPDF" }) {
            engine.currentProgramSteps = p.steps.map { $0.stringValue }
        }
        engine.currentProgramStepIndex = 5 // Focus on "𝑒ˣ"
        
        return Group {
            // iOS Preview
            ProgramEditorView()
                .environment(engine)
                .previewDisplayName("iOS Equation Editor")
                .previewDevice("iPhone 15 Pro")
            
            // WatchOS Preview
            ProgramEditorView()
                .environment(engine)
                .previewDisplayName("Watch Equation Editor")
                .previewDevice("Apple Watch Ultra 2 (49mm)")
        }
    }
}
#endif
