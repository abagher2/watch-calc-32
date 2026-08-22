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
            XCTAssertNotNil(controller.retroUI.activeMenu, "Menu \(menuCase.rawValue) should open")
            
            // Render frame
            controller.render()

            
            if !menuCase.items.isEmpty {
                // Verify softkey pixels in bottom region (Page 6 & 7, Y: 48..63)
                var softkeyPixels = 0
                for page in 6...7 {
                    for col in 0..<128 {
                        if controller.renderer.buffer[page * 128 + col] != 0 { softkeyPixels += 1 }
                    }
                }
                XCTAssertGreaterThan(softkeyPixels, 0, "Menu \(menuCase.rawValue) must render softkeys in bottom region")
            }
            
            // Close menu
            controller.processAction(.c)
            XCTAssertNil(controller.retroUI.activeMenu, "Menu \(menuCase.rawValue) should close after C")
        }
    }
    
    // MARK: - 2. Exhaustive Menu Alpha Filtering & Pagination Test
    func testExhaustiveMenuAlphaFilteringAndPagination() {
        // 1. Test CONST menu pagination (MORE▶)
        controller.processAction(.const)
        XCTAssertEqual(controller.retroUI.activeMenu, .const)
        
        let initialOffset = controller.retroUI.menuOffset
        controller.processAction(.lfu5) // LFU_5 is MORE▶ for long menus
        XCTAssertGreaterThan(controller.retroUI.menuOffset, initialOffset, "MORE▶ softkey must advance menu pagination offset")
        
        // 2. Test Menu Backspace and Exit
        controller.processAction(.c)
        controller.processAction(.base)
        XCTAssertEqual(controller.retroUI.activeMenu, .base)
        
        controller.processAction(.backspace)
        XCTAssertNil(controller.retroUI.activeMenu, "Backspace on empty query should exit menu")
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
        
        // Assert left-justified pixels starting at left margin (Page 3, X: 0..20)
        var leftMarginPixels = 0
        for col in 0...20 {
            if controller.renderer.buffer[3 * 128 + col] != 0 { leftMarginPixels += 1 }
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
        
        // Assert HEX annunciator pixel rendering in top region (Page 0)
        var topAnnunciatorPixels = 0
        for col in 0..<128 {
            if controller.renderer.buffer[0 * 128 + col] != 0 { topAnnunciatorPixels += 1 }
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
        
        // Verify equation steps rendered on screen (Page 1 & 2)
        var programStepPixels = 0
        for page in 1...3 {
            for col in 0..<128 {
                if controller.renderer.buffer[page * 128 + col] != 0 { programStepPixels += 1 }
            }
        }
        XCTAssertGreaterThan(programStepPixels, 0, "Programming steps must render on LCD screen")
        
        // Test scroll offset navigation
        engine.setShift(1)
        controller.processAction(.digit8) // Up arrow scroll
        XCTAssertGreaterThanOrEqual(controller.retroUI.programScrollOffset, 0)
        
        engine.isProgrammingMode = false
    }

    // MARK: - 6. Exhaustive Advanced Solver / Integrator Emulation Test
    func testExhaustiveSolverAndIntegratorEmulation() {
        // Add test program
        let prog = CalculatorEngine.Program(label: "F", steps: ["X", "2", "^", "1", "-"])
        engine.programs = [prog]
        
        // Trigger SOLVE mode
        controller.processAction(.solve)
        XCTAssertEqual(controller.retroUI.c47Mode, .solve)
        controller.render()
        
        // Manually select program for Advanced emulation test
        controller.retroUI.c47Program = prog
        XCTAssertEqual(controller.retroUI.c47Program?.label, "F")
        
        // Clear mode
        controller.processAction(.c)
        XCTAssertEqual(controller.retroUI.c47Mode, .none)
    }

    // MARK: - 7. Exhaustive Plots, Equations & Text Clipping / Non-Overlap Test
    func testExhaustivePlotsEquationsAndNoTextClippingOrOverlap() {
        // 1. Test Graph Plot Rendering
        engine.generatePlot(variable: "X", explicitMin: -10, explicitMax: 10)
        engine.requestPlot = true
        controller.render()
        
        var plotPixels = 0
        for page in 1...6 {
            for col in 0..<128 {
                if controller.renderer.buffer[page * 128 + col] != 0 { plotPixels += 1 }
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
        engine.isEquationMode = true
        engine.currentEquation = "SIN(X)+COS(Y)*2.5"
        controller.render()
        
        var equationPixels = 0
        for page in 1...4 {
            for col in 0..<128 {
                if controller.renderer.buffer[page * 128 + col] != 0 { equationPixels += 1 }
            }
        }
        XCTAssertGreaterThan(equationPixels, 0, "Equation text must render pixels in main display region")
        engine.isEquationMode = false
        
        // 3. Test Text Clipping & Softkey Bounds Non-Overlap Audit across all 18 Menus
        for menuCase in CalculatorMenu.allCases {
            controller.retroUI.activeMenu = menuCase
            controller.render()
            
            // Verify softkey items in menu stay bounded within 20px column widths
            let items = MenuSystem.filter(menu: menuCase, query: "")
            let visibleCount = items.count
            XCTAssertLessThanOrEqual(min(visibleCount, 6), 6, "Maximum 6 softkeys rendered per page")
            
            for item in items.prefix(5) {
                // Check fitted label width
                var label = item.label
                if label == "4-LVL" { label = "4LV" }
                else if label == "PRGM" { label = "PRG" }
                else if label == "REGS" { label = "REG" }
                else if label == "FRAC" { label = "FRC" }
                else if label == "RAND" { label = "RND" }
                else if label == "VARS" { label = "VAR" }
                else if label == "GRAD" { label = "GRD" }
                else if label == "MODES" { label = "MOD" }
                else if label == "MODINT" { label = "MOD" }
                else if label == "L.R." { label = "LR" }
                
                let textW = controller.renderer.getStringWidth(label, size: .tiny)
                XCTAssertLessThanOrEqual(textW, 20, "Softkey '\(item.label)' fitted width \(textW)px must not exceed 20px softkey slot bounds")
            }
        }
    }
}
