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
        XCTAssertEqual(cgImage?.width, 400, "CGImage width should be 400")
        XCTAssertEqual(cgImage?.height, 240, "CGImage height should be 240")
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
        for y in 200..<240 {
            for x in 0..<400 {
                let byteIdx = y * 50 + (x / 8)
                let bitIdx = x % 8
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
        for y in 0..<40 {
            for x in 0..<400 {
                let byteIdx = y * 50 + (x / 8)
                let bitIdx = x % 8
                if (controller.renderer.buffer[byteIdx] & (1 << bitIdx)) != 0 {
                    annunciatorPixelsDrawn = true
                    break
                }
            }
        }
        XCTAssertTrue(annunciatorPixelsDrawn, "Annunciator must render pixels in top region Y: 0-40")
    }
    
    func testHP32SIIDisplayJustification() {
        // 1. Left-justified number entry
        engine.digit(4)
        engine.digit(2)
        controller.render()
        
        var leftSideDigitPixels = 0
        for y in 50..<180 {
            for x in 0..<100 {
                let byteIdx = y * 50 + (x / 8)
                let bitIdx = x % 8
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
        for y in 50..<180 {
            for x in 0..<100 {
                let byteIdx = y * 50 + (x / 8)
                let bitIdx = x % 8
                if (controller.renderer.buffer[byteIdx] & (1 << bitIdx)) != 0 {
                    leftSidePixels += 1
                }
            }
        }
        XCTAssertGreaterThan(leftSidePixels, 0, "Error message must be left-justified starting near left edge")
    }
}


