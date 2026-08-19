import SwiftUI
import RPNCore

struct ConstantsMenuView: View {
    @Bindable var engine: CalculatorEngine
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    
    var filteredConstants: [PhysicalConstant] {
        if searchText.isEmpty {
            return builtInConstants
        } else {
            return builtInConstants.filter { constant in
                constant.name.localizedCaseInsensitiveContains(searchText) ||
                constant.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredConstants) { constant in
                Button {
                    engine.push(CalculatorValue(real: constant.value))
                    isPresented = false
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(constant.symbol)
                                .font(.headline)
                                .foregroundColor(.yellow)
                            Spacer()
                            Text(formatValue(constant.value) + (constant.unit.isEmpty ? "" : " " + constant.unit))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(constant.name)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .searchable(text: $searchText, prompt: "Search Constants")
            .navigationTitle("CNST")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func formatValue(_ val: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.positiveFormat = "0.###E+0"
        formatter.exponentSymbol = "e"
        if val > 1e-4 && val < 1e5 {
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 5
        }
        return formatter.string(from: NSNumber(value: val)) ?? "\(val)"
    }
}
