import SwiftUI
#if os(watchOS)
import WatchKit
#endif
import RPNCore

struct CalcButton: View {
    let title: String
    let yellow: String
    let blue: String
    let isDigit: Bool
    let isAlpha: Bool
    let textColor: Color?
    @Environment(CalculatorEngine.self) var engine
    @EnvironmentObject var themeManager: ThemeManager
    #if os(watchOS)
    @AppStorage("hapticsMode") private var hapticsMode: Int = 2
#else
    @AppStorage("hapticsMode") private var hapticsMode: Int = 0
#endif
    let action: (CalculatorOperation) -> Void
    
    init(
        _ title: String,
        yellow: String = "",
        blue: String = "",
        isDigit: Bool = false,
        isAlpha: Bool = false,
        textColor: Color? = nil,
        action: @escaping (CalculatorOperation) -> Void = { _ in }
    ) {
        self.title = title
        self.yellow = yellow
        self.blue = blue
        self.isDigit = isDigit
        self.isAlpha = isAlpha
        self.textColor = textColor
        self.action = action
    }
    
    private var a11yID: String {
        if title == " " { return "invisible_enter" }
        let op = mapOp(title)
        if op == .enter && title != "ENTER" {
            return isAlpha ? "alpha_\(title)" : "ui_\(title)"
        }
        return "op_\(String(describing: op))"
    }
    
    var body: some View {
        Button {
            #if os(watchOS)
            if hapticsMode == 0 {
                WKInterfaceDevice.current().play(.click)
            } else if hapticsMode == 1 {
                WKInterfaceDevice.current().play(.directionUp)
            }
            #endif
            
            let opToExecute: String
            switch engine.shiftState {
            case 1: opToExecute = yellow.isEmpty ? title : yellow
            case 2: opToExecute = blue.isEmpty ? title : blue
            default: opToExecute = title
            }
            
            let mappedOp = mapOp(opToExecute)
            
            if mappedOp == .enter && opToExecute != "ENTER" && opToExecute.count == 1 && opToExecute.first!.isLetter {
                engine.submitAlpha(opToExecute)
            } else {
                dispatchKey(mappedOp, engine: engine, onMenuAction: { cmd in
                    // Watch: let the action closure handle menu routing
                    _ = cmd
                })
            }
            
            engine.shiftState = 0
            action(mappedOp)
        } label: {
            if title == "<-" {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .bold))
            } else {
                Text(title)
            }
        }
        .buttonStyle(ShiftedPioneerButtonStyle(
            yellow: yellow,
            blue: blue,
            isDigit: isDigit,
            isAlpha: isAlpha,
            theme: themeManager.theme,
            textColor: textColor,
            activeShift: engine.shiftState,
            fontSize: 14
        ))
        .accessibilityIdentifier(a11yID)
    }
    
    // mapOp() and dispatchKey() live in Shared/KeyActionDispatcher.swift
}
