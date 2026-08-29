import XCTest
@testable import RPNCore

final class TempTest: XCTestCase {
    func testStress() {
        let engine = CalculatorEngine()
        
        let startMem = getMemory()
        
        for _ in 0..<1_000_000 {
            engine.digit(5)
            engine.enter()
            engine.digit(2)
            engine.executeMath("×")
            engine.executeMath("SIN")
            engine.digit(3)
            engine.executeMath("yˣ")
        }
        
        let endMem = getMemory()
        print("MEMORY DELTA: \((endMem > startMem ? endMem - startMem : 0)/1024) KB")
    }
    
    func getMemory() -> UInt64 {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            return taskInfo.resident_size
        } else {
            return 0
        }
    }
}
