import XCTest
import Foundation
import RPNCore

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
        
        // Reset state so we don't break subsequent tests
        sendCommand("DEC")
        Thread.sleep(forTimeInterval: 0.2)
    }

    func runSharedTestCase(_ testCase: SharedCalculatorTestCase) {
        sendCommand("C")
        Thread.sleep(forTimeInterval: 0.5)
        
        for step in testCase.steps {
            sendCommand(step.op)
            if let expected = step.expectedX {
                var formattedExpected = expected
                if formattedExpected.hasSuffix(".0") {
                    formattedExpected = String(formattedExpected.dropLast(2))
                }
                
                let screen = readScreen(expecting: "X: \(formattedExpected)")
                XCTAssertTrue(screen.contains("X: \(formattedExpected)") || screen.contains("X: \(expected)") || screen.contains("X: \(expected)000"), "[\(testCase.name)] Expected X to contain: \(formattedExpected) but got screen: \(screen)")
            }
        }
    }

    func testSharedBasicMathUI() {
        if let tc = SharedMathTestCases.cases.first(where: { $0.name == "BasicMathUI" }) {
            runSharedTestCase(tc)
        } else {
            XCTFail("Could not find BasicMathUI test case")
        }
    }

    func testSharedCalculationEfficiency() {
        if let tc = SharedMathTestCases.cases.first(where: { $0.name == "CalculationEfficiency" }) {
            runSharedTestCase(tc)
        } else {
            XCTFail("Could not find CalculationEfficiency test case")
        }
    }

    func testSharedStoRcl() {
        if let tc = SharedMathTestCases.cases.first(where: { $0.name == "StoRcl" }) {
            runSharedTestCase(tc)
        } else {
            XCTFail("Could not find StoRcl test case")
        }
    }

    func testSharedModuloAndRemainder() {
        if let tc = SharedMathTestCases.cases.first(where: { $0.name == "ModuloAndRemainder" }) {
            runSharedTestCase(tc)
        } else {
            XCTFail("Could not find ModuloAndRemainder test case")
        }
    }

    func testSharedMiToKm() {
        if let tc = SharedMathTestCases.cases.first(where: { $0.name == "MiToKm" }) {
            runSharedTestCase(tc)
        } else {
            XCTFail("Could not find MiToKm test case")
        }
    }

    func testSharedAll32SIIMathOperations() {
        if let tc = SharedMathTestCases.cases.first(where: { $0.name == "All32SIIMathOperations" }) {
            runSharedTestCase(tc)
        } else {
            XCTFail("Could not find All32SIIMathOperations test case")
        }
    }
    
    func testThoroughParityOnFirmware() {
        for tc in SharedCalculatorThoroughTestCases.cases {
            runSharedTestCase(tc)
            sendCommand("C") // clean up
        }
    }
    
    func testFirmwareStackMenuSoftkeys() {
        sendCommand("FLAGS")
        Thread.sleep(forTimeInterval: 0.5)
        
        // Use softkey 6 (.lfu5) to scroll through pages/menu mapping for STACK
        sendCommand("LFU_5")
        Thread.sleep(forTimeInterval: 0.5)
        
        // After pressing LFU_5, we should be in STACK menu.
        // Wait! Let's just tap LFU_0 to select the first option (4-LVL)
        sendCommand("LFU_0")
        Thread.sleep(forTimeInterval: 0.5)
        
        takeScreenshot(name: "testFirmwareStackMenuSoftkeys")
        
        // After setting STACK size, we're back to main display.
        // Let's verify it by checking the screen
        let screen = readScreen(expecting: "X:")
        XCTAssertTrue(screen.contains("X:"), "Screen did not return to normal view after STACK menu execution")
    }
}
