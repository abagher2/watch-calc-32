import XCTest
@testable import RPNCore

#if canImport(CoreGraphics)
import CoreGraphics
#endif

final class RetroUIParityTests: XCTestCase {
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

    #if canImport(CoreGraphics)
    func testCGImageGeneration() {
        engine.digit(4)
        engine.digit(2)
        engine.enter()
        engine.digit(5)
        engine.executeMath("×")
        
        controller.render()
        
        let cgImage = controller.renderer.toCGImage()
        XCTAssertNotNil(cgImage, "Renderer.toCGImage() should produce a valid CGImage")
        XCTAssertEqual(cgImage?.width, 132, "CGImage width should be 132")
        XCTAssertEqual(cgImage?.height, 65, "CGImage height should be 65")
    }
    #endif
    
    func testBasicValueFormatterParity() {
        let formatter = BasicValueFormatter()
        
        let fixResult = formatter.format(value: 3.14159, mode: .fix(4))
        XCTAssertEqual(fixResult, "3.1416")
        
        let sciResult = formatter.format(value: 1234.56, mode: .sci(2))
        XCTAssertTrue(sciResult.contains("E"))
        
        let engResult = formatter.format(value: 0.00456, mode: .eng(2))
        XCTAssertTrue(engResult.contains("E"))
        
        let allResult = formatter.format(value: 42.0, mode: .all)
        XCTAssertEqual(allResult, "42")
    }

    func testBaseMenuSoftkey() {
        controller.processAction(.base)
        XCTAssertEqual(controller.engine.activeMenu?.rawValue, "BASE")
        
        controller.processAction(.lfu0)
        XCTAssertEqual(controller.engine.baseMode, .hex)
        XCTAssertNil(controller.engine.activeMenu)
    }

    func testDispMenuSoftkeyAndFix4() {
        controller.processAction(.disp)
        XCTAssertEqual(controller.engine.activeMenu?.rawValue, "DISP")
        
        controller.processAction(.lfu0)
        XCTAssertEqual(controller.retroUI.waitingForMenuDigit?.action, "FIX")
        XCTAssertNil(controller.engine.activeMenu)
        
        controller.processAction(.digit4)
        if case .fix(let p) = controller.engine.displayMode {
            XCTAssertEqual(p, 4)
        } else {
            XCTFail("Expected .fix(4)")
        }
        XCTAssertNil(controller.retroUI.waitingForMenuDigit)
    }
    
    func testShowModeToggle() {
        controller.processAction(.show)
        XCTAssertTrue(controller.retroUI.isShowingFullPrecision)
        controller.processAction(.c)
        XCTAssertFalse(controller.retroUI.isShowingFullPrecision)
    }
    
    func testRegsModeToggle() {
        controller.processAction(.regs)
        XCTAssertTrue(controller.retroUI.isShowingRegisters)
        controller.processAction(.c)
        XCTAssertFalse(controller.retroUI.isShowingRegisters)
    }
    
    func testLayoutRegionNonOverlapping() {
        // 1. Softkey row (Y: 200-239)
        controller.processAction(.base) // Opens softkey menu
        controller.render()
        
        var softkeyPixelsDrawn = false
        for y in 54..<65 {
            for x in 0..<132 {
                let byteIdx = (y / 8) * 132 + x
                let bitIdx = y % 8
                if (controller.renderer.buffer[byteIdx] & (1 << bitIdx)) != 0 {
                    softkeyPixelsDrawn = true
                    break
                }
            }
        }
        XCTAssertTrue(softkeyPixelsDrawn, "Softkeys must render pixels in softkey region Y: 200-239")
        
        // 2. Annunciators row (Y: 0-40)
        controller.processAction(.c) // Close menu
        engine.setShift(1)
        controller.render()
        
        var annunciatorPixelsDrawn = false
        for y in 0..<11 {
            for x in 0..<132 {
                let byteIdx = (y / 8) * 132 + x
                let bitIdx = y % 8
                if (controller.renderer.buffer[byteIdx] & (1 << bitIdx)) != 0 {
                    annunciatorPixelsDrawn = true
                    break
                }
            }
        }
        XCTAssertTrue(annunciatorPixelsDrawn, "Annunciator must render pixels in top region Y: 0-11")
    }
    
    func testAllAnnunciatorsRendering() {
        let states: [(setup: (CalculatorEngine) -> Void, name: String)] = [
            ({ $0.shiftState = 1 }, "↰"),
            ({ $0.shiftState = 2 }, "↱"),
            ({ $0.angleMode = .rad }, "RAD"),
            ({ $0.angleMode = .grd }, "GRD"),
            ({ $0.complexMode = true }, "CMPLX"),
            ({ $0.isExamMode = true }, "🔒 EXAM"),
            ({ $0.autoReturnToMainPad = false }, "STAY"),
            ({ $0.isHypPending = true }, "HYP"),
            ({ $0.stack.append(CalculatorValue(real: 1)); $0.stack.append(CalculatorValue(real: 1)); $0.stack.append(CalculatorValue(real: 1)); $0.stack.append(CalculatorValue(real: 1)); $0.stack.append(CalculatorValue(real: 1)) }, "↑"),
            ({ $0.isProgrammingMode = true }, "EQN"),
            ({ $0.baseMode = .hex }, "HEX"),
            ({ $0.baseMode = .oct }, "OCT"),
            ({ $0.baseMode = .bin }, "BIN"),
            ({ $0.isStatPlot = true }, "STAT"),
            ({ $0.isWaitingForAlpha = true }, "A..Z")
        ]
        
        for state in states {
            engine = CalculatorEngine() // Fresh engine
            controller = RetroUIController(engine: engine, lfuManager: lfuManager)
            
            state.setup(engine)
            controller.render()
            
            var pixels = 0
            for y in 0..<11 {
                for x in 0..<132 {
                    let byteIdx = (y / 8) * 132 + x
                    let bitIdx = y % 8
                    if (controller.renderer.buffer[byteIdx] & (1 << bitIdx)) != 0 {
                        pixels += 1
                    }
                }
            }
            XCTAssertGreaterThan(pixels, 0, "Annunciator '\(state.name)' failed to render any pixels in top region Y: 0-11")
        }
    }
    
    func testHP32SIIDisplayJustification() {
        // 1. Left-justified number entry
        engine.digit(4)
        engine.digit(2)
        controller.render()
        
        var leftSideDigitPixels = 0
        for y in 11..<54 {
            for x in 0..<100 {
                let byteIdx = (y / 8) * 132 + x
                let bitIdx = y % 8
                if (controller.renderer.buffer[byteIdx] & (1 << bitIdx)) != 0 {
                    leftSideDigitPixels += 1
                }
            }
        }
        XCTAssertGreaterThan(leftSideDigitPixels, 0, "Building number entry must be left-justified starting near left edge")
        
        // 2. Left-justified error message
        engine.errorMessage = "INVALID DATA"
        controller.render()
        
        var leftSidePixels = 0
        for y in 11..<54 {
            for x in 0..<100 {
                let byteIdx = (y / 8) * 132 + x
                let bitIdx = y % 8
                if (controller.renderer.buffer[byteIdx] & (1 << bitIdx)) != 0 {
                    leftSidePixels += 1
                }
            }
        }
        XCTAssertGreaterThan(leftSidePixels, 0, "Error message must be left-justified starting near left edge")
    }


    func testStackMenuSoftkeys() {
        controller.processAction(.flags)
        XCTAssertEqual(controller.engine.activeMenu?.rawValue, "FLAGS")
        
        controller.render() // Must render to populate LFU manager slots
        
        // "STACK ▸" is the 1st item in the firmware FLAGS menu.
        // It appears on the 1st softkey (.lfu0).
        controller.processAction(.lfu0)
        
        XCTAssertEqual(controller.engine.activeMenu?.rawValue, "STACK")
        
        controller.render() // Must render to populate LFU manager slots
        
        XCTAssertEqual(controller.menuItemsDisplayCache[0].label, "4-LVL")
        controller.processAction(.lfu0)
        
        XCTAssertEqual(controller.engine.stackSizeLimit, 4)
        XCTAssertNil(controller.engine.activeMenu)
    }

    func testPlotRendering() {
        engine.programs = [] // clear programs
        let p = CalculatorEngine.Program(label: "A", steps: [Instruction(fromString: "𝑥²")!])
        engine.programs.append(p)
        engine.currentProgramLabel = "A"
        
        engine.digit(1)
        engine.enter()
        engine.digit(2)
        engine.enter()
        engine.digit(3)
        engine.enter()
        engine.digit(4)
        
        controller.processAction(.plot)
        controller.render()
        
        var plotPixels = 0
        for y in 0..<54 { // above softkeys
            for x in 0..<132 {
                let byteIdx = (y / 8) * 132 + x
                let bitIdx = y % 8
                if (controller.renderer.buffer[byteIdx] & (1 << bitIdx)) != 0 {
                    plotPixels += 1
                }
            }
        }
        XCTAssertGreaterThan(plotPixels, 0, "Plot should render some pixels on the screen")
    }
}
