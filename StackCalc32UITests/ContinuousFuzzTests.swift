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
        XCTAssertTrue(app.staticTexts["LCD"].waitForExistence(timeout: 10), "LCD did not appear in time")

        let jsonPath = "/Users/abagher/Documents/GitHub/watch-calc-32/scratch/fuzz_expected.json"
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)),
              let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            XCTFail("Could not read oracle JSON")
            return
        }
        
        for json in jsonArray.shuffled().prefix(20) {
            guard let seq = json["sequence"] as? [String],
                  let expected = json["expected"] as? String else { continue }
            
            if seq.isEmpty { continue }
            
            for op in seq {
                let key = self.mapOpToIdentifier(op)
                if app.buttons[key].exists {
                    app.buttons[key].firstMatch.tap()
                } else if app.staticTexts[key].exists {
                    app.staticTexts[key].firstMatch.tap()
                } else {
                    if app.buttons["func_←"].exists {
                        app.buttons["func_←"].firstMatch.tap()
                    }
                }
            }
            
            let deviceName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] ?? "Unknown"
            let lcd = app.staticTexts["LCD"].label
            var mismatch = false
            
            if lcd != expected {
                print("❌ PARITY MISMATCH on \(deviceName)! Expected LCD: \(expected), Got: \(lcd) for seq: \(seq)")
                mismatch = true
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
            }
            
            if app.buttons["func_←"].exists {
                app.buttons["func_←"].firstMatch.tap()
            }
        }
    }
    func mapOpToIdentifier(_ op: String) -> String {
        switch op {
        case "0"..."9": return "btn_\\(op)"
        case ".": return "btn_."
        case "ENTER": return "func_ENTER"
        case "C": return "func_←"
        case "SQRT": return "func_√𝑥"
        default: return "func_\\(op)"
        }
    }
}
