import XCTest
@testable import RPNCore

/// Exhaustive parity tests: every MenuItem.action must be accepted by CalculatorEngine
/// without producing an error. This catches action string mismatches between MenuSystem
/// and the engine's executeMath/executeOp switch.
final class MenuParityTests: XCTestCase {

    var engine: CalculatorEngine!

    override func setUp() {
        super.setUp()
        engine = CalculatorEngine()
        // Pre-load stat registers so LR / stddev / mean ops have data
        engine.executeMath("3"); engine.executeMath("ENTER")
        engine.executeMath("4"); engine.executeMath("Σ+")
        engine.executeMath("5"); engine.executeMath("ENTER")
        engine.executeMath("6"); engine.executeMath("Σ+")
        engine.executeMath("7"); engine.executeMath("ENTER")
        engine.executeMath("8"); engine.executeMath("Σ+")
        seedStack()
    }

    // Sub-menu navigation actions open another menu, not a math op.
    private let subMenuNavigationActions: Set<String> = [
        "STATMEAN", "STATSTDDEV", "STATLR", "STATSUMS",
        "VARS", "PRGM", "REGS"
    ]

    func testAllMenuItemActionsAreHandledByEngine() {
        var failures: [String] = []

        for menu in CalculatorMenu.allCases {
            for item in menu.getItems(engine: CalculatorEngine()) {
                if subMenuNavigationActions.contains(item.action) { continue }

                let action = item.requiresDigit ? item.action + " 4" : item.action
                
                // Use a fresh engine per item to prevent state leakage (e.g. large constants overflowing Int64)
                let freshEngine = CalculatorEngine()
                freshEngine.executeMath("3"); freshEngine.executeMath("ENTER")
                freshEngine.executeMath("4"); freshEngine.executeMath("Σ+")
                freshEngine.executeMath("5"); freshEngine.executeMath("ENTER")
                freshEngine.executeMath("6"); freshEngine.executeMath("Σ+")
                freshEngine.executeMath("3"); freshEngine.executeMath("ENTER")
                freshEngine.executeMath("4"); freshEngine.executeMath("ENTER")
                freshEngine.executeMath("5"); freshEngine.executeMath("ENTER")
                freshEngine.executeMath("2")

                freshEngine.errorMessage = nil
                freshEngine.executeMath(action)

                if let err = freshEngine.errorMessage {
                    failures.append("[\(menu.rawValue)] '\(item.label)' (action: '\(action)') → error: \(err)")
                }
            }
        }

        XCTAssertTrue(failures.isEmpty,
            "Menu items with broken engine actions:\n" + failures.joined(separator: "\n"))
    }

    func testDispMenuSetsDisplayMode() {
        engine.executeMath("FIX 4"); XCTAssertEqual(engine.displayMode, .fix(4))
        engine.executeMath("SCI 3"); XCTAssertEqual(engine.displayMode, .sci(3))
        engine.executeMath("ENG 2"); XCTAssertEqual(engine.displayMode, .eng(2))
        engine.executeMath("SIG 5"); XCTAssertEqual(engine.displayMode, .sig(5))
        engine.executeMath("ALL");   XCTAssertEqual(engine.displayMode, .all)
    }

    func testModesMenuSetsAngleMode() {
        engine.executeMath("DEG");  XCTAssertEqual(engine.angleMode, .deg)
        engine.executeMath("RAD");  XCTAssertEqual(engine.angleMode, .rad)
        engine.executeMath("GRAD"); XCTAssertEqual(engine.angleMode, .grd)
        engine.executeMath("GRD");  XCTAssertEqual(engine.angleMode, .grd)
    }

    func testPartsMenuOperations() {
        let freshEngine = CalculatorEngine()
        
        freshEngine.executeMath("3"); freshEngine.executeMath("."); freshEngine.executeMath("7"); freshEngine.executeMath("ENTER")
        freshEngine.executeMath("ABS")
        XCTAssertEqual(freshEngine.stack.first!.real, 3.7, accuracy: 1e-10)
        
        freshEngine.executeMath("3"); freshEngine.executeMath("."); freshEngine.executeMath("7"); freshEngine.executeMath("ENTER")
        freshEngine.executeMath("INTG")
        XCTAssertEqual(freshEngine.stack.first!.real, 3.0, accuracy: 1e-10)
        
        freshEngine.executeMath("3"); freshEngine.executeMath("."); freshEngine.executeMath("7"); freshEngine.executeMath("ENTER")
        freshEngine.executeMath("FRAC")
        XCTAssertEqual(freshEngine.stack.first!.real, 0.7, accuracy: 1e-10)
        
        freshEngine.executeMath("5"); freshEngine.executeMath("+/-"); freshEngine.executeMath("ENTER")
        freshEngine.executeMath("SGN")
        XCTAssertEqual(freshEngine.stack.first!.real, -1.0, accuracy: 1e-10)
        
        freshEngine.executeMath("5"); freshEngine.executeMath("ENTER")
        freshEngine.executeMath("SGN")
        XCTAssertEqual(freshEngine.stack.first!.real, 1.0, accuracy: 1e-10)
        
        freshEngine.executeMath("0"); freshEngine.executeMath("ENTER")
        freshEngine.executeMath("SGN")
        XCTAssertEqual(freshEngine.stack.first!.real, 0.0, accuracy: 1e-10)
    }

    func testCLxZerosXRegister() {
        engine.executeMath("5")
        engine.executeMath("CLx")
        XCTAssertEqual(engine.stack.first!.real, 0.0, accuracy: 1e-10)
        XCTAssertNil(engine.errorMessage)
    }

    func testComparisonOperatorsXY() {
        let ops = ["x=y","x≠y","x>y","x<y","x≥y","x≤y"]
        for op in ops {
            engine.errorMessage = nil
            engine.executeMath(op)
            XCTAssertNil(engine.errorMessage, "'\(op)' should not error")
            seedStack()
        }
    }

    func testComparisonOperatorsX0() {
        let ops = ["x=0","x≠0","x>0","x<0","x≥0","x≤0"]
        for op in ops {
            engine.executeMath("2")
            engine.errorMessage = nil
            engine.executeMath(op)
            XCTAssertNil(engine.errorMessage, "'\(op)' should not error")
            seedStack()
        }
    }

    func testClearMenuHasCLx() {
        let items = CalculatorMenu.clear.getItems(engine: CalculatorEngine())
        XCTAssertTrue(items.contains(where: { $0.label == "CLx" }))
    }

    func testProbMenuHas4Items() {
        let items = CalculatorMenu.prob.getItems(engine: CalculatorEngine())
        XCTAssertEqual(items.count, 4)
        XCTAssertTrue(items.contains(where: { $0.label == "Cn,r" }))
        XCTAssertTrue(items.contains(where: { $0.label == "Pn,r" }))
        XCTAssertTrue(items.contains(where: { $0.label == "n!" }))
        XCTAssertTrue(items.contains(where: { $0.label == "RAND" }))
    }

    func testLRMenuHas5Items() {
        let items = CalculatorMenu.lr.getItems(engine: CalculatorEngine())
        XCTAssertEqual(items.count, 5)
        XCTAssertTrue(items.contains(where: { $0.label == "ŷ" }))
        XCTAssertTrue(items.contains(where: { $0.label == "x̂" }))
        XCTAssertTrue(items.contains(where: { $0.label == "r" }))
        XCTAssertTrue(items.contains(where: { $0.label == "m" }))
        XCTAssertTrue(items.contains(where: { $0.label == "b" }))
    }

    func testStatCompositeHasSubMenuNavigationActions() {
        let actions = CalculatorMenu.stat.getItems(engine: CalculatorEngine()).map(\.action)
        XCTAssertTrue(actions.contains("STATMEAN"))
        XCTAssertTrue(actions.contains("STATSTDDEV"))
        XCTAssertTrue(actions.contains("STATLR"))
        XCTAssertTrue(actions.contains("STATSUMS"))
    }

    func testFlagsDigitItems() {
        let flags = CalculatorMenu.flags.getItems(engine: CalculatorEngine())
        for item in flags where ["SF","CF","FS?","FC?"].contains(item.label) {
            XCTAssertTrue(item.requiresDigit, "\(item.label) must requiresDigit")
        }
    }

    private func seedStack() {
        engine.executeMath("3"); engine.executeMath("ENTER")
        engine.executeMath("4"); engine.executeMath("ENTER")
        engine.executeMath("5"); engine.executeMath("ENTER")
        engine.executeMath("2")
    }
}
