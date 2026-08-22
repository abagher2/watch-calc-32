import SwiftUI
import RPNCore
import Observation

@main

struct StackCalc32App: App {
    @State private var engine = CalculatorEngine()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(engine)
                .environmentObject(themeManager)
        }
    }
}

