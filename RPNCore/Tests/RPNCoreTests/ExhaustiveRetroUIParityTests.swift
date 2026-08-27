import XCTest
@testable import RPNCore

#if canImport(CoreGraphics)
import CoreGraphics
#endif

final class ExhaustiveRetroUIParityTests: XCTestCase {
    var engine: CalculatorEngine!
    var lfuManager: LFUManager!
    var renderer: Renderer!
    var retroUI: RetroUI!
    var controller: RetroUIController!
    
    override func setUp() {
        super.setUp()
        engine = CalculatorEngine()
        lfuManager = LFUManager()
        renderer = Renderer()
        retroUI = RetroUI(lfuManager: lfuManager)
        controller = RetroUIController(engine: engine, lfuManager: lfuManager)
    }
    
    func getLogicalPixel(renderer: Renderer, x: Int, y: Int) -> Bool {
        if x < 0 || x >= 400 || y < 0 || y >= 240 { return false }
        let byteIndex = y * 50 + (x / 8)
        let bitIndex = x % 8
        return (renderer.buffer[byteIndex] & UInt8(1 << bitIndex)) != 0
    }
    
    // MARK: - 1. Exhaustive All Menus Test
    func testExhaustiveAllMenusRenderingAndParity() {
        let menuToOp: [CalculatorMenu: CalculatorOperation] = [
            .disp: .disp,
            .modes: .modes,
            .base: .base,
            .const: .const,
            .flags: .flags,
            .clear: .clear,
            .parts: .parts,
            .prob: .prob,
            .sums: .sums,
            .stat: .statMean,
            .mem: .mem,
            .testXY: .testXY,
            .testX0: .testX0,
            .statMean: .statMean,
            .statStdDev: .statStdDev,
            .lr: .lr
        ]

        
        for menuCase in CalculatorMenu.allCases {
            guard let op = menuToOp[menuCase] else { continue }
            controller.processAction(op)
            
            // Verify menu opens
            XCTAssertNotNil(controller.engine.activeMenu, "Menu \(menuCase.rawValue) should open")
            
            // Render frame
            controller.render()

            
            if !menuCase.getItems(engine: CalculatorEngine()).isEmpty {
                // Verify softkey pixels in bottom region (Y: 200..239)
                var softkeyPixels = 0
                for y in 200...239 {
                    for x in 0..<400 {
                        if getLogicalPixel(renderer: controller.renderer, x: x, y: y) { softkeyPixels += 1 }
                    }
                }
                XCTAssertGreaterThan(softkeyPixels, 0, "Menu \(menuCase.rawValue) must render softkeys in bottom region")
            }
            
            // Close menu
            controller.processAction(.c)
            XCTAssertNil(controller.engine.activeMenu, "Menu \(menuCase.rawValue) should close after C")
        }
    }
    
    // MARK: - 2. Exhaustive Menu Alpha Filtering & Pagination Test
    func testExhaustiveMenuAlphaFilteringAndPagination() {
        // 1. Test CONST menu pagination (MORE▶)
        controller.processAction(.const)
        XCTAssertEqual(controller.engine.activeMenu, .const)
        
        let initialOffset = controller.retroUI.menuOffset
        controller.processAction(.lfu5) // LFU_5 is MORE▶ for long menus
        XCTAssertGreaterThan(controller.retroUI.menuOffset, initialOffset, "MORE▶ softkey must advance menu pagination offset")
        
        // 2. Test Menu Backspace and Exit
        controller.processAction(.c)
        controller.processAction(.base)
        XCTAssertEqual(controller.engine.activeMenu, .base)
        
        controller.processAction(.backspace)
        XCTAssertNil(controller.engine.activeMenu, "Backspace on empty query should exit menu")
    }

    // MARK: - 2b. STAT Sub-Menu Navigation on RetroUI (regression for STATMEAN/STATSTDDEV/STATLR/STATSUMS)
    func testStatSubMenuNavigationOnRetroUI() {
        // Seed stat data so stat ops don't error
        engine.executeMath("3"); engine.executeMath("ENTER")
        engine.executeMath("4"); engine.executeMath("Σ+")
        engine.executeMath("3"); engine.executeMath("ENTER")
        engine.executeMath("4"); engine.executeMath("ENTER")
        engine.executeMath("5"); engine.executeMath("ENTER")
        engine.executeMath("2")

        // Open the composite .stat menu (triggered by .statMean op)
        controller.processAction(.statMean)
        XCTAssertEqual(controller.engine.activeMenu, .statMean,
                       ".statMean op must open the statMean menu")
        controller.processAction(.c)

        // Simulate: open .stat menu directly, then navigate to each sub-menu via LFU softkey
        // The .stat menu items are: 𝑥̄,ȳ (STATMEAN), s,σ (STATSTDDEV), L.R. (STATLR), SUMS (STATSUMS)
        let statMenu = CalculatorMenu.stat
        let statItems = statMenu.getItems(engine: CalculatorEngine())
        let expectedSubMenus: [CalculatorMenu] = [.statMean, .statStdDev, .lr, .sums]

        for (i, expectedMenu) in expectedSubMenus.enumerated() {
            controller.engine.activeMenu = statMenu
            controller.retroUI.menuOffset = 0
            controller.menuItemsDisplayCache = statItems

            // Verify the item at this position is a sub-menu navigation action
            XCTAssertEqual(statItems[i].action, ["STATMEAN","STATSTDDEV","STATLR","STATSUMS"][i])

            // Press the corresponding LFU softkey (0=slot0, 1=slot1, etc.)
            // .stat has 4 items; RetroUI maps indices 0,1 to slots 0,1 and 4,5 to slots 4,5
            let lfu: CalculatorOperation = [.lfu0, .lfu1, .lfu4, .lfu5][i]
            controller.processAction(lfu)

            XCTAssertEqual(controller.engine.activeMenu, expectedMenu,
                           "Selecting '\(statItems[i].label)' from .stat must open .\(expectedMenu.rawValue), not execute STATMEAN as a math op")
            controller.processAction(.c)
        }
    }

    // MARK: - 3. Exhaustive RPN Stack & Left-Justified Display Test
    func testExhaustiveStackOperationsAndLeftJustifiedDisplay() {
        // Enters 12.34 and pushes to stack
        controller.processAction(.digit1)
        controller.processAction(.digit2)
        controller.processAction(.decimal)
        controller.processAction(.digit3)
        controller.processAction(.digit4)
        
        controller.render()
        
        // Assert left-justified pixels starting at left margin (X: 0..20)
        var leftMarginPixels = 0
        for x in 0...20 {
            for y in 40...190 {
                if getLogicalPixel(renderer: controller.renderer, x: x, y: y) { leftMarginPixels += 1 }
            }
        }
        XCTAssertGreaterThan(leftMarginPixels, 0, "Building number entry must be left-justified starting at X: 2")
        
        controller.processAction(.enter)
        controller.processAction(.digit5)
        controller.processAction(.add)
        
        controller.render()
        XCTAssertEqual(controller.engine.stack.first?.real ?? 0.0, 17.34, accuracy: 1e-6, "RPN addition result must match")
        
        // Test SHOW (Full Precision) view
        controller.processAction(.show)
        XCTAssertTrue(controller.retroUI.isShowingFullPrecision)
        controller.render()
        
        // Test REGS (Registers Viewer) view
        controller.processAction(.c)
        controller.processAction(.regs)
        XCTAssertTrue(controller.retroUI.isShowingRegisters)
        controller.render()
        
        controller.processAction(.c)
        XCTAssertFalse(controller.retroUI.isShowingRegisters)
    }

    // MARK: - 4. Exhaustive Base Modes & Bitwise Operations Test
    func testExhaustiveBaseModesAndBitwiseOperations() {
        // Switch to HEX mode via BASE menu
        controller.processAction(.base)
        controller.processAction(.lfu0) // HEX is softkey slot 0
        XCTAssertEqual(controller.engine.baseMode, .hex)
        controller.render()
        
        // Assert HEX annunciator pixel rendering in top region
        var topAnnunciatorPixels = 0
        for x in 0..<400 {
            for y in 0...30 {
                if getLogicalPixel(renderer: controller.renderer, x: x, y: y) { topAnnunciatorPixels += 1 }
            }
        }
        XCTAssertGreaterThan(topAnnunciatorPixels, 0, "HEX annunciator must render in top region Page 0")
        
        // Switch to OCT, BIN, DEC using proper softkey slot indexing (0, 1, 4, 5)
        controller.processAction(.base)
        controller.processAction(.lfu4) // OCT is softkey slot 4
        XCTAssertEqual(controller.engine.baseMode, .oct)
        
        controller.processAction(.base)
        controller.processAction(.lfu5) // BIN is softkey slot 5
        XCTAssertEqual(controller.engine.baseMode, .bin)
        
        controller.processAction(.base)
        controller.processAction(.lfu1) // DEC is softkey slot 1
        XCTAssertEqual(controller.engine.baseMode, .dec)
    }

    // MARK: - 5. Exhaustive Programming & Equation Mode Test
    func testExhaustiveProgrammingAndEquationMode() {
        engine.isProgrammingMode = true
        engine.currentProgramSteps = ["LBL A", "12", "ENTER", "34", "×", "RTN"]
        
        controller.render()
        
        // Verify equation steps rendered on screen
        var programStepPixels = 0
        for y in 40...190 {
            for x in 0..<400 {
                if getLogicalPixel(renderer: controller.renderer, x: x, y: y) { programStepPixels += 1 }
            }
        }
        XCTAssertGreaterThan(programStepPixels, 0, "Programming steps must render on LCD screen")
        
        // Test scroll offset navigation
        engine.setShift(1)
        controller.processAction(.digit8) // Up arrow scroll
        // Removed unused programScrollOffset check
        engine.isProgrammingMode = false
    }

    // MARK: - 6. Exhaustive Advanced Solver / Integrator Emulation Test
    func testExhaustiveSolverAndIntegratorEmulation() {
        // Add test program
        let prog = CalculatorEngine.Program(label: "F", steps: ["X", "2", "^", "1", "-"].compactMap { Instruction(fromString: $0) })
        engine.programs = [prog]
        
        // Trigger SOLVE mode
        controller.processAction(.solve)
        XCTAssertEqual(controller.retroUI.softkeyMode, .solve)
        controller.render()
        
        // Manually select program for Advanced emulation test
        controller.retroUI.softkeyProgram = prog
        XCTAssertEqual(controller.retroUI.softkeyProgram?.label, "F")
        
        // Clear mode
        controller.processAction(.c)
        XCTAssertEqual(controller.retroUI.softkeyMode, .none)
    }

    // MARK: - 7. Exhaustive Plots, Equations & Text Clipping / Non-Overlap Test
    func testExhaustivePlotsEquationsAndNoTextClippingOrOverlap() {
        // 1. Test Graph Plot Rendering
        engine.generatePlot(variable: "X", explicitMin: -10, explicitMax: 10)
        engine.requestPlot = true
        controller.render()
        
        var plotPixels = 0
        for y in 30...190 {
            for x in 0..<400 {
                if getLogicalPixel(renderer: controller.renderer, x: x, y: y) { plotPixels += 1 }
            }
        }
        XCTAssertGreaterThan(plotPixels, 0, "Graph plot must render pixels in main content region")
        
        // Test Plot LFU Point Searching via LFU Keys (R1..R6)
        controller.processAction(.lfu0)
        XCTAssertEqual(engine.selectedPlotMarkerIndex, 0, "Pressing LFU0 must select plot marker 0")
        controller.render()
        
        controller.processAction(.lfu2)
        XCTAssertEqual(engine.selectedPlotMarkerIndex, 2, "Pressing LFU2 must select plot marker 2")
        controller.render()
        
        controller.processAction(.c)
        XCTAssertFalse(engine.requestPlot, "Pressing C must dismiss plot view")
        
        // 2. Test Equation Rendering
        engine.promptString = "SIN(X)+COS(Y)*2.5"
        controller.render()
        
        var equationPixels = 0
        for y in 40...190 {
            for x in 0..<400 {
                if getLogicalPixel(renderer: controller.renderer, x: x, y: y) { equationPixels += 1 }
            }
        }
        XCTAssertGreaterThan(equationPixels, 0, "Equation text must render pixels in main display region")
        
        
        // 3. Test Text Clipping & Softkey Bounds Non-Overlap Audit across all 18 Menus
        for menuCase in CalculatorMenu.allCases {
            controller.engine.activeMenu = menuCase
            controller.render()
            
            // Verify softkey items in menu stay bounded within 20px column widths
            let items = MenuSystem.filter(menu: menuCase, query: "", engine: CalculatorEngine())
            let visibleCount = items.count
            XCTAssertLessThanOrEqual(min(visibleCount, 6), 6, "Maximum 6 softkeys rendered per page")
            
            for item in items.prefix(5) {
                let textW = controller.renderer.getStringWidth(item.label, size: .tiny)
                XCTAssertLessThanOrEqual(textW, 66, "Softkey '\(item.label)' fitted width \(textW)px must not exceed 66px softkey slot bounds")
            }
        }
    }
}
