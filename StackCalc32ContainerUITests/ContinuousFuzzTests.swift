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

    func testStandardParityFuzzing() throws {
        try testParityFuzzingImpl()
    }

    func testRetroUIParityFuzzing() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launchArguments.append("-useRetroUI")
        app.launch()
        try testParityFuzzingImpl()
    }

    func testLandscapeParityFuzzing() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
        
        XCUIDevice.shared.orientation = .landscapeRight
        try testParityFuzzingImpl()
    }


    func testParityFuzzingImpl() throws {
        print(app.debugDescription)

        XCTAssertTrue(app.staticTexts["lcd_display"].waitForExistence(timeout: 10), "LCD did not appear in time")

        for _ in 0..<20 {
            guard let url = URL(string: "http://127.0.0.1:8181/next"),
                  let data = try? Data(contentsOf: url),
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let seq = json["sequence"] as? [String],
                  let expected = json["expected"] as? String else { continue }
            
            if seq.isEmpty { continue }
            
            for op in seq {
                let keys = self.mapOpToIdentifiers(op)
                for key in keys {
                    if app.buttons[key].exists {
                        app.buttons[key].firstMatch.tap()
                    } else if app.staticTexts[key].exists {
                        app.staticTexts[key].firstMatch.tap()
                    } else {
                        // Try to swipe!
                        if app.buttons["sim_swipe_left"].exists { app.buttons["sim_swipe_left"].tap() }
                        else { app.swipeLeft() }
                        if app.buttons[key].exists { app.buttons[key].firstMatch.tap() }
                        else { 
                            if app.buttons["sim_swipe_right"].exists { app.buttons["sim_swipe_right"].tap(); app.buttons["sim_swipe_right"].tap() }
                            else { app.swipeRight(); app.swipeRight() }
                        }
                        if app.buttons[key].exists { app.buttons[key].firstMatch.tap() }
                        else { 
                            if app.buttons["sim_swipe_left"].exists { app.buttons["sim_swipe_left"].tap() }
                            else { app.swipeLeft() }
                        }
                    }
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
    func mapOpToIdentifiers(_ op: String) -> [String] {
        if op.hasPrefix("op_digit") {
            let digit = String(op.dropFirst(8))
            return ["btn_\(digit)"]
        }
        switch op {
        case "0"..."9": return ["btn_\(op)"]
        case "op_decimal", ".": return ["btn_."]
        case "op_enter", "ENTER": return ["invisible_ENTER"]
        case "op_backspace", "C": return ["func_<-"]
        case "op_add", "+": return ["func_+"]
        case "op_subtract", "-": return ["func_-"]
        case "op_multiply", "×": return ["func_×"]
        case "op_divide", "÷": return ["func_÷"]
        case "op_sqrt", "√𝑥": return ["func_√𝑥"]
        case "op_reciprocal", "¹/𝑥": return ["op_reciprocal"]
        case "op_sin", "SIN": return ["func_SIN"]
        case "op_cos", "COS": return ["func_COS"]
        case "op_tan", "TAN": return ["func_TAN"]
        case "op_rollDown", "R↓": return ["func_R↓"]
        case "op_swapXY", "x≷y": return ["func_𝑥≷𝑦"]
        
        case "op_shiftYellow": return ["btn_yellow_shift"]
        case "op_shiftBlue": return ["btn_blue_shift"]
        case "op_e": return ["func_E"]
        case "op_toggleSign": return ["func_+/-"]
        case "op_lfu0": return ["func_A..Z"]
        case "op_lfu1": return ["func_F0"]
        case "op_lfu2": return ["func_F1"]
        case "op_lfu3": return ["func_F2"]
        case "op_lfu4": return ["func_F3"]
        case "op_lfu5": return ["func_F4"]
        
        // Handling old string format just in case
        case "𝑥²": return ["btn_yellow_shift", "func_√𝑥"]
        case "ASIN": return ["btn_yellow_shift", "func_SIN"]
        case "ACOS": return ["btn_yellow_shift", "func_COS"]
        case "ATAN": return ["btn_yellow_shift", "func_TAN"]
        case "LAST𝑥": return ["btn_yellow_shift", "func_ENTER"]
        case "%": return ["btn_blue_shift", "func_COS"]
        case "%CHG": return ["btn_blue_shift", "func_TAN"]
        case "ABS": return ["btn_blue_shift", "func_+/-"]
        case "IP": return ["btn_blue_shift", "func_√𝑥", "IP"]
        case "FP": return ["btn_blue_shift", "func_√𝑥", "FP"]
        default: 
            let stringVal = op.replacingOccurrences(of: "op_", with: "")
            return ["func_\(stringVal.uppercased())"]
        }
    }

}
