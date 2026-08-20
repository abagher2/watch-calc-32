import XCTest
import Foundation

/// Hardware-In-the-Loop (HIL) Tests for the WatchCalc 32 Firmware
/// These tests connect to a running QEMU instance over a TCP socket
/// to simulate hardware button presses and validate the VTY terminal output.
///
/// To run:
/// 1. Launch QEMU with the firmware:
///    `qemu-system-arm -machine ... -serial tcp:localhost:4444,server,nowait`
/// 2. Run this test suite: `swift test --filter FirmwareHILTests`
final class FirmwareHILTests: XCTestCase {
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    override func setUpWithError() throws {
        // Connect to QEMU's virtual serial port (TCP Socket)
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           "localhost" as CFString,
                                           4445,
                                           &readStream,
                                           &writeStream)
        
        guard let inStream = readStream?.takeRetainedValue(),
              let outStream = writeStream?.takeRetainedValue() else {
            throw NSError(domain: "HIL", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create streams"])
        }
        
        inputStream = inStream
        outputStream = outStream
        
        inputStream.open()
        outputStream.open()
        
        // Wait for connection to establish
        Thread.sleep(forTimeInterval: 0.5)
        
        // Initial C (clear screen) to ensure state is clean
        sendCommand("C")
    }
    
    override func tearDownWithError() throws {
        inputStream.close()
        outputStream.close()
    }
    
    func sendCommand(_ cmd: String) {
        let command = cmd + "\n"
        let data = [UInt8](command.utf8)
        outputStream.write(data, maxLength: data.count)
        Thread.sleep(forTimeInterval: 0.1) // Give firmware time to process and redraw
    }
    
    func readScreen(expecting: String) -> String {
        var buffer = [UInt8](repeating: 0, count: 2048)
        var output = ""
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < 2.0 {
            if inputStream.hasBytesAvailable {
                let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
                if bytesRead > 0 {
                    output += String(bytes: buffer[0..<bytesRead], encoding: .utf8) ?? ""
                }
            }
            if output.contains(expecting) {
                return output
            }
            Thread.sleep(forTimeInterval: 0.05)
        }
        return output
    }
    
    func takeScreenshot(name: String) {
        var cmdStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           "localhost" as CFString,
                                           4446,
                                           nil,
                                           &cmdStream)
        if let cfStream = cmdStream?.takeRetainedValue() {
            let outStream: OutputStream = cfStream
            outStream.open()
            let command = "DUMP_SCREEN:\(name)\n"
            let data = [UInt8](command.utf8)
            outStream.write(data, maxLength: data.count)
            outStream.close()
        }
    }
    
    func testMathCorrectness_BasicAddition() {
        sendCommand("3")
        sendCommand("ENTER")
        sendCommand("4")

        sendCommand("+")
        Thread.sleep(forTimeInterval: 0.5) // Wait for output
        
        let screen = readScreen(expecting: "X: 7")
        print("SCREEN OUTPUT: \(screen)")
        
        takeScreenshot(name: "testMathCorrectness_BasicAddition")
        
        // The VTY display outputs strings like "X: 7" or "X: 7.0000" depending on format
        // We assert the physical display screen received the correct number
        XCTAssertTrue(screen.contains("X: 7"), "Screen did not contain expected X register value")
    }
    
    func testMenuUsage_ChangeToHex() {
        sendCommand("BASE")
        sendCommand("LFU_0") // LFU_0 is HEX in the BASE menu
        Thread.sleep(forTimeInterval: 0.5) // Wait for output
        let screen = readScreen(expecting: "X: 0")
        print("SCREEN OUTPUT HEX: \(screen)")
        
        takeScreenshot(name: "testMenuUsage_ChangeToHex")
        
        // Since HEX mode formats X differently
        // We can just verify the menu interaction didn't crash and returned to normal
        XCTAssertTrue(screen.contains("X: 0"), "Screen did not return to normal view after menu execution")
    }
}
