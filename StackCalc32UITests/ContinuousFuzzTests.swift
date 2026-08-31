import XCTest
import Foundation

class ContinuousFuzzTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }

    func testParityFuzzing() throws {
        XCTAssertTrue(app.staticTexts["lcd_display"].waitForExistence(timeout: 10), "LCD did not appear in time")

        for _ in 0..<20 {
            guard let url = URL(string: "http://127.0.0.1:8181/next"),
                  let data = try? Data(contentsOf: url),
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let seq = json["sequence"] as? [String],
                  let expected = json["expected"] as? String else { continue }
            
            if seq.isEmpty { continue }
            
            for op in seq {
                let key = self.mapOpToIdentifier(op)
                if app.buttons[key].exists {
                    app.buttons[key].firstMatch.tap()
                } else if app.staticTexts[key].exists {
                    app.staticTexts[key].firstMatch.tap()
                } else {
                    // Try to swipe!
                    app.swipeLeft()
                    if app.buttons[key].exists { app.buttons[key].firstMatch.tap() }
                    else { app.swipeRight(); app.swipeRight() }
                    if app.buttons[key].exists { app.buttons[key].firstMatch.tap() }
                    else { app.swipeLeft() }
                }
            }
            
            let deviceName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] ?? "Unknown"
            let lcd = app.staticTexts["lcd_display"].label
            var mismatch = false
            func reportResult(device: String, seq: [String], expected: String, got: String, match: Bool, errorType: String = "") {
                let dict: [String: Any] = [
                    "device": device, "sequence": seq, "expected": expected, "got": got, "match": match, "errorType": errorType
                ]
                if let data = try? JSONSerialization.data(withJSONObject: dict) {
                    var req = URLRequest(url: URL(string: "http://127.0.0.1:8181/report_result")!)
                    req.httpMethod = "POST"
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.httpBody = data
                    let sem = DispatchSemaphore(value: 0)
                    URLSession.shared.dataTask(with: req) { _,_,_ in sem.signal() }.resume()
                    sem.wait()
                }
            }
            
            if lcd != expected {
                print("❌ PARITY MISMATCH on \(deviceName)! Expected LCD: \(expected), Got: \(lcd) for seq: \(seq)")
                mismatch = true
                reportResult(device: deviceName, seq: seq, expected: expected, got: lcd, match: false, errorType: "LCD")
            }
            
            let expectedAnns = json["annunciators"] as? [String] ?? []
            let allAnnunciators = ["RAD", "GRD", "CMPLX", "🔒 EXAM", "STAY", "EQN", "HYP", "↑", "HEX", "OCT", "BIN", "STAT", "A..Z", "F0", "F1", "F2", "F3"]
            
            for ann in allAnnunciators {
                let shouldExist = expectedAnns.contains(ann)
                var doesExist = false
                if ann == "🔒 EXAM" { doesExist = app.staticTexts["exam_indicator"].exists || app.staticTexts[ann].exists }
                else if ann == "↑" { doesExist = app.staticTexts["stack_indicator"].exists || app.staticTexts[ann].exists }
                else { doesExist = app.staticTexts[ann].exists }
                
                if doesExist != shouldExist {
                    print("❌ ANNUNCIATOR MISMATCH on \(deviceName)! \(ann) Expected: \(shouldExist), Got: \(doesExist) for seq: \(seq)")
                    mismatch = true
                }
            }
            
            let stateJSONString = app.staticTexts["semantic_state"].label
            if let stateData = stateJSONString.data(using: .utf8),
               let stateDict = try? JSONSerialization.jsonObject(with: stateData, options: []) as? [String: Any] {
                
                let uiStack = stateDict["stack"] as? [String] ?? []
                let uiPlotCount = stateDict["plotDataPointsCount"] as? Int ?? 0
                
                let expectedStack = json["stackData"] as? [String] ?? []
                let expectedPlotCount = json["plotDataPointsCount"] as? Int ?? 0
                
                if uiStack != expectedStack {
                    print("❌ DEEP STACK MISMATCH on \(deviceName)! Expected: \(expectedStack), Got: \(uiStack) for seq: \(seq)")
                    mismatch = true
                }
                
                if uiPlotCount != expectedPlotCount {
                    print("❌ PLOT METADATA MISMATCH on \(deviceName)! Expected: \(expectedPlotCount), Got: \(uiPlotCount) for seq: \(seq)")
                    mismatch = true
                }
            } else {
                print("⚠️ WARNING: Could not read hidden semantic_state on \(deviceName)")
            }
            
            if !mismatch {
                print("✅ Parity Match (LCD, Annunciators, Stack & Plots): \(lcd) for \(seq)")
                reportResult(device: deviceName, seq: seq, expected: expected, got: lcd, match: true)
            }
            
            
            app.terminate()
            app.launch()
            _ = app.staticTexts["lcd_display"].waitForExistence(timeout: 10)

        }
    }
    func mapOpToIdentifier(_ op: String) -> String {
        if op.hasPrefix("op_") { return op }
        switch op {
        case "0"..."9": return "op_digit\(op)"
        case ".": return "op_decimal"
        case "ENTER": return "op_enter"
        case "C": return "op_backspace"
        case "<-": return "op_backspace"
        case "SQRT": return "op_sqrt"
        case "+": return "op_add"
        case "-": return "op_subtract"
        case "×": return "op_multiply"
        case "÷": return "op_divide"
        case "CHS": return "op_toggleSign"
        case "EEX": return "op_e"
        case "y^x": return "op_power"
        case "1/x": return "op_reciprocal"
        case "LN": return "op_ln"
        case "SIN": return "op_sin"
                case "SHIFT_YELLOW": return "op_shiftYellow"
        case "SHIFT_BLUE": return "op_shiftBlue"
        case "LFU_0": return "op_lfu0"
        case "LFU_1": return "op_lfu1"
        case "LFU_2": return "op_lfu2"
        case "LFU_3": return "op_lfu3"
        case "LFU_4": return "op_lfu4"
        case "LFU_5": return "op_lfu5"
        case "BASE": return "op_base"
        case "DISP": return "op_disp"
        case "EQN": return "op_eqn"
        case "CONST": return "op_const"
        case "PLOT": return "op_plot"
        case "STAT": return "op_stat"
        case "PROG": return "op_prog"
        case "MEM": return "op_mem"
        case "e^x": return "op_exp"
        case "COS": return "op_cos"
        case "TAN": return "op_tan"
        case "+/-": return "op_toggleSign"
        case "x<>y": return "op_swapXY"
        case "STO": return "op_sto"
        case "RCL": return "op_rcl"
        case "R↓": return "op_rollDown"
        default: return "op_\(op)"
        }
    }
}
