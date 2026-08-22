import SwiftUI
import RPNCore

struct ShowView: View {
    @Environment(\.dismiss) private var dismiss
    let rawValue: Double
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(String(format: "%.14g", rawValue))
                    .font(.system(size: 32, weight: .medium, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle("SHOW")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
