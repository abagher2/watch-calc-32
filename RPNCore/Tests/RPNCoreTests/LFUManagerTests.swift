import XCTest
@testable import RPNCore

final class LFUManagerTests: XCTestCase {
    
    func testLFUEviction() {
        let manager = LFUManager()
        
        // The LFUManager has 6 slots total
        // Let's populate all 6 slots with unique functions
        
        // We need 6 distinct functions that are NOT in the ignored list.
        // The ignored list includes basic numbers, C, ENTER, etc.
        let functions = [
            "SIN", "COS", "TAN", "ASIN", "ACOS", "ATAN"
        ]
        
        // Execute each function multiple times to give them usage counts
        // We will execute the first function (index 0) only 1 time,
        // and the others multiple times.
        for (index, function) in functions.enumerated() {
            let usageCount = index == 0 ? 1 : (index + 2)
            for _ in 0..<usageCount {
                manager.recordUsage(of: function)
            }
        }
        
        // At this point, "SIN" has the lowest usage count (1).
        // Let's verify that "SIN" is present in the slots.
        XCTAssertTrue(manager.slots.contains("SIN"), "SIN should be in one of the slots")
        
        // Now we execute a 7th function (e.g., "√x") a bunch of times
        // It should evict the least frequently used function ("SIN")
        for _ in 0..<5 {
            manager.recordUsage(of: "√x")
        }
        
        // Verify that "SIN" is NO LONGER in the slots
        XCTAssertFalse(manager.slots.contains("SIN"), "SIN should have been evicted")
        
        // Verify that "√x" IS in the slots
        XCTAssertTrue(manager.slots.contains("√x"), "√x should be in one of the slots")
    }
}
