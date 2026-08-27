import SwiftUI
import RPNCore
import Observation

@main

struct StackCalc32App: App {
    @State private var engine = CalculatorEngine()
    @StateObject private var themeManager: ThemeManager = {
        let tm = ThemeManager()
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-useRetroUI") {
            tm.activeThemeType = .retro
        }
        if let themeIndex = args.firstIndex(of: "-theme"), themeIndex + 1 < args.count {
            let themeName = args[themeIndex + 1]
            if let type = ThemeType.allCases.first(where: { $0.rawValue == themeName }) {
                tm.activeThemeType = type
            }
        }
        return tm
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(engine)
                .environmentObject(themeManager)
        }
    }
}

