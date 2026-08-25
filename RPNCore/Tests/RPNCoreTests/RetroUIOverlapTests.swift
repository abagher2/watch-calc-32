import XCTest
@testable import RPNCore

final class RetroUIOverlapTests: XCTestCase {
    var engine: CalculatorEngine!
    var lfuManager: LFUManager!
    var renderer: Renderer!
    var retroUI: RetroUI!
    
    override func setUp() {
        super.setUp()
        engine = CalculatorEngine()
        lfuManager = LFUManager()
        renderer = Renderer()
        renderer.detectOverlap = true
        retroUI = RetroUI(lfuManager: lfuManager)
    }

    func testNoOverlapInStandardMode() {
        engine.digit(1)
        engine.digit(2)
        engine.digit(3)
        engine.enter()
        engine.digit(4)
        engine.digit(5)
        
        renderer.clear()
        retroUI.render(engine: engine, renderer: renderer)
        XCTAssertFalse(renderer.hasOverlap, "Pixels should not overlap in standard mode")
    }
    
    func testNoOverlapInMenuMode() {
        engine.digit(1)
        engine.activeMenu = .modes
        
        renderer.clear()
        retroUI.render(engine: engine, renderer: renderer)
        XCTAssertFalse(renderer.hasOverlap, "Pixels should not overlap when rendering menus")
    }
    
    func testNoOverlapInEquationMode() {
        engine.isEquationMode = true
        engine.currentEquation = "X+1"
        
        renderer.clear()
        retroUI.render(engine: engine, renderer: renderer)
        XCTAssertFalse(renderer.hasOverlap, "Pixels should not overlap in equation mode")
    }
    
    func testNoOverlapInPlotMode() {
        engine.requestPlot = true
        engine.plotData = [(0, 0), (1, 1), (2, 4), (3, 9)]
        engine.selectedPlotMarkerIndex = 2
        
        renderer.clear()
        retroUI.render(engine: engine, renderer: renderer)
        XCTAssertFalse(renderer.hasOverlap, "Pixels should not overlap in plot mode")
    }
    
    func testNoOverlapWithIndicators() {
        engine.isHypPending = true
        engine.isStatPlot = true
        engine.isWaitingForAlpha = true
        engine.digit(1)
        engine.enter()
        
        renderer.clear()
        retroUI.render(engine: engine, renderer: renderer)
        XCTAssertFalse(renderer.hasOverlap, "Pixels should not overlap with indicators visible")
    }
}
