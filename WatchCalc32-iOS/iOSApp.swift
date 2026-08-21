import SwiftUI
import RPNCore
import Observation

@main

struct WatchCalc32_iOSApp: App {
    @State private var engine = CalculatorEngine()
    @StateObject private var themeManager: ThemeManager = {
        let tm = ThemeManager()
        if ProcessInfo.processInfo.arguments.contains("-useRetroUI") {
            tm.activeThemeType = .retro
        }
        return tm
    }()
    
    var body: some Scene {
        WindowGroup {
            iOSContentView()
                .environment(engine)
                .environmentObject(themeManager)
        }
    }


}
