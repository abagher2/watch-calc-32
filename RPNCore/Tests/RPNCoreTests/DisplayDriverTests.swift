import XCTest
@testable import RPNCore

#if canImport(CoreGraphics)
import CoreGraphics
#endif

final class DisplayDriverTests: XCTestCase {
    
    func testFullRefreshWhenNoPreviousBuffer() {
        let driver = EInkDisplayDriver()
        let renderer = Renderer()
        renderer.drawString("TEST", x: 10, y: 10)
        
        let packet = driver.renderFrame(buffer: renderer.buffer, previousBuffer: nil)
        XCTAssertTrue(packet.isFullRefresh, "Should request full refresh when no previous buffer is provided")
        XCTAssertEqual(packet.width, 128)
        XCTAssertEqual(packet.height, 64)
    }
    
    func testZeroDiffsWhenBuffersIdentical() {
        let driver = EInkDisplayDriver()
        let renderer = Renderer()
        renderer.drawString("SAME", x: 5, y: 5)
        let prevBuffer = renderer.buffer
        
        let packet = driver.renderFrame(buffer: renderer.buffer, previousBuffer: prevBuffer)
        XCTAssertFalse(packet.isFullRefresh)
        XCTAssertEqual(packet.totalChangedPixels, 0, "No pixels should be flagged as changed for identical buffers")
        XCTAssertEqual(packet.width, 0)
        XCTAssertEqual(packet.height, 0)
        XCTAssertTrue(packet.diffBytes.isEmpty)
    }
    
    func testPartialDiffBoundingBox() {
        let driver = EInkDisplayDriver()
        let renderer = Renderer()
        let prevBuffer = renderer.buffer
        
        // Draw small dot at (16, 20)
        renderer.setPixel(x: 16, y: 20, color: true)
        
        let packet = driver.renderFrame(buffer: renderer.buffer, previousBuffer: prevBuffer)
        XCTAssertFalse(packet.isFullRefresh)
        XCTAssertEqual(packet.totalChangedPixels, 1)
        XCTAssertEqual(packet.x, 16, "Bounding box x should align to byte boundary 16")
        XCTAssertEqual(packet.y, 20, "Bounding box y should start at 20")
        XCTAssertGreaterThan(packet.width, 0)
        XCTAssertGreaterThan(packet.height, 0)
        XCTAssertFalse(packet.diffBytes.isEmpty, "Diff bytes should contain packet payload")
    }
    
    #if canImport(CoreGraphics)
    func testCGImageDriverOutput() {
        let driver = CGImageDisplayDriver()
        let renderer = Renderer()
        renderer.drawString("CGIMAGE", x: 2, y: 2)
        
        let cgImage = driver.renderFrame(buffer: renderer.buffer, previousBuffer: nil)
        XCTAssertNotNil(cgImage)
        XCTAssertEqual(cgImage?.width, 128)
        XCTAssertEqual(cgImage?.height, 64)
    }
    #endif
    
    func testOLEDDriverPayload() {
        let driver = OLEDDisplayDriver()
        let renderer = Renderer()
        renderer.setPixel(x: 0, y: 0, color: true)
        
        let payload = driver.renderFrame(buffer: renderer.buffer, previousBuffer: nil)
        XCTAssertEqual(payload.count, 1025)
        XCTAssertEqual(payload[0], 0x40, "First byte must be SSD1306 command control byte 0x40")
    }
}
