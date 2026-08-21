import SwiftUI
import RPNCore
import Observation

@main

struct WatchCalc32_iOSApp: App {
    @State private var engine = CalculatorEngine()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            iOSContentView()
                .environment(engine)
                .environmentObject(themeManager)
        }
    }


}
