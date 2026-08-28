import XCTest
@testable import RPNCore
import Foundation

final class FirmwareQuickTest: XCTestCase {
    func sendCommand(_ cmd: String) {
        var cmdStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "localhost" as CFString, 4445, nil, &cmdStream)
        if let cfStream = cmdStream?.takeRetainedValue() {
            let outStream: OutputStream = cfStream
            outStream.open()
            let data = [UInt8]((cmd + "\n").utf8)
            outStream.write(data, maxLength: data.count)
            outStream.close()
        }
    }
    func takeScreenshot(name: String) {
        var cmdStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "localhost" as CFString, 4446, nil, &cmdStream)
        if let cfStream = cmdStream?.takeRetainedValue() {
            let outStream: OutputStream = cfStream
            outStream.open()
            let data = [UInt8](("DUMP_SCREEN:" + name + "\n").utf8)
            outStream.write(data, maxLength: data.count)
            outStream.close()
        }
    }
    func testQuick() {
        Thread.sleep(forTimeInterval: 2.0)
        
        // Enter '1' as program
        sendCommand("PRGM")
        sendCommand("1")
        sendCommand("ENTER")
        sendCommand("PRGM")
        
        sendCommand("PLOT")
        sendCommand("LFU_0") // Equation
        sendCommand("LFU_3") // EXEC
        Thread.sleep(forTimeInterval: 8.0)
        takeScreenshot(name: "NormalPDF_NewUI2")
    }
}
